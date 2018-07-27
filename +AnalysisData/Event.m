%============================================
%   Event Class:
%       Some Repeatable data, such as Stetes, Bar, Event itsef, are using this class.
%============================================

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

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end
end
