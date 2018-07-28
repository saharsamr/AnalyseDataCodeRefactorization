%% Trials, The Main Part of Extracting Data

%% Main Data
% The properties that come in the following are the main data fileds that we are
% going to find out for each trial. These are the aim of whole procedure that we
% are discussing.
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
        isGood2
        isGood1
        clueIndex = []
        changeIndex = []
        shouldKeep = []
        goodAmount = 0
        eye
        reactionTime = []
        TTW
        stateTiming

    %% Extract Trial Data
    % This function just calls others to set the properties we mentioned above.
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
            this.set_id(trial_index, trials_start_indices, experiment_events);
            this.set_trial_events( ...
                                    experiment_events, ...
                                    trial_index, ...
                                    trials_start_indices ...
            );
            this.set_trial_number();
            this.set_times();
            bar_index = this.set_bar_info(); % TODO: maybe it needs name improvment.
            changed_index = this.set_changed_flag();
            TTW_indices = this.set_TTWs();
            kept_bar_index = Utils.Util.find_all(this.events_.info, 'keptBar:');
            trial_ID_index = Utils.Util.find_all(this.events_.info, 'TRIALID');
            this.set_trial_states( ...
                                   bar_index, ...
                                   changed_index, ...
                                   TTW_indices, ...
                                   kept_bar_index, ...
                                   trial_ID_index ...
            );
            this.set_errors();
            this.set_reward_value();
            this.set_cue_index(trial_index);
            this.set_change_index(trial_index);
            this.set_should_keep_index(trial_index);
            this.set_good_amount(experiment_properties);
            this.eye = AnalysisData.Eye(eye_time_samples, this.startTime, this.events_, data_eye);
            this.set_is_goods(); % TODO: not a proper name at all!
            this.set_reaction_time_and_update_is_good(experiment_start_date);
            this.set_state_timings(data_eye, start_time_eyelink);
        end

    %% Set Trial ID
    % Each trial has an id which is unique in the related experiment.
        function set_id ( ...
                          this, ...
                          trial_index, ...
                          trials_start_indices, ...
                          experiment_events ...
        )
            id_str = experiment_events.info{trials_start_indices(trial_index)};
            this.ID = Utils.Util.substr2double(id_str, ' ', 1);
        end

    %% Set the Related Events of Trial
    % We previously mentioned that each experiment has a set of events which
    % will show the detail of that by help of a *info* and *time* properties.
    % This function will seperate the portion of current trial from the whole
    % experiment events.
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

    %% Set Trial Number
    % Each trial has a trial number too.
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

    %% Set the Trial Times
    % The aim of this function is to set the time which the current trial starts
    % and the time it ends.
        function set_times (this)
            this.startTime = this.events_.time(1);
            this.endTime = this.events_.time(end);
        end

    %% Set the Information of Bar for the Current Trial
    % Monkey will get and release the bar several times during the trial. This
    % function by setting the bar property, help to keep track of bar status.
    % the BAR_SAMPLING_FREQ is the frequency which we track the bar.
        function bar_index = set_bar_info (this)
            bar_index = Utils.Util.find_all(this.events_.info, 'bar:');
            this.bar = AnalysisData.Bar( ...
                                        this.events_.info(bar_index), ...
                                        this.events_.time(bar_index) ...
            );
            this.bar.remakeBarSignal(this.endTime, CONFIG.Config.BAR_SAMPLING_FREQ);
        end


    %% Set the Changed Flag
    % TODO : need to explain the aim of changed flag.
        function changed_index = set_changed_flag (this)
            changed_index = Utils.Util.find_all(this.events_.info, 'changed:');
            if ~isempty(changed_index)
                if ~isempty(strfind(this.events_.info{changed_index(end)}, 'false'))
                    changed = 0;
                elseif ~isempty(strfind(this.events_.info{changed_index(end)}, 'true'))
                    changed = 1;
                end
                this.changed = changed;
            end
        end

    %% Set TTW (Time To Wait (TODO)) of Trial
    % This part is responsible for setting the the time is need to wait in each
    % state.
        function TTW_indices = set_TTWs (this) % TODO: no use of TTW class.
            TTW_indices   = Utils.Util.find_all(this.events_.info, 'TTW:');
            for TTW_index = TTW_indices
                TTW_str = this.events_.info{TTW_index};
                this.TTW.(TTW_str(1:strfind(TTW_str,':')-1)) = ...
                        Utils.Util.substr2double(TTW_str, ':', 2);
            end
        end

    %% Set States Transmition of Trial
    % The design of experiment has several states, which should transfer through
    % them in special orders, the function below set these states.
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

    %% Check for Errors May Occured In Trial
    % if any error occured, we can maintain that by *=>error* in states
    % transmitions and if the current trial states contain this, we can set the
    % error flag to true.
        function set_errors (this)
            start_state_index = Utils.Util.find_last( ...
                                                      this.states.info, ...
                                                      'barWait=>barWait_waiter' ...
            );
            error_index = Utils.Util.find_all(this.states.info, '=>error');
            this.Error = (~isempty(error_index)) && (error_index > start_state_index);
        end

    %% Set the Reward Value that Monkey Achieved
    % this function sepecify the amount of reward that monkey should receive.
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

    %% Set the Index Which Describe The Cue Situation (TODO)
    % Cue may appear in different positions on the screen, cue index shows us
    % this position at specific trials.
        function set_cue_index (this, trial_index)
           clueIndex = Utils.Util.find_all(this.states.info, 'cueIndex:');
           if ~isempty(clueIndex)
               clueIndex = clueIndex(end);
               this.clueIndex = Utils.Util.substr2double(this.states.info{clueIndex}, ':', 2);
           else
               warning(['no cueIndex found in trial ' ...
                        num2str(trial_index) ...
                        ' events! setting it to 1!'] ...
               )
               clueIndex = 1;
               this.clueIndex = clueIndex;
           end
        end

    %% Set the Index Which Describe Wether The Stimulus Direction Has Changed or Not (TODO)
    % Stimulus direction may change during the trial, and it differs in two
    % factors, first which stimulus direction has changed, and second, being
    % clockwise or vice-versa.
        function set_change_index (this, trial_index)
           changeIndex = Utils.Util.find_all(this.states.info, 'changeIndex:');
            if ~isempty(changeIndex)
                changeIndex = changeIndex(end);
                this.changeIndex = Utils.Util.substr2double(this.states.info{changeIndex}, ':', 2);
            else
                warning(['no change_index found in trial ' ...
                         num2str(trial_index) ...
                         ' events! setting it to 1!'] ...
                )
                changeIndex = 1;
                this.changeIndex = changeIndex;
            end
        end

    %% Set The Index Which Describe Wether the Monkey Should Keep the Bar or Not (TODO)
    % Depending on the trial parameters, monkey should keep or release the bar
    % at a time. this property is maintained in this function.
        function set_should_keep_index (this, trial_index)
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
                warning(['no shouldKeepIndex found in trial ' ...
                         num2str(trial_index) ...
                         ' events! setting it to 0!'] ...
                )
                this.shouldKeep = 0;
            end
        end

    %% Set the Reward Amount With Respect to Monkey Functionality
    % Depend on how good the monkey behaved, we should make decision for amount
    % of rewards it will recieved.
        function set_good_amount (this, experiment_properties)
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

    %% Set the Flag That Showes Wether This is a Good Trial or Not
    % Not all the trials has the standard parameters to participate in future
    % analysis. The functionality of this function is to determine that.
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

    %% Set Monkey's Reaction Time and Update Goodness of Trial
    % If monkey react properly in a trial, but not in specific range of time,
    % the goodness of trial will loss.
        function set_reaction_time_and_update_is_good (this, time_data)
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
                        this.update_is_good_respected_to_reaction_times(time_data);
                    catch
                        warning(['Bar not set to False after release in file: ' ...
                                 datestr(time_data) '!'] ...
                        )
                    end
                end
            end
        end

    %% Set the Timings of States Transmitions
    % The timings of states transmitions, and the times where monkey's eyes has
    % saccades is set here.
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

    %% Check If Any Error Occured
    % The help function for checking errors in the current trial. We used this
    % function in *set_is_goods* function, described above.
        function no_error = errors_occured (this)
            error_msg = Utils.Util.find_all(this.events_.info, 'ERROR MESSAGES');
            error_com = Utils.Util.find_all(this.events_.info, 'ERROR COMMANDS');
            no_error = isempty(error_msg) && isempty(error_com);
        end

    %% Update Goodness of Trial
    % The help function for updating the goodness of trial with respect to the
    % monkey's reaction time. This function has called in
    % *set_reaction_time_and_update_is_good* function, described above.
        function update_is_good_respected_to_reaction_times (this, time_data)
            if isempty(this.reactionTime)
                this.isGood1 = 0;
                warning(['Bar not set to False after release in file: ' ...
                         datestr(time_data) '!'] ...
                )
            elseif this.reactionTime < 0
                this.isGood2 = 0;
                this.isGood1 = 0;
                warning(['Bar Error Reaction time: ' ...
                         datestr(time_data) '!'] ...
                )
            end
        end
