%% The Event Class
% This class is going to be used *whenever* we have a property that should be
% describe in terms of matching *info* and *time* arrays to describe the behaiviour
% of our object or system.

%TODO: Add checking for same sizes later.

classdef Event < AnalysisData.Data
    properties (Access = public)
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
