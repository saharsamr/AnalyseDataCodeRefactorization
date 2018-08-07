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
            this@Experiments.Experiment( ...
                                    postfix, ...
                                    exType, ...
                                    exSubject, ...
                                    exResearcherFN, ...
                                    exResearcherLN, ...
                                    startDate ...
            );
        end

        function extract_experiment_data (this, exp_index)
            extract_experiment_data@Experiments.Experiment(this, exp_index);
            [NEV, NS5] = DAO.DAO.load_blackrock_data();
            this.set_trials_spikes(NEV);
            this.plot_spikes_during_trials();
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

    methods (Access = protected)
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

        function plot_spikes_during_trials (this)
            orientations = this.find_experiment_orientations();
            f = figure(1);
            delta_y = 0.2;
            for i = 1:numel(orientations)
                selected_trials = this.trials([this.trials.orientation_number] == i);
                subplot(numel(orientations),1,i);
                this.plot_spikes_of_single_trial(selected_trials, i, delta_y);
                Utils.Plot.set_subplot_figure_design( ...
                                                -2000, ...
                                                6000, ...
                                                0, ...
                                                (numel(selected_trials)+1)*delta_y, ...
                                                orientations(i) ...
                );
            end
            Utils.Plot.set_plot_features( ...
                                    numel(orientations), ...
                                    1, ...
                                    numel(orientations), ...
                                    10000*[-0.2:0.1:0.6], ...
                                    'Time(ms)' ...
            );
        end

        function plot_spikes_of_single_trial (this, trials, subplot_index, delta_y)
            for j = 1:numel(trials)
                plot( ...
                    trials(j).spike_times - ...
                    trials(j).start_stimulus_time ...
                    , ...
                    j*delta_y* ...
                    ones(1, numel(trials(j).spike_times)) ...
                    , ...
                    'b.' ...
                );
                hold on
            end
        end

        function orientations = find_experiment_orientations (this)
            orientations_index = Utils.Util.find_last(this.Properties.info, ...
                                                      'stimulusOrientations' ...
            );
            orientations_str = this.Properties.info{orientations_index};
            orientations = eval(orientations_str(strfind(orientations_str, ':')+2:end));
        end

        function [start_time_eyelink,eye_time_samples] = calibrate_times( ...
                                                                    this, ...
                                                                    events_, ...
                                                                    data_eye ....
        )
            [start_time_eyelink, eye_time_samples] = ...
                calibrate_times@Experiments.Experiment(this, events_, data_eye) ...
            ;
        end

        function set_experiment_properties (this, events_, trials_start_indices)
            set_experiment_properties@Experiments.Experiment( ...
                                                        this, ...
                                                        events, ...
                                                        trials_start_indices ...
            );
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
            filter_good_trials@Experiments.Experiment(this);
        end
    end

end
