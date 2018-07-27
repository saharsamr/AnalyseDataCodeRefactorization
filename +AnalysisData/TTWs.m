% TODO: All possible TTWs are set?

classdef TTW < AnalysisData.Data
    properties (Access = private)
        realfixationTTW
        realcueTTW
        realnothingTTW
        realstimulusTTW
        realreleaseWaitTTW
        realchangeStimulusTTW
        realrewardTTW
    end

    methods (Access = public)
        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end
    end 
end
