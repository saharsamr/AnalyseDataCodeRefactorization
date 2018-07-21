classdef Experiment_Data < handle
    properties (Access = public)
        data
    end

    methods (Access = public)
        function this = Experiment_Data(data)
            this.data = data;
        end

        function set_data_eye (this, data)
            this.data = data;
        end
    end
end
