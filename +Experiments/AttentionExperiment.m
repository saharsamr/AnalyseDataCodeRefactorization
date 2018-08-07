classdef AttentionExperiment < Experiments.Experiment
    methods (Access = public)
        function this = AttentionExperiment ( ...
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
            extract_experiment_el_data@Experiments.Experiment(this, exp_index);
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@Experiments.Experiment(this);
        end
    end

    methods (Access = protected)
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
