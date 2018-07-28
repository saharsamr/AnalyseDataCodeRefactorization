%% Data Access Object (DAO)
% This class is the layer between the *eyelink* and *AnalysisData/Experiment*
% object which handles the extraction of data related to each experiment.


%% Common detail of several experiments
% The *DAO* class holds these properties which are common accross some
% experiment; such as who has done these experiments and they've done in what
% range of time.
% the *data_list* property is the list of *.edf* files receives from *eyelink*
% for distinct experiments.
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

    %% DAO Constructor
    % set the properties using passed arguments and by parsing file names and
    % setting the related times, etc.
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
            this.time_start = datetime( ...
                                       time_start, ...
                                       'InputFormat', ...
                                       'yyyy-MM-dd HH:mm:SS' ...
            );
            this.time_end = datetime( ...
                                    time_end, ...
                                    'InputFormat', ...
                                    'yyyy-MM-dd HH:mm:SS' ...
            );
            this.bar_sampling_frequency = bar_sampling_frequency;
            this.close_fig_flag = close_fig_flag;
            this.data_folder = data_folder_pass;
            this.data_list = dir(fullfile(this.data_folder, '*.edf'));
            this.time_data = datetime( ...
                                    this.data_list(1).name(1:20), ...
                                    'InputFormat', ...
                                    'dd-MMM-yyyy-HH-mm-SS' ...
            );
        end


    %% Extract Data Related to Each Experiments
    % Each *.edf* file is representing data of a specific experiment which
    % has several trials that has been tested under the same enviroment
    % conditions.
    % The description of each function called here is available at the top
    % of that function definition.
        function extract_experiments_data (this)
            for exp_index = 1:numel(this.data_list)
                this.time_data = datetime( ...
                                        this.data_list(exp_index).name(1:20), ...
                                        'InputFormat', ...
                                        'dd-MMM-yyyy-HH-mm-SS' ...
                );
                disp(this.data_list(exp_index).name(1:20));
                postfix = this.data_list(exp_index).name(22:end-4);
                try
                    this.validate_time_data();
                    data_eye = this.load_data(exp_index);
                    experiment = AnalysisData.Experiment( ...
                                            postfix, ...
                                            this.task_name, ...
                                            this.subject_name, ...
                                            this.researcher_firstname, ...
                                            this.researcher_lastname, ...
                                            this.time_data ...
                    );
                    experiment.extract_experiment_data(data_eye);
                    experiment = struct(experiment);
                    this.save_data(exp_index, experiment);
                catch e
                    error(e.message);
                    continue
                end
            end
        end
    end

    %% Validate the Experiment Time
    % We previously mentioned that the *DAO* try to extract data of experiments
    % which has common situations, specially the range of time they has been
    % experimented.
    % This function is checking that the *.edf* file time data is compatible
    % with the time that we set in the config file. (those configs are passed
    % to experiment using DAO class.)
        function validate_time_data (this)
            if this.time_data < this.time_start || ...
                this.time_data > this.time_end
                throw (MException( ...
                    'Invalid experiment time', ...
                    'Time is out of valid range.' ...
                ));
            end
        end

    %% Load Experiment Data
    % At this step, by help of an external library, which the codes are located
    % in the *edfReader* folder, we translate the *.edf* format to the proper
    % *.mat* format for easier use of data in future.
        function data_eye = load_data (this, exp_index)
            addpath('edfReader')
            path = [this.data_folder this.data_list(exp_index).name(1:end-4)];
            data_eye = Edf2Mat([path '.edf']);
        end

    %% Save Final Data
    % After extraction of data related to each experimetn, we need to store the
    % retreived data in a *.mat* file to be easily available for future need of
    % them. This function is doing that.
        function save_data (this, exp_index, experiment)
            output_folder = 'Folder Pass to Save the Result';
            dir_name = [Directory that we want to have to reach to saved data];
            warning('off', 'MATLAB:MKDIR:DirectoryExists');
            mkdir(dir_name);
            warning('on', 'MATLAB:MKDIR:DirectoryExists');
            save([dir_name '/data.mat'], 'experiment');
        end
