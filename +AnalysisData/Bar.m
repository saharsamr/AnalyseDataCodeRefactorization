classdef Bar < Event
    properties (Access = public)
        signal
    end

    methods (Access = public)
        function this = Bar(info, time)
            this@Event(info, time)
        end
    end
end
