%% Bar
% This object can be modeled using the *AnalysisData/Event* class, which the info
% shows behaivour of the monkey with the bar, and the *time* determines the time
% of that. But, it should have an extra property, *signal*, that is set with
% respet to the info recieved for bar on a specific moment.

    %% Set the Bar Signal
    % This function has the responsibility to set the signal property as described
    % above, with respet to the bar frequency sampling.
        function remakeBarSignal(this, trialEndTime, frequency)
            this.signal.time = floor(min(this.time):0.5:trialEndTime);
            this.signal.bar  = zeros(1, numel(this.signal.time))-1;

            for event_index = 1:numel(this.info)
                if strfind(this.info{event_index},'true')
                    barState = 1;
                elseif strfind(this.info{event_index},'false')
                    barState = 0;
                else
                    barState = -1;
                end
                this.signal.bar(this.signal.time > this.time(event_index)) = barState;
            end
        end
