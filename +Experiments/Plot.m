classdef Plot
    methods (Static)

        function raster_plot_and_psth_of_spikes (features, trials, feature_name, x_low_lim, x_high_lim, x_axis_partitions)
            f = figure(1);
            delta_y = 0.2;
            for i = 1:numel(features)
                selected_trials = trials([trials.(feature_name)] == i);
                subplot(2*numel(features),1,2*i-1);
                Experiments.Plot.plot_raster(selected_trials, i, delta_y);
                Utils.Plot.set_subplot_figure_design( ...
                                                x_low_lim, ...
                                                x_high_lim, ...
                                                0, ...
                                                (numel(selected_trials)+1)*delta_y, ...
                                                features(i) ...
                );
                subplot(2*numel(features),1,2*i);
                psth_ = Experiments.Plot.plot_psth (selected_trials, x_low_lim, x_high_lim, 10, 1);
                Utils.Plot.set_subplot_figure_design( ...
                                                x_low_lim, ...
                                                x_high_lim, ...
                                                0, ...
                                                max(psth_), ...
                                                [] ...
                );
            end
            Utils.Plot.set_plot_features( ...
                                    2*numel(features), ...
                                    1, ...
                                    2*numel(features), ...
                                    x_axis_partitions, ...
                                    'Time(ms)' ...
            );
        end

        function plot_raster (trials, subplot_index, delta_y)
            for j = 1:numel(trials)
                h = errorbar( ...
                    trials(j).spike_times - ...
                    trials(j).start_stimulus_time ...
                    , ...
                    j*delta_y* ...
                    ones(1, numel(trials(j).spike_times)) ...
                    , ...
                    0.1*ones(1, numel(trials(j).spike_times)), ...
                    'k' ...
                );
                h.CapSize = 0;
                h.LineStyle = 'none';
                hold on
            end
        end

        function final_psth = plot_psth (trials, x_low_lim, x_high_lim, bin_size_ms, x_delta_ms)
            num_of_samples = x_high_lim - x_low_lim + 1;
            psth_ = zeros(1, num_of_samples);
            for j = 1:numel(trials)
                for k = trials(j).spike_times - trials(j).start_stimulus_time
                    if (k > x_low_lim & k < x_high_lim)
                        psth_(floor(k-x_low_lim+1)) = psth_(floor(k-x_low_lim+1))+1;
                    end
                end
            end
            final_psth = zeros(1, num_of_samples);
            for k = 1:x_delta_ms:num_of_samples
                low_band = max(1, k-bin_size_ms/2);
                high_band = min (num_of_samples, k+bin_size_ms/2-1);
                x = sum(psth_(low_band:high_band));
                for i = k:k+x_delta_ms-1
                    final_psth(i) = x;
                end 
            end
            a = area(x_low_lim:x_high_lim, final_psth);
            a.FaceColor = [0, 0, 0];
        end

    end
end
