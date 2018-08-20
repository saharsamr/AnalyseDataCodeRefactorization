classdef StimulusVariables
    enumeration
        stimulusSizes
        stimulusSpatialFrequencies
        stimulusContrasts
        stimulusOrientations
        stimulusPhases
    end

    methods (Static)
        function stimulus_variable = get_type ()
            if (CONFIG.Config.STIMULUS_VARIABLE_NAME == 'size')
                stimulus_variable = Experiments.StimulusVariables.stimulusSizes;
            elseif (CONFIG.Config.STIMULUS_VARIABLE_NAME == 'spatial_frequency')
                stimulus_variable = Experiments.StimulusVariables.stimulusSpatialFrequencies;
            elseif (CONFIG.Config.STIMULUS_VARIABLE_NAME == 'orientation')
                stimulus_variable = Experiments.StimulusVariables.stimulusOrientations;
            elseif (CONFIG.Config.STIMULUS_VARIABLE_NAME == 'contrast')
                stimulus_variable = Experiments.StimulusVariables.stimulusContrasts;
            elseif (CONFIG.Config.STIMULUS_VARIABLE_NAME == 'phase')
                stimulus_variable = Experiments.StimulusVariables.stimulusPhases;
            end
        end
    end
end
