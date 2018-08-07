classdef DAO < handle

    properties (Access = private)
        subject_name
        task_name
        researcher_firstname
        researcher_lastname
        bar_sampling_frequency
        close_fig_flag
        data_folder
        data_list
        time_start
        time_end
        time_data
    end

    methods (Access = public)
        function this = DAO ( ...
                subject_name, ...
                task_name, ...
                researcher_firstname, ...
                researcher_lastname, ...
                time_start, ...
                time_end, ...
                bar_sampling_frequency, ...
                close_fig_flag, ...
                data_folder_pass ...
        )
            this.subject_name = subject_name;
            this.task_name = task_name;
            this.researcher_firstname = researcher_firstname;
            this.researcher_lastname = researcher_lastname;
            this.time_start = datetime(time_start, 'InputFormat', 'yyyy-MM-dd HH:mm:SS');
            this.time_end = datetime(time_end, 'InputFormat', 'yyyy-MM-dd HH:mm:SS');
            this.bar_sampling_frequency = bar_sampling_frequency;
            this.close_fig_flag = close_fig_flag;
            this.data_folder = data_folder_pass;
            this.data_list = dir(fullfile(this.data_folder, '*.edf'));
            this.time_data = datetime(this.data_list(1).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
        end

        function extract_experiments_data (this)
            for exp_index = 1:numel(this.data_list)
                this.time_data = datetime(this.data_list(exp_index).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
                postfix = this.data_list(exp_index).name(22:end-4);
                try
                    this.validate_time_data();
                    disp(this.data_list(exp_index).name(1:20));
                    experiment = Experiments.([CONFIG.Config.TASK_NAME 'Experiment'])( ...
                                postfix, ...
                                this.task_name, ...
                                this.subject_name, ...
                                this.researcher_firstname, ...
                                this.researcher_lastname, ...
                                this.time_data ...
                    );
                    experiment.extract_experiment_data(exp_index);
                    experiment.convert_properties_to_struct();
                    experiment = struct(experiment);
                    this.save_data(exp_index, experiment);
                catch e
                    disp(e.message);
                    continue
                end
            end
        end
    end

    methods (Access = private)
        function validate_time_data (this)
            if this.time_data < this.time_start || ...
                this.time_data > this.time_end
                throw (MException( ...
                    'DAO:ValidateTime', ...
                    'Time is out of valid range.' ...
                ));
            end
        end

        function save_data (this, exp_index, experiment)
            output_folder = 'E:\IPM\EyeLink_DataExtraction\RefactoredCodes\';
            dir_name = [output_folder 'output/' this.task_name '/' this.subject_name '/' this.data_list(exp_index).name(1:end-4)];
            warning('off', 'MATLAB:MKDIR:DirectoryExists');
            mkdir(dir_name);
            warning('on', 'MATLAB:MKDIR:DirectoryExists');
            save([dir_name '/data.mat'], 'experiment');
        end
    end

    methods (Static)
        function data_eye = load_eyelink_data (exp_index)
            data_folder = CONFIG.Config.EYELINK_DATA_PATH;
            data_list = dir(fullfile(data_folder, '*.edf'));
            path = [data_folder data_list(exp_index).name(1:end-4)];
            data_eye = Edf2Mat([path '.edf']);
        end

        function [NEV, NS5] = load_blackrock_data (exp_index) %TODO: ask for set a prper name for br data too.
            path = CONFIG.Config.BLACKROCK_DATA_PATH;
            NEV = openNEV([path 'RF.nev'], 'overwrite');
            NS5 = openNSx([path 'RF.ns6']);
        end
    end

end
