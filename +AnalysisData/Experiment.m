classdef Experiment
    properties (Access = public)
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
        function this = Experiment ( ...
                postfix, ...
                exType, ...
                exSubject, ...
                exResearcherFN, ...
                exResearcherLN, ...
                startDate, ...
                data_eye ...
        )
            this.Postfix = postfix;
            this.ExperimentType = exType;
            this.ExperimentSubject =  exSubject;
            this.ExperimentResearcherFirstName = exResearcherFN;
            this.ExperimentResearcherLastName = exResearcherLN;
            this.startDate = startDate;
            this.data_eye = data_eye
        end
    end

end
