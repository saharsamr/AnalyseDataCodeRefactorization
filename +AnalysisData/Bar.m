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

            this.signal.bar = remakeBarSignal(this.info, this.time, this.signal.time);
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Event(this);
        end
    end
end
