classdef Experiment < AnalysisData.Data
    properties (Access = public)
        Postfix = ''
        ExperimentType = ''
        ExperimentSubjectName = ''
        ExperimentResearcherFirstName = ''
        ExperimentResearcherLastName = ''
        startDate
        Properties
        trials
    end

    methods (Access = public)
        function this = Experiment ( ...
                postfix, ...
                exType, ...
                exSubject, ...
                exResearcherFN, ...
                exResearcherLN, ...
                startDate, ...
                data_eye ...
        )
            this.Postfix = postfix;
            this.ExperimentType = exType;
            this.ExperimentSubjectName =  exSubject;
            this.ExperimentResearcherFirstName = exResearcherFN;
            this.ExperimentResearcherLastName = exResearcherLN;
            this.startDate = startDate; %TODO: heck that this parameter is set correctly.
        end

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
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Access = private)
        function [start_time_eyelink, eye_time_samples] = calibrate_times (this, events_, data_eye)
            start_time_eyelink = events_.time( ...
                    find(strcmp(events_.info, 'trialNumber: 1'),1) ...
            );
            events_.time = events_.time - start_time_eyelink;
            eye_time_samples = data_eye.Samples.time - ...
                                    start_time_eyelink;
            % TODO: maybe we can put saccade calibration here too.
        end

        function set_experiment_properties (this, events_, trials_start_indices)
            this.Properties = AnalysisData.Event( ...
                                events_.info(1:trials_start_indices(1)-1), ...
                                events_.time(1:trials_start_indices(1)-1) ...
            );
        end

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
    end

end
