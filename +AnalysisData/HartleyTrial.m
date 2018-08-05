classdef HartleyTrial < AnalysisData.Trial
    properties (Access = public)
        stimulus_data
        stimulus_names
    end

    methods (Access = public)
        function extract_trial_data ( ...
                                this, ...
                                trial_index, ...
                                experiment_events, ...
                                experiment_properties, ...
                                experiment_start_date, ...
                                trials_start_indices, ...
                                eye_time_samples, ...
                                data_eye, ...
                                start_time_eyelink ...
        )
            extract_trial_data@AnalysisData.Trial( ...
                                    this, ...
                                    trial_index, ...
                                    experiment_events, ...
                                    experiment_properties, ...
                                    experiment_start_date, ...
                                    trials_start_indices, ...
                                    eye_time_samples, ...
                                    data_eye, ...
                                    start_time_eyelink ...
            );
            display_indices = Utils.Util.find_all(this.trial_events.info, 'display');
            this.update_used_indices(display_indices);
            tracker_indices = Utils.Util.find_all(this.trial_events.info, 'tracker');
            this.update_used_indices(tracker_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'keyboard');
            this.update_used_indices(keyboard_indices);
            keyboard_indices = Utils.Util.find_all(this.trial_events.info, 'TRIALID');
            this.update_used_indices(keyboard_indices);
            % this.set_stimulus_data();
            this.set_stimulus_name();
        end

        function set_states_of_trail (this, trial_index)
            set_states_of_trail@AnalysisData.Trial(this);
        end

        function set_goodness_and_reward_of_trial (this, properties, start_date)
            set_goodness_and_reward_of_trial@AnalysisData.Trial(this);
            this.is_good_trial = ~this.error;
        end

        function convert_properties_to_struct (this)
            convert_properties_to_struct@AnalysisData.Trial(this);
        end
    end

    methods (Access = protected)
        % function set_stimulus_data (this)
        %     stimulus_data_index = Utils.Util.find_all(this.trial_events.info, 'stimulusData');
        %     disp('-----------');
        %     disp(stimulus_data_index)
        %     if(~isempty(stimulus_data_index))
        %         stimulus_data_str = this.trial_events.info{stimulus_data_index};
        %         this.stimulus_data = stimulus_data_str;
        %     end
        %     this.update_used_indices(stimulus_data_index);
        % end

        function set_stimulus_name (this)
            stimulus_name_index = Utils.Util.find_all(this.trial_events.info, 'stimulusName');
            if(~isempty(stimulus_name_index))
                % for i = 1:numel(stimulus_name_index)
                %     stimulus_name_str = this.trial_events.info{stimulus_name_index(i)};
                %     this.stimulus_names(i) = stimulus_name_str(strfind(stimulus_name_str, ':')+3:end-1);
                % end
                this.stimulus_names = AnalysisData.Event ( ...
                                                            this.trial_events.info(stimulus_name_index), ...
                                                            this.trial_events.time(stimulus_name_index) ...
                );
            end
            this.update_used_indices(stimulus_name_index);
        end
    end
end
