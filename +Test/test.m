%% Functionality of the Code Procedure
% This code is written to extract received data from
% eyelink for each experiment of task "Attention"
% and finally save the proper data in a .mat file
% to use this data for Analysing the result of
% experiments.

%% Setting Configs and Run the DAO
% The whole procedure starts by *test.m* file
% located in *Test* package, which reads the
% configs from *CONFIG/Config.m* file and then
% create a *DAO* (Data Access Object) with the
% maintained configs to extract the data of
% each experiments.

addpath('.\..\');
import CONFIG.*
import DAO.*

warning('off', 'MATLAB:structOnObject');

dao = DAO.DAO ( ...
            CONFIG.Config.SUBJECT_NAME, ...
            CONFIG.Config.TASK_NAME, ...
            CONFIG.Config.RESEARCHER_FIRST_NAME, ...
            CONFIG.Config.RESEARCHER_LAST_NAME, ...
            CONFIG.Config.TIME_START, ...
            CONFIG.Config.TIME_END, ...
            CONFIG.Config.BAR_SAMPLING_FREQ, ...
            CONFIG.Config.CLOSE_FIG_FLAG, ...
            CONFIG.Config.DATA_PATH ...
        );

dao.extract_experiments_data();

warning('on', 'MATLAB:structOnObject');
