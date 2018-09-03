addpath(genpath('toolbox'));

clear all
close all
clc

warning('off', 'MATLAB:structOnObject');

dao = DAO.DAO ( ...
            CONFIG.Config.SUBJECT_NAME, ...
            CONFIG.Config.TASK_NAME, ...
            CONFIG.Config.RESEARCHER_FIRST_NAME, ...
            CONFIG.Config.RESEARCHER_LAST_NAME, ...
            CONFIG.Config.TIME_START, ...
            CONFIG.Config.TIME_END, ...
            CONFIG.Config.BAR_SAMPLING_FREQ, ...
            CONFIG.Config.EYELINK_DATA_PATH ...
        );

dao.extract_experiments_data();

warning('on', 'MATLAB:structOnObject');