classdef Trial
    properties (Access = private)
        ID
        events
        trialNumber
        startTime
        endTime
        bar
        changed
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
            this.events.info = experiment_events.info( ...
                                    trial_start_index:end_of_trial_index ...
                                    );
            this.events.time = experiment_events.time( ...
                                    trial_start_index:end_of_trial_index ...
                                    );
        end
end
