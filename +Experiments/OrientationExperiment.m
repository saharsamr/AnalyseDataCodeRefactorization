classdef OrientationExperiment < Experiments.Experiment
    methods (Access = public)
        function this = OrientationExperiment ( ...
                postfix, ...
                exType, ...
                exSubject, ...
                exResearcherFN, ...
                exResearcherLN, ...
                startDate ...
        )
            this@Experiments.Experiment(postfix, exType, exSubject, exResearcherFN, exResearcherLN, startDate);
        end

        function extract_experiment_data (this, exp_index)
            extract_experiment_data@Experiments.Experiment(this, exp_index);
            [NEV, NS5] = DAO.DAO.load_blackrock_data();
            this.set_trials_spikes(NEV);
        end

        function set_trials_spikes (this, NEV)
            [br_time_stamps, br_states] = this.extract_br_timestamps_and_states(NEV);
            time_stamp_11 = this.align_br_and_el_times(br_time_stamps, br_states, NEV);
            for trial_index = 1:numel(this.trials)
                disp(trial_index);
                this.trials(trial_index).set_spike_times(time_stamp_11);
            end
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Access = protected)
        function [br_time_stamps, br_states] = extract_br_timestamps_and_states (this, NEV)
            br_time_stamps = NEV.Data.SerialDigitalIO.TimeStamp;
            br_states = this.extract_br_states(NEV, br_time_stamps);
            br_time_stamps = double(br_time_stamps(br_states~=0)) / double(NEV.MetaTags.SampleRes);
            br_states = br_states(br_states~=0)';
        end

        function br_states = extract_br_states (this, NEV, br_time_stamps)
            Values       = NEV.Data.SerialDigitalIO.UnparsedData;
            br_states     = nan(size(Values));
            for stampIndex = 1:numel(br_time_stamps)
                binaryVector = de2bi(Values(stampIndex));
                binaryVector = binaryVector(1:6);
                br_states(stampIndex) = double(bi2de(binaryVector));
            end
        end

        function time_stamp_11 = align_br_and_el_times (this, br_time_stamps, br_states, NEV)
            spikes = NEV.Data.Spikes;
            br_init_time = br_time_stamps(br_states==3);
            el_init_time = this.trials(1).trial_events.time(find(strcmp(this.trials(1).trial_events.info, 'init=>barWait'),1)) / 1000.0;
            alignment_value = (el_init_time - br_init_time(1));
            br_time_stamps = br_time_stamps + alignment_value;
            spikeTimeStamps = 1000*(double(NEV.Data.Spikes.TimeStamp)/double(NEV.MetaTags.SampleRes) + alignment_value);
            time_stamp_11 = double(spikeTimeStamps(spikes.Electrode == 11));
        end

        function [start_time_eyelink, eye_time_samples] = calibrate_times(this, events_, data_eye)
            [start_time_eyelink, eye_time_samples] = calibrate_times@Experiments.Experiment(this, events_, data_eye);
        end

        function set_experiment_properties (this, events_, trials_start_indices)
            set_experiment_properties@Experiments.Experiment(this, events, trials_start_indices);
        end

        function filter_good_trials (this)
            filter_good_trials@Experiments.Experiment(this);
        end
    end

end
