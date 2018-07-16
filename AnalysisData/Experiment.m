classdef Experiment
    properties (Access = private)
        Postfix = ''
        ExperimentType = ''
        ExperimentSubject = ''
        ExperimentResearcherFirstName = ''
        ExperimentResearcherLastName = ''
        StartDate
        Properties
        Trials
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
    end

end
