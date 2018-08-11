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

        function extract_experiment_el_data (this, exp_index)
            data_eye = DAO.DAO.load_eyelink_data(exp_index);
            events_ = AnalysisData.Event( ...
                            data_eye.Events.Messages.info, ...
                            data_eye.Events.Messages.time ...
            );
            [start_time_eyelink, eye_time_samples] = this.calibrate_times(events_, data_eye);
            trials_start_indices = Utils.Util.find_all(events_.info, 'trialNumber');
            this.set_experiment_properties(events_, trials_start_indices);
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

        function extract_experiment_br_data (this)
            [NEV, NS5] = DAO.DAO.load_blackrock_data();
            this.set_trials_spikes(NEV);
        end

        function set_trials_spikes (this, NEV)
            [br_time_stamps, br_states] = this.extract_br_timestamps_and_states(NEV);
            time_stamp_11 = this.align_br_and_el_times( ...
                                                br_time_stamps, ...
                                                br_states, ...
                                                NEV ...
            );
            for trial_index = 1:numel(this.trials)
                this.trials(trial_index).set_spike_times(time_stamp_11);
            end
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Abstract, Access = public)
        extract_experiment_data (thid, exp_index);
    end

    methods (Access = protected)
        function [start_time_eyelink, eye_time_samples] = calibrate_times(this, events_, data_eye)
            start_time_eyelink = events_.time( ...
                    find(strcmp(events_.info, 'trialNumber: 1'),1) ...
            );
            events_.time = events_.time - start_time_eyelink;
            eye_time_samples = data_eye.Samples.time - ...
                                    start_time_eyelink;
        end

        function set_experiment_properties (this, events_, trials_start_indices)
            this.Properties = AnalysisData.Event( ...
                                events_.info(1:trials_start_indices(1)-1), ...
                                events_.time(1:trials_start_indices(1)-1) ...
            );
        end

        function [br_time_stamps, br_states] = extract_br_timestamps_and_states (this, NEV)
            br_time_stamps = NEV.Data.SerialDigitalIO.TimeStamp;
            br_states = this.extract_br_states(NEV, br_time_stamps);
            br_time_stamps = double(br_time_stamps(br_states~=0)) / ...
                             double(NEV.MetaTags.SampleRes) ...
            ;
            br_states = br_states(br_states~=0)';
        end

        function br_states = extract_br_states (this, NEV, br_time_stamps)
            Values = NEV.Data.SerialDigitalIO.UnparsedData;
            br_states = nan(size(Values));
            for stampIndex = 1:numel(br_time_stamps)
                binaryVector = de2bi(Values(stampIndex));
                binaryVector = binaryVector(1:6);
                br_states(stampIndex) = double(bi2de(binaryVector));
            end
        end

        function time_stamp_11 = align_br_and_el_times (this, br_time_stamps, br_states, NEV)
            spikes = NEV.Data.Spikes;
            br_init_time = br_time_stamps(br_states==3);
            el_init_time = this.find_el_the_first_state_time();
            alignment_value = (el_init_time - br_init_time(1));
            br_time_stamps = br_time_stamps + alignment_value;
            spikeTimeStamps = 1000*(double(NEV.Data.Spikes.TimeStamp) / ...
                                    double(NEV.MetaTags.SampleRes) + ...
                                    alignment_value ...
            );
            time_stamp_11 = double(spikeTimeStamps(spikes.Electrode == 11));
        end

        function el_init_time = find_el_the_first_state_time (this)
            el_init_time = this.trials(1).trial_events.time( ...
                            find( ...
                                strcmp( ...
                                    this.trials(1).trial_events.info, ...
                                    'init=>barWait' ...
                                ),1 ...
                            ) ...
            ) / 1000.0;
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
