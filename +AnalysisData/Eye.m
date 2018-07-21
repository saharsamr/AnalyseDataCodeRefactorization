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

            % TODO: find a way for passing better the data_eye.
        end

        function set_saccade_time (this, data_eye, state_timings, start_time_eyelink)
            counter = 0;
            endSaccads   = data_eye.Events.Esacc.end   - start_time_eyelink;
            startSaccads = data_eye.Events.Esacc.start - start_time_eyelink;
            for saccad_index = 1:numel(endSaccads)
                if endSaccads(saccad_index) > state_timings.trigger
                    cut = find(this.eye.time < endSaccads(saccad_index) & this.time > startSaccads(saccad_index));
                    if ~isempty(cut)
                        counter = counter + 1;
                        this.saccadeTime{counter} = this.time(cut);
                    end
                end
            end
        end 
    end
end
