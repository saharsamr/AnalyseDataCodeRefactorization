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
        data_eye % TODO: ask wether it just keep eye data!
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
            this.data_list = dir([this.data_folder '*.edf'])
            this.time_data = datetime(this.data_list(1).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
        end

        function extract_experiments_data (this)
            for exp_index = 1:numel(this.data_list)
                time_data = datetime(data_list(exp_index).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
                postfix = data_list(exp_index).name(22:end-4);
                try
                    this.validate_time_data()
                    data_eye = this.load_data(exp_index)
                    experiment = Experiment( ...
                                            postfix, ...
                                            this.task_name, ...
                                            this.subject_name, ...
                                            this.researcher_firstname, ...
                                            this.researcher_lastname, ...
                                            time_data ...
                                );
                    experiment.set_data_eye(data_eye);
                catch e
                    fprintf(1, e.message)
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
                    'Invalid experiment time', ...
                    'Time is out of valid range.' ...
                ));
            end
        end

        function data_eye = load_data (this, exp_index)
            path = [this.data_folder this.data_list(exp_index).name(1:end-4)];
            data_eye = Experiment_Data(Edf2Mat([path '.edf']));
            load([path '.mat']);
        end
    end

end
