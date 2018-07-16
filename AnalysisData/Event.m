%============================================
%   Event Class:
%       Some Repeatable data, such as Stetes, Bar, Event itsef, are using this class.
%============================================

classdef Event
    properties (Access = private)
        Info = [];
        Time = [];
    end

    methods (Access = public)
        function this = Event (info, time)
            this.Info = info;
            this.Time = time;
        end
    end
end
