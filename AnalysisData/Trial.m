classdef Trial
    properties (Access = private)
        ID
        Events
        TrialNumber
        StartTime
        EndTime
        Bar
        Changed
        States
        Error
        RewardValue
        IsGood2 % TODO: Ask to find a better name
        IsGood1
        ClueIndex
        ChangeIndex
        ShouldKeep
        Eye
        ReactionTime
        TTW
        StateTiming
    end
end
