classdef Trial
    properties (Access = private)
        ID
        events
        trialNumber
        startTime
        endTime
        bar
        changed
        states
        Error
        rewardValue
        isGood2 % TODO: Ask to find a better name
        isGood1
        clueIndex
        changeIndex
        shouldKeep
        goodAmount
        eye
        reactionTime
        TTW
        stateTiming
    end
end
