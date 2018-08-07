classdef Plot
    methods (Static)
    function set_subplot_figure_design (x_low_lim, x_high_lim, y_low_lim, y_high_lim, y_label)
        xlim([x_low_lim x_high_lim]);
        ylim([y_low_lim y_high_lim]);
        ylabel(y_label);
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        box off;
        hold off;
    end

    function set_plot_features (num_of_subplots, horizental_portion, vertical_portion, x_tick, x_label)
        hold on, ...
        subplot(num_of_subplots, horizental_portion, vertical_portion), ...
        set(gca,'xtick', x_tick), ...
        xlabel(x_label,'FontSize',13)
    end
    end
end
