classdef Trial < handle
    properties (Access = public)
        ID
        events_
        trialNumber = []
        startTime
        endTime
        bar
        changed = []
        states
        Error
        rewardValue
        isGood2 % TODO: Ask to find a better name
        isGood1
        clueIndex = []
        changeIndex = []
        shouldKeep = []
        goodAmount = 0
        eye
        reactionTime = []
        TTW
        stateTiming
    end

    methods (Access = public)
        function extract_trial_data ( ...
                                this, ...
                                trial_index, ...
                                experiment_events, ...
                                experiment_properties, ...
                                trials_start_indices, ...
                                eye_time_samples, ...
                                data_eye, ...
                                start_time_eyelink ...
        )
            this.set_id(trial_index, trials_start_indices, experiment_events);
            % disp('a');
            this.set_trial_events( ...
                                    experiment_events, ...
                                    trial_index, ...
                                    trials_start_indices ...
            );
            % disp('b');
            this.set_trial_number();
            % disp('c');
            this.set_times();
            % disp('d');
            bar_index = this.set_bar_info(); % TODO: maybe it needs name improvment.
            % disp('e');
            changed_index = this.set_changed_flag();
            % disp('f');
            TTW_indices = this.set_TTWs();
            % disp('g');
            kept_bar_index = Utils.Util.find_all(this.events_.info, 'keptBar:');
            % disp('h');
            trial_ID_index = Utils.Util.find_all(this.events_.info, 'TRIALID');
            % disp('i');
            this.set_trial_states( ...
                                   bar_index, ...
                                   changed_index, ...
                                   TTW_indices, ...
                                   kept_bar_index, ...
                                   trial_ID_index ...
            );
            % disp('j');
            this.set_errors();
            % disp('k');
            this.set_reward_value();
            % disp('l');
            this.set_cue_index(trial_index);
            % disp('m');
            this.set_change_index(trial_index);
            % disp('n');
            this.set_should_keep_index(trial_index);
            % disp('o');
            this.set_good_amount(experiment_properties);
            % disp('p');
            this.eye = AnalysisData.Eye(eye_time_samples, this.startTime, this.events_, data_eye);
            % disp('q');
            this.set_is_goods(); % TODO: not a proper name at all!
            % disp('r');
            this.set_reaction_time_and_update_is_good();
            % disp('s');
            this.set_state_timings(data_eye, start_time_eyelink);
            % disp('t');
        end
    end

    methods (Access = private)
        function set_id ( ...
                          this, ...
                          trial_index, ...
                          trials_start_indices, ...
                          experiment_events ...
        )
            id_str = experiment_events.info{trials_start_indices(trial_index)};
            this.ID = Utils.Util.substr2double(id_str, ' ', 1);
        end

        function set_trial_events ( ...
                                    this, ...
                                    experiment_events, ...
                                    trial_index, ...
                                    trials_start_indices ...
        )
            start_index = trials_start_indices(trial_index);
            if trial_index ~= numel(trials_start_indices)
                this.events_ = AnalysisData.Event( ...
                                experiment_events.info(start_index:trials_start_indices(trial_index+1)-1), ...
                                experiment_events.time(start_index:trials_start_indices(trial_index+1)-1) ...
                );
            else
                this.events_ = AnalysisData.Event( ...
                                experiment_events.info(start_index:end), ...
                                experiment_events.time(start_index:end) ...
                );
            end
        end

        function set_trial_number (this)
            trial_num_index = Utils.Util.find_all( ...
                                                   this.events_.info, ...
                                                   'trialNumber:' ...
            );
            if ~isempty(trial_num_index)
                trial_num_str = this.events_.info{trial_num_index};
                this.trialNumber = Utils.Util.substr2double(trial_num_str, ' ', 1);
            end
        end

        function set_times (this)
            this.startTime = this.events_.time(1);
            % disp(this.startTime);
            this.endTime = this.events_.time(end);
            % disp('---');
        end

        function bar_index = set_bar_info (this)
            bar_index = Utils.Util.find_all(this.events_.info, 'bar:');
            this.bar = AnalysisData.Bar( ...
                                        this.events_.info(bar_index), ...
                                        this.events_.time(bar_index) ...
            );
            this.bar.remakeBarSignal(this.endTime, CONFIG.Config.BAR_SAMPLING_FREQ);
        end


        function changed_index = set_changed_flag (this)
            changed_index = Utils.Util.find_all(this.events_.info, 'changed:');
            if ~isempty(changed_index)
                if ~isempty(strfind(this.events_.info{changed_index(end)}, 'false'))
                    changed = 0;
                elseif ~isempty(strfind(this.events_.info{changed_index(end)}, 'true'))
                    changed = 1;
                end
            end
        end

        function TTW_indices = set_TTWs (this) % TODO: no use of TTW class.
            TTW_indices   = Utils.Util.find_all(this.events_.info, 'TTW:');
            for TTW_index = TTW_indices
                TTW_str = this.events_.info{TTW_index};
                this.TTW.(TTW_str(1:strfind(TTW_str,':')-1)) = ...
                        Utils.Util.substr2double(TTW_str, ':', 2);
            end
        end

        function set_trial_states ( ...
                                    this, ...
                                    bar_index, ...
                                    changed_index, ...
                                    TTW_indices, ...
                                    kept_bar_index, ...
                                    trial_ID_index ...
        )
            unused_indices = union( ...
                                    union( ...
                                           union( ...
                                                  union( ...
                                                         bar_index, ...
                                                         changed_index ...
                                                  ), kept_bar_index ...
                                            ), TTW_indices ...
                                    ), trial_ID_index ...
                             );
            this.states = AnalysisData.Event( ...
                        this.events_.info(setdiff(1:numel(this.events_.info), ...
                                            unused_indices)), ...
                        this.events_.time(setdiff(1:numel(this.events_.info), ...
                                            unused_indices)) ...
            );
        end

        function set_errors (this)
            start_state_index = Utils.Util.find_last( ...
                                                      this.states.info, ...
                                                      'barWait=>barWait_waiter' ...
            );
            error_index = Utils.Util.find_all(this.states.info, '=>error');
            this.Error = (~isempty(error_index)) && (error_index > start_state_index);
        end

        function set_reward_value (this)
            reward_index = Utils.Util.find_all(this.states.info, 'reward:');
            if this.Error
                this.rewardValue = -1;
            elseif isempty(reward_index)
                this.rewardValue = -2;
            else
                this.rewardValue = Utils.Util.substr2double(this.states.info{reward_index}, ':', 2)/0.2;
            end
        end

        function set_cue_index (this, trial_index)
           clueIndex = Utils.Util.find_all(this.states.info, 'cueIndex:');
           if ~isempty(clueIndex)
               clueIndex = clueIndex(end);
               this.clueIndex = Utils.Util.substr2double(this.states.info{clueIndex}, ':', 2);
           else
               % warning(['no cueIndex found in trial ' ...
               %          num2str(trial_index) ...
               %          ' events! setting it to 1!'] ...
               % )
               clueIndex = 1;
               this.clueIndex = clueIndex;
           end
        end

        function set_change_index (this, trial_index)
           changeIndex = Utils.Util.find_all(this.states.info, 'changeIndex:');
            if ~isempty(changeIndex)
                changeIndex = changeIndex(end);
                this.changeIndex = Utils.Util.substr2double(this.states.info{changeIndex}, ':', 2);
            else
                % warning(['no change_index found in trial ' ...
                %          num2str(trial_index) ...
                %          ' events! setting it to 1!'] ...
                % )
                changeIndex = 1;
                this.changeIndex = changeIndex;
            end
        end

        function set_should_keep_index (this, trial_index) %TODO: functionality of this part has changed a bit. check it carefully.
            shouldKeepIndex = Utils.Util.find_all(this.states.info, 'shouldKeep:');
            if ~isempty(shouldKeepIndex)
                if ~isempty(strfind(this.states.info{shouldKeepIndex(end)}, 'false'))
                    this.shouldKeep = 0;
                elseif ~isempty(strfind(this.states.info{shouldKeepIndex(end)}, 'true'))
                    this.shouldKeep = 1;
                end
            elseif Utils.Util.do_exist(this.states.info, 'stimulus_waiter=>keepWait') % TODO: does it necessary to handle this part? Do the eyelink data always have the shouldkeep data to avoid this part?
                this.shouldKeep = 1;
            elseif Utils.Util.do_exist(this.states.info, 'stimulus_waiter=>releaseWait')
                this.shouldKeep = 0;
            else
                % warning(['no shouldKeepIndex found in trial ' ...
                %          num2str(trial_index) ...
                %          ' events! setting it to 0!'] ...
                % )
                this.shouldKeep = 0;
            end
        end

        function set_good_amount (this, experiment_properties) % TODO: functionality of this part has changed a bit. check carefully (the else case)
            if this.shouldKeep == 1
                rewardAmountIndex = Utils.Util.find_all( ...
                                                    experiment_properties.info, ...
                                                    'keepRewardAmount:' ...
                );
            elseif this.shouldKeep == 0
                rewardAmountIndex = Utils.Util.find_all( ...
                                                    experiment_properties.info, ...
                                                    'releaseRewardAmount:' ...
                );
            end
            this.goodAmount = Utils.Util.substr2double(experiment_properties.info{rewardAmountIndex}, ':', 2);
        end

        function set_is_goods (this) % TODO: chek functionality in the end.
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
            this.isGood2 = (keep_trig || release_trig) && (no_error);
            this.isGood1 = reward_state && no_error && (this.goodAmount <= this.rewardValue);
        end

        function set_reaction_time_and_update_is_good (this)
            if this.isGood1 && this.shouldKeep == 0
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
                        this.reactionTime = release_point_time - (this.states.time(tempFromTime) - start_state_index);
                        this.update_is_good_respected_to_reaction_times();
                    catch
                        % warning(['Bar not set to False after release in file: ' ...
                        %          datestr(time_data) '!'] ...
                        % )
                    end
                end
            end
        end

        function set_state_timings (this, data_eye, start_time_eyelink)
            if this.isGood2
                this.stateTiming = AnalysisData.StatesTimings(this.states);
                this.eye.set_saccade_time( ...
                                           data_eye, ...
                                           this.stateTiming, ...
                                           start_time_eyelink ...
                );
            end
        end

        function no_error = errors_occured (this)
            error_msg = Utils.Util.find_all(this.events_.info, 'ERROR MESSAGES');
            error_com = Utils.Util.find_all(this.events_.info, 'ERROR COMMANDS');
            no_error = isempty(error_msg) && isempty(error_com);
        end

        function update_is_good_respected_to_reaction_times (this)
            if isempty(this.reactionTime)
                this.isGood1 = 0;
                % warning(['Bar not set to False after release in file: ' ...
                %          datestr(time_data) '!'] ...
                % )
            elseif this.reactionTime < 0
                this.isGood2 = 0;
                this.isGood1 = 0;
                % warning(['Bar Error Reaction time: ' ...
                %          datestr(time_data) '!'] ...
                % )
            end
        end
    end

end
