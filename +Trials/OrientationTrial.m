classdef OrientationTrial < Trials.Trial %TODO: fix reward value bug for this trial.
    properties (Access = public)
        orientation_number
        start_fixation_time
        start_stimulus_time
        reward_time
        spike_times
        % stimulus_number_in_trial %TODO: what does this do?
        % real_stimulus_show_time
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
            failed_trial_indices = Utils.Util.find_all(this.trial_events.info, 'failedTrial');
            this.update_used_indices(failed_trial_indices);
            % this.set_orientation_number();
        end

        function set_states_of_trail (this, trial_index)
            set_states_of_trail@Trials.Trial(this);
            this.set_acceptable_states('stimulusNumberInTrial: 0');
            this.set_orientation_number();
            this.set_important_states_times();
        end

        function set_goodness_and_reward_of_trial (this, properties, start_date)
            set_goodness_and_reward_of_trial@Trials.Trial(this);
            this.check_trial_goodness_by_states( ...
                                            'barWait=>barWait_waiter', ...
                                            'releaseWait_waiter=>reward' ...
            );
        end

        function set_spike_times (this, time_stamp_11)
            try
                this.spike_times = time_stamp_11( ...
                                        time_stamp_11 < this.reward_time ...
                                        & ...
                                        time_stamp_11 > this.start_fixation_time ...
                );
            catch
            end
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@Trials.Trial(this);
        end
    end

    methods (Access = protected)
        function set_orientation_number (this)
            stimulus_name_index = Utils.Util.find_last( ...
                                                      this.trial_events.info, ...
                                                      'stimulusName' ...
            );
            if(~isempty(stimulus_name_index))
                stimulus_str = this.trial_events.info{stimulus_name_index};
                this.orientation_number = Utils.Util.substr2double(stimulus_str, ':', 3, '&', 1);
            end
            this.update_used_indices(stimulus_name_index);
        end

        function set_important_states_times (this)
            this.start_fixation_time = this.find_state_time('startFixation=>startFixation_waiter');
            this.start_stimulus_time = this.find_state_time('stimulus=>stimulus_waiter');
            this.reward_time = this.find_state_time('releaseWait_waiter=>reward');
        end

        function set_acceptable_states (this, start_of_each_trial)
            set_acceptable_states@Trials.Trial(this, start_of_each_trial);
        end

        function check_trial_goodness_by_states (this, start_state, end_state)
            check_trial_goodness_by_states@Trials.Trial(this, start_state, end_state);
        end

        function update_used_indices (this, new_indices)
            update_used_indices@Trials.Trial(this, new_indices);
        end

        function state_index = find_state_time (this, state_name)
            state_index = find_state_time@Trials.Trial(this, state_name);
        end
    end
end
