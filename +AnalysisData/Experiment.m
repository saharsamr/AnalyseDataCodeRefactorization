classdef Experiment
    properties (Access = public)
        Postfix = ''
        ExperimentType = ''
        ExperimentSubject = ''
        ExperimentResearcherFirstName = ''
        ExperimentResearcherLastName = ''
        startDate
        Properties
        trials = []
        data_eye
        events
        start_time_eyelink % TODO: some features like this, does not need to store in the final structure.
        eye_time_samples % TODO: same TODO above.
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
            this.startDate = startDate; %TODO: heck that this parameter is set correctly.
            this.data_eye = data_eye
        end

        function extract_experiment_data (this)
            events = data_eye.Events.Messages;
            this.calibrate_times();
            trials_start_indices = find(cellfun(@(x) ~isempty(x), ...
                                 strfind(this.events.info, 'trialNumber')) ...
                                );
            this.set_experiment_properties(trial_start_indices); % TODO: find a way to not pass this object.
            for trial_index = 1:numel(trial_start_indices)
                trials[trial_index] = AnalysisData.Trial();
                trials[trial_index].extract_trial_data( ...
                                                trial_index, ...
                                                this.events, ...
                                                trials_start_indices ...
                                                );
        end
    end

    methods (Access = private)
        function calibrate_times (this)
            this.start_time_eyelink = this.events.time( ...
                    find(strcmp(this.events.info, 'trialNumber: 1'),1) ...
            );
            this.events.time = this.events.time - start_time_eyelink;
            this.eye_time_samples = this.data_eye.Samples.time - ...
                                    this.start_time_eyelink;
            % TODO: maybe we can put saccade calibration here too.
        end

        function set_experiment_properties (this, trial_start_indices)
            this.Properties.info = this.events.info(1:trial_start_indices(1)-1);
            this.Properties.time = this.events.time(1:trial_start_indices(1)-1);
        end
    end

end
