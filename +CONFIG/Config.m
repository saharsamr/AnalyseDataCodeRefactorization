%% Configs
% This class, with its *constant* properties, is where we set the common variables
% mentioned previously among different experiments we try to maintain theis data.

classdef Config
    properties (Constant)
        SUBJECT_NAME = 'Subject Name'
        TASK_NAME = 'Task Name'
        RESEARCHER_FIRST_NAME = 'Researcher First Name'
        RESEARCHER_LAST_NAME = 'Researcher Last Name'
        TIME_START = 'Lower Bound of Experiments Times'
        TIME_END = 'Upper Bound of Experiments Times'
        BAR_SAMPLING_FREQ = The Frequency of Bar Sampling
        CLOSE_FIG_FLAG = 0 %TODO
        DATA_PATH = 'Path to Retreive .edf files'
    end
end
