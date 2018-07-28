%% Monkey's Eye Data
% We should keep track of monkey's eye features to determine its attention and
% reactions. This class is responsible for that, where we can have the position
% of its eye and their saccade times, etc, all together.

%% Eye Properties
% These properties shows the features of eyes we care about in this task.
    properties (Access = private)
        time = [];
        pa = []; %TODO: ask to find a better name.
        posx = [];
        posy = [];
        errorVal
        saccadeTime = [];

    %% Setting Eye's Features
    % The construtor of this class, is going to extract and set the features are
    % available below. But the saccade times are set in next function.
        function this = Eye (eye_time_samples, startTime, trial_events, data_eye)
            eye_sample_cut_indices = eye_time_samples >= startTime ...
                                    & ...
                                  eye_time_samples <= trial_events.time(end) ...
            ;
            this.time = eye_time_samples(eye_sample_cut_indices);
            this.pa = data_eye.Samples.pa(eye_sample_cut_indices, 2);
            this.posx = data_eye.Samples.posX(eye_sample_cut_indices);
            this.posy = data_eye.Samples.posY(eye_sample_cut_indices);
            this.errorVal = -32768; % TODO

            this.pa(this.pa == this.errorVal) = NaN;
            this.posx(this.posx == this.errorVal) = NaN;
            this.posy(this.posy == this.errorVal) = NaN;
            this.saccadeTime = [];
        end

    %% Set Ssaccade Times
    % This function, as we mentioned previous, extracted the saccade times during
    % a special trial for furture analysis.
        function set_saccade_time (this, data_eye, state_timings, start_time_eyelink)
            counter = 0;
            endSaccads   = data_eye.Events.Esacc.end   - start_time_eyelink;
            startSaccads = data_eye.Events.Esacc.start - start_time_eyelink;
            for saccad_index = 1:numel(endSaccads)
                if endSaccads(saccad_index) > state_timings.trigger
                    cut = find(this.time < endSaccads(saccad_index) & this.time > startSaccads(saccad_index));
                    if ~isempty(cut)
                        counter = counter + 1;
                        this.saccadeTime{counter} = this.time(cut);
                    end
                end
            end
        end
