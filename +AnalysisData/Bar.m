classdef Bar < AnalysisData.Event
    properties (Access = public)
        signal
    end

    methods (Access = public)
        function this = Bar(info, time)
            this@AnalysisData.Event(info, time);
        end

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
    end
end
