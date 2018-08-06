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
                startDate ...
        )
            this.Postfix = postfix;
            this.ExperimentType = exType;
            this.ExperimentSubjectName =  exSubject;
            this.ExperimentResearcherFirstName = exResearcherFN;
            this.ExperimentResearcherLastName = exResearcherLN;
            this.startDate = startDate;
        end

        function extract_experiment_data (this, exp_index)
            data_eye = DAO.DAO.load_eyelink_data(exp_index);
            events_ = AnalysisData.Event( ...
                            data_eye.Events.Messages.info, ...
                            data_eye.Events.Messages.time ...
            );
            [start_time_eyelink, eye_time_samples] = this.calibrate_times(events_, data_eye);
            trials_start_indices = Utils.Util.find_all(events_.info, 'trialNumber');
            % this.set_experiment_properties(events_, trials_start_indices);
            this.Properties = AnalysisData.Event( ...
                                events_.info(1:trials_start_indices(1)-1), ...
                                events_.time(1:trials_start_indices(1)-1) ...
            );
            this.trials = Trials.([CONFIG.Config.TASK_NAME 'Trial']).empty(numel(trials_start_indices), 0);
            for trial_index = 1:numel(trials_start_indices)
                this.trials(trial_index) = eval(([ ...
                                                    'Trials.' ...
                                                    CONFIG.Config.TASK_NAME ...
                                                    'Trial'...
                ]));
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
                this.trials(trial_index).set_states_of_trail(trial_index);
                this.trials(trial_index).set_goodness_and_reward_of_trial( ...
                                                this.Properties, ...
                                                this.startDate ...
                );
            end
            this.filter_good_trials();
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Access = protected)
        function [start_time_eyelink, eye_time_samples] = calibrate_times(this, events_, data_eye)
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
                if this.trials(trial_index).is_good_trial == 1
                    result(result_index) = this.trials(trial_index);
                    result_index = result_index + 1;
                end
            end
            this.trials = result;
        end
    end

end