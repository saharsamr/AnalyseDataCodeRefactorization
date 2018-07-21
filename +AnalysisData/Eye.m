classdef Eye
    properties (Access = private)
        time = [];
        pa = []; %TODO: ask to find a better name.
        posx = [];
        posy = [];
        errorVal
        saccadeTime = [];
    end

    methods (Access = public)
        function this = Eye (trial, data_eye)
            eye_sample_cut_indices = trial.eye_time_samples >= trial.startTime ...
                                    & ...
                                  trial.eye_time_samples <= trial.events.time(end) ...
            ;
            this.time     = trial.eye_time_samples(eye_sample_cut_indices);
            this.pa       = data_eye.Samples.pa(eye_sample_cut_indices, 2); % ------------- pa chie?
            this.posx     = data_eye.Samples.posX(eye_sample_cut_indices);
            this.posy     = data_eye.Samples.posY(eye_sample_cut_indices);
            this.errorVal = -32768; % ------------- ??

            this.pa(this.pa == this.errorVal) = NaN;
            this.posx(this.posx == this.errorVal) = NaN;
            this.posy(this.posy == this.errorVal) = NaN;
            this.saccadeTime = [];

        endSaccads   = data_eye.Events.Esacc.end   - start_time_eyelink; % TODO: start time eyelink is not available here.
            startSaccads = data_eye.Events.Esacc.start - start_time_eyelink;

            % TODO: find a way for passing better the data_eye.
end
