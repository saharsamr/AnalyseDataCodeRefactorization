classdef DAO
    properties (Access = private)
        subject_name
        task_name
        researcher_firstname
        researcher_lastname
        time_start
        time_end
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
        function this = DAO (
                subject_name,
                task_name,
                researcher_firstname,
                researcher_lastname,
                time_start,
                time_end,
                bar_sampling_frequency,
                close_fig_flag,
                data_folder_pass
        )
            this.subject_name = subject_name;
            this.task_name = task_name;
            this.researcher_firstname = researcher_firstname;
            this.researcher_lastname = researcher_lastname;
            this.time_start = time_start;
            this.time_end = time_end;
            this.bar_sampling_frequency = bar_sampling_frequency;
            this.close_fig_flag = close_fig_flag;
            this.data_folder = data_folder_pass;
            this.data_list = dir([data_folder '*.edf']);
            this.time_start = datetime(time_start, 'InputFormat', 'yyyy-MM-dd HH:mm:SS');
            this.time_end = datetime(time_end, 'InputFormat', 'yyyy-MM-dd HH:mm:SS');
            this.time_data = datetime(data_list(1).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
        end

        function extract_experiments_data (this)
            for exp_index = 1:numel(this.data_list)
                time_data = datetime(data_list(exp_index).name(1:20), 'InputFormat', 'dd-MMM-yyyy-HH-mm-SS');
                try
                    this.validate_time_data()
                    this.load_data(exp_index)
                catch e
                    fprintf(1, e.message)
                    continue
                end
                postfix = data_list(exp_index).name(22:end-4);
                experiment = Experiment(
                                        postfix,
                                        this.task_name,
                                        this.subject_name,
                                        this.researcher_firstname,
                                        this.researcher_lastname,
                                        time_data
                            );

            end
        end
    end

    methods (Access = private)
        function validate_time_data (this)
            if this.time_data < this.time_start || this.time_data > this.time_end
                throw MException('Invalid experiment time', 'Time is out of valid range.');
            end
        end

        function load_data (this, exp_index)
            this.data_eye = Edf2Mat([this.data_folder this.data_list(exp_index).name(1:end-4) '.edf']);
            load([this.data_folder this.data_list(exp_index).name(1:end-4) '.mat']);
        end
    end

end
