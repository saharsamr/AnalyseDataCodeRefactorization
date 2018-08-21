% close all;
clear all;

load('lfp.mat');

continuous_data = NS5.Data(1,:);
continuous_data_time = NS5.time_;

figure(1);
for i = 1:numel(Trials)-1
    start_stimuli_time = Trials(i).fixation_time_PHDI;
    end_stimuli_time = Trials(i).End_StimulusTimePHDI;
    Trials(i).continuous_data.info = continuous_data(continuous_data_time > start_stimuli_time & continuous_data_time < end_stimuli_time);
    Trials(i).continuous_data.time = continuous_data_time(continuous_data_time > start_stimuli_time & continuous_data_time < end_stimuli_time) - Trials(i).Time_Onset_PHDI;

    cutoff_freq=250;
    filter_order=2;
    [b1,a1]=butter(2, filter_order*cutoff_freq/7500, 'low');
    filtered_data = filter(b1, a1, Trials(i).continuous_data.info);
    plot(Trials(i).continuous_data.time, filtered_data, 'b');

    hold on;
end
