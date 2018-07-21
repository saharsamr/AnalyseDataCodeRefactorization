classdef DAO

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
                    this.validate_time_data()
                    data_eye = this.load_data(exp_index)
                    experiment = AnalysisData.Experiment( ...
                                            postfix, ...
                                            this.task_name, ...
                                            this.subject_name, ...
                                            this.researcher_firstname, ...
                                            this.researcher_lastname, ...
                                            this.time_data, ...
                                            data_eye ...
                                );
                    % disp('Text');
                    experiment.extract_experiment_data();
                catch e
                    disp(e.message);
                    continue
                end
            end
            this.save_data();
        end
    end

    methods (Access = private)
        function validate_time_data (this)
            if this.time_data < this.time_start || ...
                 this.time_data > this.time_end
                throw (MException( ...
                    'Invalid experiment time', ...
                    'Time is out of valid range.' ...
                ));
            end
        end

        function data_eye = load_data (this, exp_index)
            addpath('edfReader')
            path = [this.data_folder this.data_list(exp_index).name(1:end-4)];
            data_eye = AnalysisData.Experiment_Data(Edf2Mat([path '.edf']));
            % load([path '.mat']); % TODO: does not save any .mat files.
            % disp('done');
        end

        function save_data (this)
            output_folder = 'D:\Analysis code\';
            dir_name = [output_folder 'output/' TaskName '/' SubjectName '/' data_list(exp_index).name(1:end-4)];
            warning('off', 'MATLAB:MKDIR:DirectoryExists')
            mkdir(dir_name);
            warning('on', 'MATLAB:MKDIR:DirectoryExists')
            %serialized_Exp = serialize(Experiment);
            %save([dir_name '/data.mat'], 'serialized_Exp','-v7.3')
            save([dir_name '/data.mat'], 'Experiment')
        end 
    end

end
