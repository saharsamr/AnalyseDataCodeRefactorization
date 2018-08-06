classdef HartleyTrial < Trials.Trial
    properties (Access = public)
        % stimulus_data %TODO: get proper data from the hartley.mat whenever it's needed. not here.
        stimulus_names
    end

    methods (Access = public)
        function extract_trial_data ( ...
                                this, ...
                                trial_index, ...
                                experiment_events, ...
                                experiment_properties, ...
                                experiment_start_date, ...
                                trials_start_indices, ...
                                eye_time_samples, ...
                                data_eye, ...
                                start_time_eyelink ...
        )
            extract_trial_data@Trials.Trial( ...
                                    this, ...
                                    trial_index, ...
                                    experiment_events, ...
                                    experiment_properties, ...
                                    experiment_start_date, ...
                                    trials_start_indices, ...
                                    eye_time_samples, ...
                                    data_eye, ...
                                    start_time_eyelink ...
            );
            display_indices = Utils.Util.find_all(this.trial_events.info, 'display');
            this.update_used_indices(display_indices);
            tracker_indices = Utils.Util.find_all(this.trial_events.info, 'tracker');
            this.update_used_indices(tracker_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'keyboard');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'TRIALID');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'fialedTrial');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'inParameter');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'TRIAL');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'audio');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'realstimulusShowTime');
            this.update_used_indices(keyboard_indices);
            % this.set_stimulus_data();
            this.set_stimulus_name();
        end

        function set_states_of_trail (this, trial_index)
            set_states_of_trail@Trials.Trial(this);
        end

        function set_goodness_and_reward_of_trial (this, properties, start_date)
            set_goodness_and_reward_of_trial@Trials.Trial(this);
            this.is_good_trial = ~this.error;
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@Trials.Trial(this);
        end
    end

    methods (Access = protected)
        function set_stimulus_name (this)  %TODO: all of them? orjust after the last 'barWait=>barWait_waiter'?
            stimulus_name_index = Utils.Util.find_all(this.trial_events.info, 'stimulusName');
            if(~isempty(stimulus_name_index))
                this.stimulus_names = AnalysisData.Event ( ...
                                this.trial_events.info(stimulus_name_index), ...
                                this.trial_events.time(stimulus_name_index) ...
                );
            end
            this.update_used_indices(stimulus_name_index);
        end

        function state_index = find_state_time (this, state_name)
            state_index = find_state_time@Trials.Trial(this, state_name);
        end
    end
end