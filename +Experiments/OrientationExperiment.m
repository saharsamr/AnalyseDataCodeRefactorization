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
            this.extract_experiment_el_data(exp_index);
            this.extract_experiment_br_data();
            this.plot_spikes_during_trials();
        end

        function extract_experiment_el_data (this, exp_index)
            extract_experiment_el_data@Experiments.Experiment(this, exp_index);
        end

        function extract_experiment_br_data (this)
            extract_experiment_br_data@Experiments.Experiment(this);
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Access = protected)
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

        function [start_time_eyelink,eye_time_samples] = ...
                    calibrate_times(this, events_, data_eye)
            [start_time_eyelink, eye_time_samples] = ...
                calibrate_times@Experiments.Experiment(this, events_, data_eye) ...
            ;
        end

        function set_experiment_properties (this, events_, trials_start_indices)
            set_experiment_properties@Experiments.Experiment( ...
                                                        this, ...
                                                        events_, ...
                                                        trials_start_indices ...
            );
        end

        function filter_good_trials (this)
            filter_good_trials@Experiments.Experiment(this);
        end
    end

end
