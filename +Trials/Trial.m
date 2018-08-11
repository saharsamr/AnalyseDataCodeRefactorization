classdef Trial < AnalysisData.Data
    properties (Access = public)
        ID
        trial_number = []
        trial_events
        start_time
        end_time
        bar
        error
        reward_value
        states
        spike_times
        is_good_trial
        eye
        TTWs
        state_timing
        used_indices = []
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
            this.set_id(trial_start_index, experiment_events);
            this.set_trial_events( ...
                                    experiment_events, ...
                                    trial_start_index, ...
                                    trial_end_index ...
            );
            this.set_trial_number();
            this.set_times();
            bar_indices = this.set_bar_info();
            this.update_used_indices(bar_indices);
            TTW_indices = this.set_TTWs();
            this.update_used_indices(TTW_indices);
            this.eye = AnalysisData.Eye( ...
                                            eye_time_samples, ...
                                            this.start_time, ...
                                            this.trial_events, ...
                                            data_eye ...
            );
            % this.set_state_timings(data_eye, start_time_eyelink);
        end

        function set_goodness_and_reward_of_trial (this)
            this.set_errors();
            this.set_reward_value();
            % TODO: implement this method, for all subclasses.
        end

        function set_states_of_trail (this)
            this.set_trial_states_transmitions();
            % TODO: implement this method, for all subclasses.
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
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end

    methods (Access = protected)

        function set_trial_states_transmitions (this)
            this.states = AnalysisData.Event( ...
                        this.trial_events.info(setdiff(1:numel(this.trial_events.info), ...
                                            this.used_indices)), ...
                        this.trial_events.time(setdiff(1:numel(this.trial_events.info), ...
                                            this.used_indices)) ...
            );
        end

        function set_id ( ...
                          this, ...
                          trial_start_index, ...
                          experiment_events ...
        )
            id_str = experiment_events.info{trial_start_index};
            this.ID = Utils.Util.substr2double(id_str, ' ', 1);
        end

        function set_trial_events ( ...
                                    this, ...
                                    experiment_events, ...
                                    trial_start_index, ...
                                    trial_end_index ...
        )
            this.trial_events = AnalysisData.Event( ...
                            experiment_events.info(trial_start_index:trial_end_index), ...
                            experiment_events.time(trial_start_index:trial_end_index) ...
            );
        end

        function set_trial_number (this)
            trial_num_index = Utils.Util.find_all( ...
                                                   this.trial_events.info, ...
                                                   'trialNumber:' ...
            );
            if ~isempty(trial_num_index)
                trial_num_str = this.trial_events.info{trial_num_index};
                this.trial_number = Utils.Util.substr2double(trial_num_str, ' ', 1);
            end
        end

        function set_times (this)
            this.start_time = this.trial_events.time(1);
            this.end_time = this.trial_events.time(end);
        end

        function bar_index = set_bar_info (this)
            bar_index = Utils.Util.find_all(this.trial_events.info, 'bar:');
            this.bar = AnalysisData.Bar( ...
                                        this.trial_events.info(bar_index), ...
                                        this.trial_events.time(bar_index) ...
            );
            this.bar.remakeBarSignal(this.end_time, CONFIG.Config.BAR_SAMPLING_FREQ);
        end

        function TTW_indices = set_TTWs (this)
            this.TTWs = AnalysisData.TTWs();
            TTW_indices   = Utils.Util.find_all(this.trial_events.info, 'TTW:');
            for TTW_index = TTW_indices
                TTW_str = this.trial_events.info{TTW_index};
                this.TTWs.add_value(TTW_str);
            end
        end

        function set_errors (this)
            start_state_index = Utils.Util.find_last( ...
                                                      this.states.info, ...
                                                      'barWait=>barWait_waiter' ...
            );
            error_index = Utils.Util.find_last(this.states.info, '=>error');
            this.error = (~isempty(error_index)) & (error_index > start_state_index);
        end

        function set_reward_value (this)
            reward_index = Utils.Util.find_all(this.states.info, 'reward:');
            reward_index = reward_index(end);
            if this.error
                this.reward_value = -1;
            elseif isempty(reward_index)
                this.reward_value = -2;
            else
                this.reward_value = Utils.Util.substr2double(this.states.info{reward_index}, ':', 2)/0.2;
            end
        end

        function set_acceptable_states (this, start_of_each_trial)
            start_real_trial = Utils.Util.find_last( ...
                                                    this.states.info, ...
                                                    start_of_each_trial ...
            );
            this.states.info =this.states.info(start_real_trial:end);
            this.states.time = this.states.time(start_real_trial:end);
        end

        function check_trial_goodness_by_states (this, start_state, end_state)
            start_index = Utils.Util.find_all(this.states.info, start_state);
        end_index = Utils.Util.find_all(this.states.info, end_state);
            this.is_good_trial = (~isempty(start_index) & (~isempty(end_index)));
        end

        function state_time = find_state_time (this, state_name)
            state_time = this.states.time( ...
                            Utils.Util.find_last(this.states.info, state_name) ...
            );
        end

        function set_state_timings (this, data_eye, start_time_eyelink)
            if this.is_good_trial
                this.state_timing = AnalysisData.StatesTimings(this.states);
                this.eye.set_saccade_time( ...
                                           data_eye, ...
                                           this.state_timing, ...
                                           start_time_eyelink ...
                );
            end
        end

        function update_used_indices (this, new_indices)
            this.used_indices = union(this.used_indices, new_indices);
        end
    end

end
