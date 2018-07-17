classdef Experiment < Experiment_Data
    properties (Access = private)
        Postfix = ''
        ExperimentType = ''
        ExperimentSubject = ''
        ExperimentResearcherFirstName = ''
        ExperimentResearcherLastName = ''
        startDate
        Properties
        trials

        data_eye
    end

    methods (Access = public)
        function this = Experiment (
                postfix,
                exType,
                exSubject,
                exResearcherFN,
                exResearcherLN,
                startDate
        )
            this.Postfix = postfix;
            this.ExperimentType = exType;
            this.ExperimentSubject =  exSubject;
            this.ExperimentResearcherFirstName = exResearcherFN;
            this.ExperimentResearcherLastName = exResearcherLN;
            this.StartDate = startDate;
        end

        function set_data_eye (this, data_eye)
            set_data_eye@Experiment_Data(data_eye);
        end
    end

end
