% Author: Rocky Mazorow
% Date: 12/3/2023

function MeanPerc = setNanBlock(MeanPerc, b, subID, group, session, block)
    MeanPerc(b).SubID = subID;
    MeanPerc(b).Group = group;
    MeanPerc(b).Session = session;
    MeanPerc(b).Block = block;
    MeanPerc(b).BlockType = block(1);
    MeanPerc(b).BlockDim = NaN;
    MeanPerc(b).NumTrials = NaN;
    MeanPerc(b).TrialTime = NaN;
    MeanPerc(b).xError = NaN;
    MeanPerc(b).yError = NaN;
    MeanPerc(b).zError = NaN;
    MeanPerc(b).TotalError = NaN;
    MeanPerc(b).TrialError = NaN;
    MeanPerc(b).StabilVariat = NaN;
    MeanPerc(b).xSpeed = NaN;
    MeanPerc(b).ySpeed = NaN;
    MeanPerc(b).zSpeed = NaN;
    MeanPerc(b).TotalSpeed = NaN;
    MeanPerc(b).TrialSpeed = NaN;
    MeanPerc(b).xRatio = NaN;
    MeanPerc(b).yRatio = NaN;
    MeanPerc(b).zRatio = NaN;
    MeanPerc(b).TotalRatio = NaN;
    MeanPerc(b).TrialRatio = NaN;
    MeanPerc(b).SubmoveIndex = NaN;
    MeanPerc(b).xDot = NaN;
    MeanPerc(b).yDot = NaN;
    MeanPerc(b).zDot = NaN;
    MeanPerc(b).TotalDecomp = NaN;
    MeanPerc(b).PercValid = NaN;
    MeanPerc(b).PercMoveEarly = NaN;
end