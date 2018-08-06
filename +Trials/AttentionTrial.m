classdef AttentionTrial < Trials.Trial
    properties (Access = public)
        changed = []
        primary_goodness
        cue_index = []
        change_index = []
        should_keep = []
        good_amount = 0
        reaction_time = []
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
            changed_index = this.set_changed_flag();
            this.update_used_indices(changed_index);
            kept_bar_index = Utils.Util.find_all(this.trial_events.info, 'keptBar:');
            this.update_used_indices(kept_bar_index);
            trial_ID_index = Utils.Util.find_all(this.trial_events.info, 'TRIALID');
            this.update_used_indices(trial_ID_index);
        end

        function set_states_of_trail (this, trial_index)
            set_states_of_trail@Trials.Trial(this);
            this.set_cue_index(trial_index);
            this.set_change_index(trial_index);
            this.set_should_keep_index(trial_index);
        end

        function set_goodness_and_reward_of_trial ( ...
                                        this, ...
                                        experiment_properties, ...
                                        experiment_start_date ...
        )
            set_goodness_and_reward_of_trial@Trials.Trial(this);
            this.set_good_amount_for_keep_or_release(experiment_properties);
            this.set_goodness_parameter();
            this.set_reaction_time_and_update_goodness(experiment_start_date);
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@Trials.Trial(this);
        end
    end

    methods (Access = protected)

        function changed_index = set_changed_flag (this)
            changed_index = Utils.Util.find_all(this.trial_events.info, 'changed:');
            if ~isempty(changed_index)
                if ~isempty(strfind(this.trial_events.info{changed_index(end)}, 'false'))
                    this.changed = 0;
                elseif ~isempty(strfind(this.trial_events.info{changed_index(end)}, 'true'))
                    this.changed = 1;
                end
            end
        end

        function set_cue_index (this, trial_index)
           cue_index = Utils.Util.find_all(this.states.info, 'cueIndex:');
           if ~isempty(cue_index)
               cue_index = cue_index(end);
               this.cue_index = Utils.Util.substr2double(this.states.info{cue_index}, ':', 2);
           else
               warning(['no cueIndex found in trial ' ...
                        num2str(trial_index) ...
                        ' events! setting it to 1!'] ...
               )
               this.cue_index = 1;
           end
        end

        function set_change_index (this, trial_index)
           change_index = Utils.Util.find_all(this.states.info, 'changeIndex:');
            if ~isempty(change_index)
                change_index = change_index(end);
                this.change_index = Utils.Util.substr2double(this.states.info{change_index}, ':', 2);
            else
                warning(['no changeIndex found in trial ' ...
                         num2str(trial_index) ...
                         ' events! setting it to 1!'] ...
                )
                this.change_index = 1;
            end
        end

        function set_should_keep_index (this, trial_index) %TODO: functionality of this part has changed a bit. check it carefully.
            should_keep_index = Utils.Util.find_all(this.states.info, 'shouldKeep:');
            if ~isempty(should_keep_index)
                if ~isempty(strfind(this.states.info{should_keep_index(end)}, 'false'))
                    this.should_keep = 0;
                elseif ~isempty(strfind(this.states.info{should_keep_index(end)}, 'true'))
                    this.should_keep = 1;
                end
            elseif Utils.Util.do_exist(this.states.info, 'stimulus_waiter=>keepWait')
                this.should_keep = 1;
            elseif Utils.Util.do_exist(this.states.info, 'stimulus_waiter=>releaseWait')
                this.should_keep = 0;
            else
                warning(['no shouldKeepIndex found in trial ' ...
                         num2str(trial_index) ...
                         ' events! setting it to 0!'] ...
                )
                this.should_keep = 0;
            end
        end

        function set_good_amount_for_keep_or_release (this, experiment_properties) % TODO: functionality of this part has changed a bit. check carefully (the else case)
            if this.should_keep == 1
                this.set_good_amount(experiment_properties, 'keepRewardAmount:');
            elseif this.should_keep == 0
                this.set_good_amount(experiment_properties, 'releaseRewardAmount:');
            end
        end

        function set_good_amount (this, experiment_properties, which_amount)
            rewardAmountIndex = Utils.Util.find_all( ...
                                                experiment_properties.info, ...
                                                which_amount ...
            );
            this.good_amount = Utils.Util.substr2double( ...
                    experiment_properties.info{rewardAmountIndex}, ':', 2 ...
            );
        end

        function set_goodness_parameter (this) % TODO: check functionality in the end.
            keep_trig = Utils.Util.do_exist( ...
                                             this.states.info, ...
                                             'stimulus_waiter=>keepWait' ...
            );
            release_trig = Utils.Util.do_exist( ...
                                                this.states.info, ...
                                                'stimulus_waiter=>releaseWait' ...
            );
            no_error = this.errors_occured();
            reward_state = 1.*Utils.Util.do_exist( ...
                                                   this.states.info, ...
                                                   'reward=>reward_waiter' ...
            );
            this.is_good_trial = (keep_trig || release_trig) && (no_error);
            this.primary_goodness = reward_state && no_error && (this.good_amount <= this.reward_value);
        end

        function set_reaction_time_and_update_goodness (this, time_data)
            if this.primary_goodness && this.should_keep == 0
                temp_point_release = Utils.Util.find_all( ...
                                                          this.states.info, ...
                                                          'stimulus=>stimulus_waiter' ...
                );
                start_state_index  = Utils.Util.find_last( ...
                                                           this.states.info, ...
                                                           'barWait=>barWait_waiter' ...
                );
                if start_state_index < temp_point_release
                    try
                        release_point = find(this.bar.signal.bar( ...
                            this.bar.signal.time > this.states.time(temp_point_release) - this.startTime ...
                            )==0, 1);
                        release_point_time = this.bar.signal.time(release_point);
                        tempFromTime = Utils.Util.find_all( ...
                                                            this.states.info, ...
                                                            'releaseWait=>releaseWait_waiter' ...
                        );
                        this.reaction_time = release_point_time - (this.states.time(tempFromTime) - start_state_index);
                        this.update_goodness_respected_to_reaction_times(time_data);
                    catch
                        warning(['Bar not set to False after release in file: ' ...
                                 datestr(time_data) '!'] ...
                        )
                    end
                end
            end
        end

        function no_error = errors_occured (this)
            error_msg = Utils.Util.find_all(this.trial_events.info, 'ERROR MESSAGES');
            error_com = Utils.Util.find_all(this.trial_events.info, 'ERROR COMMANDS');
            no_error = isempty(error_msg) && isempty(error_com);
        end

        function update_goodness_respected_to_reaction_times (this, time_data)
            if isempty(this.reaction_time)
                this.primary_goodness = 0;
                warning(['Bar not set to False after release in file: ' ...
                         datestr(time_data) '!'] ...
                )
            elseif this.reaction_time < 0
                this.is_good_trial = 0;
                this.primary_goodness = 0;
                warning(['Bar Error Reaction time: ' ...
                         datestr(time_data) '!'] ...
                )
            end
        end

        function update_used_indices (this, new_indices)
            update_used_indices@Trials.Trial(this, new_indices);
        end

        function state_index = find_state_time (this, state_name)
            state_index = find_state_time@Trials.Trial(this, state_name);
        end
    end

end
