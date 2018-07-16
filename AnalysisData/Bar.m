classdef Bar < Event
    properties (Access = private)
        signal
    end

    methods (Access = public)
        function this = Bar(info, time)
            this@Event(info, time)
        end
    end
end
