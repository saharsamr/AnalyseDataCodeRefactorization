classdef Config
    properties (Constant)
        % -----------------------------------------------------
        % LIST OF ACCEPTABLE TASK NAMES.
        % Attention
        % Hartley
        % StimulusVariables
        TASK_NAME = 'Hartley'
        % -----------------------------------------------------

        % -----------------------------------------------------
        % LIST OF ACCEPTEBLE STIMULUS VARIABLES, STRIMULUS_VARIABLES TASK ONLY.
        % orientation
        % size
        % spatial_frequency
        % phase
        % contrast
        STIMULUS_VARIABLE_NAME = 'size'
        % -----------------------------------------------------

        SUBJECT_NAME = 'Chiko'
        RESEARCHER_FIRST_NAME = 'Jafar'
        RESEARCHER_LAST_NAME = ''

        TIME_START = '2018-07-30 08:00:00'
        TIME_END = '2018-07-30 18:30:00'

        BAR_SAMPLING_FREQ = 2000

        % -----------------------------------------------------
        % EYELINK FILE DATA
        EYELINK_DATA_PATH = 'E:\\IPM\\EyeLink_DataExtraction\\RefactoredCodes\\Data\\Hartley\\'
        EYELINK_DATA_POSTFIX = 'RF'
        % -----------------------------------------------------

        % -----------------------------------------------------
        % BLACKROCK FILE DATA
        BLACKROCK_DATA_PATH = 'E:\\IPM\\EyeLink_DataExtraction\\RefactoredCodes\\Data\\Hartley\\'
        BLACKROCK_DATA_POSTFIX = 'RF'
        % -----------------------------------------------------
    end
end
