addpath('.\..\');
import CONFIG.*
import DAO.*

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
