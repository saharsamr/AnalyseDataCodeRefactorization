classdef Trial
    properties (Access = private)
        ID
        events
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
        clueIndex
        changeIndex
        shouldKeep
        goodAmount
        eye
        reactionTime
        TTW
        stateTiming
    end

    methods (Access = public)
        function extract_trial_data ( ...
                                this, ...
                                trial_index, ...
                                experiment_events, ...
                                trials_start_indices ...
                            )
            this.set_id(trial_index, trials_start_indices, experiment_events);
            this.set_trial_events(experiment_events, trial_index, trial_start_indices);
            this.set_trial_number();
            this.set_times();
            this.set_bar_info(); % TODO: maybe it needs name improvment.
            this.set_changed_flag();
        end
    end

    methods (Access = private)
        function set_id (this, trial_index, trials_start_indices, experiment_events)
            id_str = experiment_events.info{trials_start_indices(trial_index)};
            this.ID = str2double(id_str(strfind(id_str, ' ')+1:end));
        end

        function set_trial_events ( ...
                                    this, ...
                                    experiment_events, ...
                                    trial_index, ...
                                    trial_start_indices ...
                                  )
            trial_start_index = trials_start_indices(trial_index);
            end_of_trial_index;
            if trial_index ~= numel(trials_start_indices)
                end_of_trial_index = trials_start_indices(trial_index+1)-1;
            else
                end_of_trial_index = numel(trial_start_indices);
            end
            this.events = AnalysisData.Event( ...
                            experiment_events.info(trial_start_index:end_of_trial_index), ...
                            experiment_events.time(trial_start_index:end_of_trial_index) ...
                         );
        end

        function set_trial_number (this)
            trial_num_index = find(cellfun(@(x) ~isempty(x), ...
                                   strfind(this.events.info, 'trialNumber:')) ...
                                  );
            if ~isempty(trial_num_index)
                trial_num_str = this.events.info{trial_num_index};
                this.trialNumber = str2double(trial_num_str(strfind(trial_num_str, ' ')+1:end));
            end
        end

        function set_times (this)
            this.startTime = this.events.time(1);
            this.startTime = this.events.time(end);
        end

        function set_bar_info (this)
            bar_index = find(cellfun(@(x) ~isempty(x), ...
                                strfind(this.events.info, 'bar:')) ...
                            );
            this.bar = AnalysisData.Bar( ...
                            this.events.info(bar_index), ...
                            this.events.time(bar_index) ...
                       );
            % this.bar = remakeBarSignal(this.bar, this.endTime, this.bar_sampling_frequency);
            % TODO: function above, and bar_sampling_frequency.
        end

        function set_changed_flag (this)
            changed_index = find(cellfun(@(x) ~isempty(x), ...
                                 strfind(this.events.info, 'changed:')) ...
                                );
            if ~isempty(changed_index) % ------------- in dare chikar mikone?
                if ~isempty(strfind(this.events.info{changed_index(end)}, 'false'))
                    changed = 0;
                elseif  ~isempty(strfind(this.events.info{changed_index(end)}, 'true'))
                    changed = 1;
                end
                % this.changed = str2double(this.events.info{changed_index(1)}(end));
                this.changed = changed; % ------------- chera? hatta age varede ina nashe bug ham mikhore.
            end
        end


end
