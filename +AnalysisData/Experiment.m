%% Experiments
% Experiments are the container of trials which has been tested by specifics
% value for properties.

%% Experiment properties
% These are the features that are common accross all trials and the trials itselves.
    properties (Access = public)
        Postfix = ''
        ExperimentType = ''
        ExperimentSubjectName = ''
        ExperimentResearcherFirstName = ''
        ExperimentResearcherLastName = ''
        startDate
        Properties
        trials

    %% Extract experiment data
    % The function below just calls other functions for this extraction.
        function extract_experiment_data (this, data_eye)
            events_ = AnalysisData.Event( ...
                            data_eye.Events.Messages.info, ...
                            data_eye.Events.Messages.time ...
            );
            [start_time_eyelink, eye_time_samples] = this.calibrate_times(events_, data_eye);
            trials_start_indices = Utils.Util.find_all(events_.info, 'trialNumber');
            this.set_experiment_properties(events_, trials_start_indices);
            this.trials = AnalysisData.Trial.empty(numel(trials_start_indices), 0);
            for trial_index = 1:numel(trials_start_indices)
                this.trials(trial_index) = AnalysisData.Trial();
                this.trials(trial_index).extract_trial_data( ...
                                                trial_index, ...
                                                events_, ...
                                                this.Properties, ...
                                                this.startDate, ...
                                                trials_start_indices, ...
                                                eye_time_samples, ...
                                                data_eye, ...
                                                start_time_eyelink ...
                );
            end
            this.filter_good_trials();
            this.convert_properties_to_struct();
        end

    %% Calibrate Experiment times
    % By callibration, we can analyse data with relative times.
        function [start_time_eyelink, eye_time_samples] = calibrate_times (this, events_, data_eye)
            start_time_eyelink = events_.time( ...
                    find(strcmp(events_.info, 'trialNumber: 1'),1) ...
            );
            events_.time = events_.time - start_time_eyelink;
            eye_time_samples = data_eye.Samples.time - ...
                                    start_time_eyelink;
        end

    %% Set Experiment's Properties
    % There are lots of features that would affect the experiment's result. For
    % instance, the color and duration of appearance for the cue is an important
    % factor. this function extracts these properties for furtur analysis.
        function set_experiment_properties (this, events_, trials_start_indices)
            this.Properties = AnalysisData.Event( ...
                                events_.info(1:trials_start_indices(1)-1), ...
                                events_.time(1:trials_start_indices(1)-1) ...
            );
        end

    %% Filtering Good Trials
    % Not all the trials are proper to participate in our analysis, the *isGood*
    % property of each trials is the property that detect this. Here, we just
    % filter out the trials which their *isGood* property is not equal to 1.
        function filter_good_trials (this)
            result_index = 1;
            for trial_index = 1:numel(this.trials)
                if this.trials(trial_index).isGood2 == 1
                    result(result_index) = this.trials(trial_index);
                    result_index = result_index + 1;
                end
            end
            this.trials = result;
        end
