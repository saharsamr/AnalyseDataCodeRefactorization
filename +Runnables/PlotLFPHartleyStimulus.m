close all;
clear all;
clc;

load('/home/a1/sahar/IPM/PhotoDiod/ori_lfp.mat');

continueous_data = NS5.Data(1,:);
continueous_data_time = NS5.time_;

Trials = Trials(1:end-1);

disp(string(Experiments.StimulusVariables.get_type()));
features_indx = Utils.Util.find_last(properties, string(Experiments.StimulusVariables.get_type()));
features_str =properties{features_indx};
features = eval(features_str(strfind(features_str, ':')+2:end));

Experiments.Plot.plot_lfp_hartley_stimulus_features( ...
                    continueous_data, ...
                    continueous_data_time, ...
                    features, ...
                    Trials, ...
                    'orientation_number', ...
                    -500, ...
                    500, ...
                    10000*[-0.05 -0.025 0 0.025 0.05] ...
);
