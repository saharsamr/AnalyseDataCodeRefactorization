classdef OrientationTrial < Trials.Trial
    properties (Access = public)
        orientation_number
        spatial_frequency
        phase
        contrast
        start_fixation_time
        start_stimulus_time
        reward_time
        % stimulus_number_in_trial
        % real_stimulus_show_time
    end

    methods (Access = public)
        function extract_trial_data ( ...
                                this, ...
                                experiment_events, ...
                                experiment_properties, ...
                                experiment_start_date, ...
                                trial_start_index, ...
                                trial_end_index, ...
                                eye_time_samples, ...
                                data_eye, ...
                                start_time_eyelink ...
        )
            extract_trial_data@Trials.Trial( ...
                                    this, ...
                                    experiment_events, ...
                                    experiment_properties, ...
                                    experiment_start_date, ...
                                    trial_start_index, ...
                                    trial_end_index, ...
                                    eye_time_samples, ...
                                    data_eye, ...
                                    start_time_eyelink ...
            );
            used_indices = Utils.Util.find_all_indices_contain_some_words( ...
                                                    this.trial_events.info, ...
                                                    'display', ...
                                                    'tracker', ...
                                                    'keyboard', ...
                                                    'TRIALID', ...
                                                    'failedTrial' ...
            );
            this.update_used_indices(used_indices);
        end

        function set_states_of_trail (this)
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
            set_spike_times@Trials.Trial(this, time_stamp_11);
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
                stimulus_str = stimulus_str(strfind(stimulus_str, ':')+3:end-1);
                stimulus_str = strrep(stimulus_str, '&', ' ');
                values = str2num(stimulus_str);
                this.orientation_number = values(1);
                this.contrast = values(2);
                this.phase = values(3);
                this.spatial_frequency = values(4);
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
