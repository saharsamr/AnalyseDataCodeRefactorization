classdef Event
    properties (Access = private)
        info = [];
        time = [];
    end

    methods (Access = public)
        function this = Event (info, time)
            this.info = info;
            this.time = time;
        end
    end
end
