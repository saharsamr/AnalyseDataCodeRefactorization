classdef TTWs < AnalysisData.Data & dynamicprops
    properties (Access = public)
    end

    methods (Access = public)
        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Data(this);
        end

        function add_value (this, TTW_str)
            property_name = TTW_str(1:strfind(TTW_str,':')-1);
            value = Utils.Util.substr2double(TTW_str, ':', 2);
            if ~isprop(this, property_name)
                addprop(this, property_name);
            end
            this.(property_name) = value;
        end
    end
end
