classdef Bar < Event
    properties (Access = private)
        Signal
    end

    methods (Access = public)
        function this = Bar(info, time)
            this@Event(info, time)
        end
    end
end
