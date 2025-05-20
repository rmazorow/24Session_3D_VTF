% Author: Rocky Mazorow
% Date: 11/5/2023

function [ReachPerc, SubHours, error] = processSubjects(subID, group, Calib, numOfSess, root)
    % Define directories
    error = 0;
    dataDir = [root 'processed_data/' subID '/'];
    saveDir = [root 'consolidated_data/'];
    rmDupDir = [root 'removDup_data/'  subID '/'];
    perSub = [saveDir 'perSub/' subID '/'];
    
    if ~exist(perSub, 'dir')
        mkdir(perSub);
    end
    
    varNames = ["SubID" "Session" "Block" "BlockType" "TrialNum" "TrialDim" "TrialTime" ...
        "Previous" "Target" "StartPos" "EndPos" ...
        "DimensionError" "TotalError" "TrialError"...
        "DimensionSpeed" "TotalSpeed" "TrialSpeed"...
        "DimensionDistance" "TotalDistance" "OptimalDistance" "DimensionRatio" "TotalRatio" "TrialRatio" ...
        "SubmoveDecomp" "DimensionDotProd" "TotalDotProd" "StabilVariat" "TrialStabil" "InferDiode" "MoveEarly"];
    TrialData = array2table(zeros(0,length(varNames)),'VariableNames',varNames);
    
    if strcmp(group(1),'P')
        blocks = {'V_01' 'R_01' 'N_01' 'T_01'...
            'A_02' 'A_03' 'A_04' 'A_05' 'A_06' 'A_07'...
            'V_08' 'R_08' 'N_08' 'T_08'...
            'B_09' 'B_10' 'B_11' 'B_12' 'B_13' 'B_14'...
            'V_15' 'R_15' 'N_15' 'T_15'...
            'C_16' 'C_17' 'C_18' 'C_19' 'C_20' 'C_21'...
            'V_22' 'R_22' 'N_22' 'T_22'};
    else
        blocks = {'V_01' 'R_01' 'N_01' 'T_01'...
            'C_02' 'C_03' 'C_04' 'C_05' 'C_06' 'C_07'...
            'V_08' 'R_08' 'N_08' 'T_08'...
            'C_09' 'C_10' 'C_11' 'C_12' 'C_13' 'C_14'...
            'V_15' 'R_15' 'N_15' 'T_15'...
            'C_16' 'C_17' 'C_18' 'C_19' 'C_20' 'C_21'...
            'V_22' 'R_22' 'N_22' 'T_22'};
    end
    numOfBlocks = [4 1 1 1 1 1 1 4 1 1 1 1 1 1 4 1 1 1 1 1 1 4];
    nBlk = 0;
    for b = 1:numOfSess
        nBlk = nBlk + numOfBlocks(b);
    end
    
    % Define total data
    MeanPerc(1:nBlk) = struct(...
        'SubID',NaN,...
        'Group',NaN,...
        'Session',NaN,...
        'Block',NaN,...
        'BlockType',NaN,...
        'BlockDim',NaN,...
        'NumTrials',NaN,...
        'TrialTime',NaN,...
        'xError',NaN,...
        'yError',NaN,...
        'zError',NaN,...
        'TotalError',NaN,...
        'TrialError',NaN,...
        'StabilVariat',NaN,...
        'TrialStabil',NaN,...
        'xSpeed', NaN,...
        'ySpeed', NaN,...
        'zSpeed', NaN,...
        'TotalSpeed', NaN,...
        'TrialSpeed', NaN,...
        'xRatio',NaN,...
        'yRatio',NaN,...
        'zRatio',NaN,...
        'TotalRatio',NaN,...
        'TrialRatio',NaN,...
        'SubmoveIndex',NaN,...
        'xDot',NaN,...
        'yDot',NaN,...
        'zDot',NaN,...
        'TotalDecomp',NaN,...
        'PercValid',NaN,...
        'PercMoveEarly',NaN);
    
    SubHours(1:numOfSess) = struct(...
        'SubID',NaN,...
        'Session',NaN,...
        'BlockType',NaN,...
        'PercError',NaN,...
        'HoursBetween',NaN);
    
    colNames = ["SubID" "Group" "Session" "Block" "BlockType" "BlockDim" "NumTrials" "TrialTime" ...
        "xError" "yError" "zError" "TotalError" "TrialError" "StabilVariat" "TrialStabil"...
        "xSpeed" "ySpeed" "zSpeed" "TotalSpeed" "TrialSpeed"...
        "xRatio" "yRatio" "zRatio" "TotalRatio" "TrialRatio" ...
        "SubmoveIndex" "xDot" "yDot" "zDot" "TotalDecomp" "PercValid" "PercMoveEarly"];
    ReachPerc = array2table(zeros(0,length(fieldnames(MeanPerc))),'VariableNames',colNames);
    
    % Define intersession variables
    intersession = NaN(numOfSess,1);
    dateFormat = "yyyy-MM-dd_HH-mm";
    iSess = 1;
    
    try
        for b = 1:nBlk
            % Opens each block folder
            block = blocks{b};
            blockType = block(1);
            session = block(end-1:end);
            dataBlock = [dataDir block '/'];
            rmDrBlock = [rmDupDir block '/'];
            disp(['  ' block]);
            if ~exist(dataBlock, 'dir')
                disp('    NO BLOCK FOLDER')
                MeanPerc = setNanBlock(MeanPerc, b, subID, group, session, block);
            else
                % Check if need to pull another Calib
                if (strcmp(subID, 'WC_006') && strcmp(block, 'C_04')) ||...
                        (strcmp(subID, 'WC_007') && strcmp(block, 'C_03')) ||...
                        (strcmp(subID, 'WS_003') && strcmp(block, 'C_02')) ||...
                        (strcmp(subID, 'WS_008') && strcmp(block, 'C_02')) ||...
                        (strcmp(subID, 'W03_YS017') && strcmp(block, 'C_04'))||...
                        (strcmp(subID, 'W03_YS016') && strcmp(block, 'C_05'))
                    subFile = [subID '_Info.mat'];
                    load([dataDir subFile]);
                elseif (strcmp(subID, 'W03_YS016') && strcmp(block, 'C_04'))
                    subFile = [subID '_Info_S4.mat'];
                    load([dataDir subFile], 'Calib');
                end
    
                procFiles = dir(fullfile(dataBlock,'*.mat'));
                allFiles  = dir(fullfile(rmDrBlock,'*.mat'));
                procCount = size(procFiles,1);
                allCount  = size(allFiles,1);
                trialFiles = char(extractfield(procFiles,'name'));
                %disp(['Total: ' num2str(allCount) ', Filtered: ' num2str(procCount)])
    
                % Calculate dimensions
                dim = (Calib.userEdge(2,:) ./ 10) * 2;
                dimLen = sqrt(dim(1)^2 + dim(2)^2 + dim(3)^2);
    
                if strcmp(blockType, 'T') || strcmp(blockType, 'A') ||...
                        strcmp(blockType, 'B') || strcmp(blockType, 'C')
                    % Calculate intersession time in hours
                    currI = char(extractfield(allFiles,'name'));
                    currS = find(str2num(currI(:,7:9)) == 1);
                    cName = allFiles(currS).name;
                    cTime = cName(end-19:end-4);
                    c = datetime(cTime,"InputFormat",dateFormat);
    
                    if iSess > 1
                        intersession(iSess) = hours(c-p);
                    end
    
                    p = c;
                    iSess = iSess + 1;
                end
    
                if procCount == 0
                    disp('    EMPTY BLOCK FOLDER')
                    [MeanRaw, MeanPerc] = setNanBlock(MeanRaw, MeanPerc, b, subID, group, session, block);
                else
                    % Create empty arrays
                    sub = repmat(subID,allCount,1);
                    sess = repmat(session,allCount,1);
                    blockName = repmat(block,allCount,1);
                    blockT = repmat(blockType,allCount,1);
                    trialDim = cell(allCount,1);
                    trialNum = NaN(allCount,1);
                    trialTime = NaN(allCount,1);
                    previous = NaN(allCount,3);
                    target = NaN(allCount,3);
                    userStart = NaN(allCount,3);
                    userStop = NaN(allCount,3);
                    dimError = NaN(allCount,3);
                    totalError = NaN(allCount,1);
                    trialError = NaN(allCount,1);
                    dimSpeed = NaN(allCount,3);
                    totalSpeed = NaN(allCount,1);
                    trialSpeed = NaN(allCount,1);
                    dimDist = NaN(allCount,3);
                    totalDist = NaN(allCount,1);
                    optDist = NaN(allCount,1);
                    dimRatio = NaN(allCount,3);
                    totalRatio = NaN(allCount,1);
                    trialRatio = NaN(allCount,1);
                    submoveDecomp = NaN(allCount,1);
                    dimDot = NaN(allCount,3);
                    totalDot = NaN(allCount,1);
                    stabilVariance = NaN(allCount,1);
                    trialStabil = NaN(allCount,1);
                    % 0=good, 1=needed to write
                    photodiode = NaN(allCount,1);
                    % 0=good, 1=moved early
                    moveOnset = NaN(allCount,1);
    
                    for t = 1:allCount
                        % Find current trial, trial number, and load data
                        tri = find(str2num(trialFiles(:,7:9)) == t);
                        trialNum(t) = t;
                        %disp(['    ' num2str(t)])
    
                        % If not good trial, autofill NaN
                        if isempty(tri)
                            %disp(num2str(t))
                            trialDim{t} = 'NaN';
                            % Else process data
                        else
                            % Clear old variables
                            clear reach stabil
    
                            % Open trial
                            filename = procFiles(tri).name;
                            load([dataBlock filename]);
                            %disp(trialDimension)
    
                            if stopFlag ~= -1
                                % Find photodiode start time
                                go = timePoints(1);
                                % Find squeezeball stop time
                                squze = timePoints(2);
    
                                % Process optotrak data
                                reach = processedOpto(go:squze,:);
                                reach = rotoTranslateCoord(reach,Calib.R_matrix,Calib.origin) ./ 10;
    
                                % Calculate other variables
                                numSamples = length(reach);
                                trialDim{t} = trialDimension;
                                trialTime(t) = numSamples / 200;
                                previous(t,:) = prevUs ./ 10;
                                target(t,:) = targUs ./ 10;
                                userStart(t,:) = reach(1,:);
                                userStop(t,:) = reach(end,:);


                                % Calculate trial error based on movement dimension
                                sessDim = [0 0 0];
                                if contains(trialDimension,'x')
                                    sessDim(1) = 1;
                                end
                                if contains(trialDimension,'y')
                                    sessDim(2) = 1;
                                end
                                if contains(trialDimension,'z')
                                    sessDim(3) = 1;
                                end
    
                                if ~inferEndR
                                    % Analyze target capture
                                    dimErr = target(t,:) - userStop(t,:);
                                    dimError(t,:) = (dimErr ./ dim) * 100;
                                    totalError(t) = sqrt((dimErr(1))^2 + (dimErr(2))^2 + (dimErr(3))^2) / dimLen * 100;
    
                                    % Analyze stabilization
                                    if stopFlag ~= -2 && ~isnan(timePoints(3)) && length(processedOpto(timePoints(3):end,:)) > 500
                                        if isnan(timePoints(4))
                                            stabil = processedOpto(timePoints(3):end,:);
                                        else
                                            stabil = processedOpto(timePoints(3):timePoints(4),:);
                                        end
                                        stabil = rotoTranslateCoord(stabil,Calib.R_matrix,Calib.origin) ./ 10;
    
                                        totStabil = sqrt(stabil(:,1).^2 + stabil(:,2).^2 + stabil(:,3).^2);
                                        stabilVariance(t) = var(totStabil, 'omitnan');
                                    end

                                    % Calculate trial error based on movement dimension
                                    if sum(sessDim == [1 1 1]) ~= 3
                                        % for trial dimension only
                                        triDims = dim .* sessDim;
                                        triLength = sqrt(triDims(1)^2 + triDims(2)^2 + triDims(3)^2);

                                        % Calculate trial error
                                        triDimError = dimError(t,:) .* sessDim;
                                        triError = sqrt(triDimError(1)^2 + triDimError(2)^2 + triDimError(3)^2);
                                        trialError(t) = triError / triLength * 100;

                                        % Calculate stabilization error
                                        triDimStabil = stabil .* sessDim;
                                        triStabil = sqrt(triDimStabil(:,1).^2 + triDimStabil(:,2).^2 + triDimStabil(:,3).^2);
                                        trialStabil(t) = var(triStabil, 'omitnan');
                                    else
                                        trialError(t) = totalError(t);
                                        trialStabil(t) = stabilVariance(t);
                                    end
    
                                    if ~inferStartR
                                        actualDist = 0;
                                        distX = 0;
                                        distY = 0;
                                        distZ = 0;
                                        for d = 1:(numSamples-1)
                                            x_1 = reach(d,1);
                                            x_2 = reach(d+1,1);
                                            y_1 = reach(d,2);
                                            y_2 = reach(d+1,2);
                                            z_1 = reach(d,3);
                                            z_2 = reach(d+1,3);
                                            dX = abs(x_2-x_1);
                                            dY = abs(y_2-y_1);
                                            dZ = abs(z_2-z_1);
                                            distX = distX + dX;
                                            distY = distY + dY;
                                            distZ = distZ + dZ;
                                            dist = sqrt((dX)^2 + (dY)^2 + (dZ)^2);
                                            actualDist = actualDist + dist;
                                        end

                                        dimDist(t,:) = [distX distY distZ];
                                        dimSpeed(t,:) = dimDist(t,:) ./ trialTime(t);
                                        totalSpeed(t) = actualDist / trialTime(t);
    
                                        totalDist(t) = actualDist;
                                        reachLength = abs(userStop(t,:) - userStart(t,:));
                                        dimRatio(t,:) = dimDist(t,:) ./ reachLength;
                                        optDist(t) = sqrt(reachLength(1)^2 + reachLength(2)^2 + reachLength(3)^2);
                                        totalRatio(t) = totalDist(t) / optDist(t);

                                        % Calculate trial error based on movement dimension
                                        if sum(sessDim == [1 1 1]) ~= 3
                                            % Calculate speed
                                            triDimSpeed = dimSpeed(t,:) .* sessDim;
                                            trialSpeed(t) = sqrt(triDimSpeed(1)^2 + triDimSpeed(2)^2 + triDimSpeed(3)^2);

                                            % Calculate ratio
                                            actDist = dimDist(t,:) .* sessDim;
                                            strtDist = reachLength(t,:) .* sessDim;
                                            totalDist = sqrt(actDist(1)^2 + actDist(2)^2 + actDist(3)^2);
                                            optDist = sqrt(strtDist(1)^2 + strtDist(2)^2 + strtDist(3)^2);
                                            trialRatio(t) = totalDist / optDist;
                                        else
                                            trialSpeed(t) = totalSpeed(t);
                                            trialRatio(t) = totalRatio(t);
                                        end

                                    else
                                        dimDist(t,:) = NaN(1,3);
                                        dimSpeed(t,:) = NaN(1,3);
                                        totalSpeed(t) = NaN;
                                        totalDist(t) = NaN;
                                        dimRatio(t,:) = NaN(1,3);
                                        optDist(t) = NaN;
                                        totalRatio(t) = NaN;
                                        trialSpeed(t) = NaN;
                                        trialRatio(t) = NaN;
                                    end
                                else
                                    dimError(t,:) = NaN(1,3);
                                    totalError(t) = NaN; 
                                    stabilVariance(t) = NaN;
                                    trialError(t) = NaN;
                                    trialStabil(t) = NaN;
                                    dimDist(t,:) = NaN(1,3);
                                    dimSpeed(t,:) = NaN(1,3);
                                    totalSpeed(t) = NaN;
                                    totalDist(t) = NaN;
                                    dimRatio(t,:) = NaN(1,3);
                                    optDist(t) = NaN;
                                    totalRatio(t) = NaN;
                                end
    
    
                                if ~inferStartR && ~inferEndR
                                    % Calculate decomposition data
                                    if numSamples > 6
                                        di = DIalgorithm_3D(reach);
                                    else
                                        di = NaN;
                                    end
                                    [avgAxes,ad] = calcAxesDecomp(reach);
                                else
                                    di = NaN;
                                    ad = NaN;
                                    avgAxes = [NaN NaN NaN];
                                end
    
                                % 0=good, 1=needed to write
                                photodiode(t) = inferDiode;
                                % 0=good, 1=moved early
                                moveOnset(t) = movedEarly;
    
                                submoveDecomp(t) = di;
                                dimDot(t,:) = [avgAxes(1) avgAxes(2) avgAxes(3)];
                                totalDot(t) = ad;
                            end
                        end
                    end
    
                    % Save raw and percent data
                    Perc = table(sub, sess, blockName, blockT, trialNum, trialDim, trialTime,...
                        previous, target, userStart, userStop,...
                        dimError, totalError, trialError,...
                        dimSpeed, totalSpeed, trialSpeed,...
                        dimDist, totalDist, optDist, dimRatio, totalRatio, trialRatio,...
                        submoveDecomp, dimDot, totalDot, stabilVariance, trialStabil, photodiode, moveOnset,...
                        'VariableNames',varNames);
                    PercentReference = table2struct(Perc,"ToScalar",true);
                    save([perSub block], 'Perc', 'PercentReference');
    
                    % Save to all block file
                    TrialData = [TrialData; Perc];
    
                    % Average results for subject
                    numTrials = sum(~cellfun(@(x) strcmp(x,'NaN'),trialDim));
                    activTime = sum(trialTime,'omitnan');
                    movePerc = sum(moveOnset,'omitnan') / length(moveOnset) * 100;
    
                    MeanPerc(b).SubID = subID;
                    MeanPerc(b).Group = group;
                    MeanPerc(b).Session = session;
                    MeanPerc(b).Block = block;
                    MeanPerc(b).BlockType = blockType;
                    MeanPerc(b).BlockDim = trialDim(find(~cellfun(@isempty,trialDim),1));
                    MeanPerc(b).NumTrials = numTrials;
                    MeanPerc(b).TrialTime = mean(trialTime,'omitnan');
                    MeanPerc(b).xError = mean(dimError(:,1),'omitnan');
                    MeanPerc(b).yError = mean(dimError(:,2),'omitnan');
                    MeanPerc(b).zError = mean(dimError(:,3),'omitnan');
                    MeanPerc(b).TotalError = mean(totalError,'omitnan');
                    MeanPerc(b).TrialError = mean(trialError,'omitnan');
                    MeanPerc(b).StabilVariat = mean(stabilVariance,'omitnan');
                    MeanPerc(b).TrialStabil = mean(trialStabil,'omitnan');
                    MeanPerc(b).xSpeed = mean(dimSpeed(:,1),'omitnan');
                    MeanPerc(b).ySpeed = mean(dimSpeed(:,2),'omitnan');
                    MeanPerc(b).zSpeed = mean(dimSpeed(:,3),'omitnan');
                    MeanPerc(b).TotalSpeed = mean(totalSpeed,'omitnan');
                    MeanPerc(b).TrialSpeed = mean(trialSpeed,'omitnan');
                    MeanPerc(b).xRatio = mean(dimRatio(:,1),'omitnan');
                    MeanPerc(b).yRatio = mean(dimRatio(:,2),'omitnan');
                    MeanPerc(b).zRatio = mean(dimRatio(:,3),'omitnan');
                    MeanPerc(b).TotalRatio = mean(totalRatio,'omitnan');
                    MeanPerc(b).TrialRatio = mean(trialRatio,'omitnan');
                    MeanPerc(b).SubmoveIndex = mean(submoveDecomp,'omitnan');
                    MeanPerc(b).xDot = mean(dimDot(:,1),'omitnan');
                    MeanPerc(b).yDot = mean(dimDot(:,2),'omitnan');
                    MeanPerc(b).zDot = mean(dimDot(:,3),'omitnan');
                    MeanPerc(b).TotalDecomp = mean(totalDot,'omitnan');
                    MeanPerc(b).PercValid = procCount / allCount * 100;
                    MeanPerc(b).PercMoveEarly = max(movePerc, 0);
                end
            end
        end
    
        vtfB = [4:10 14:20 24:30 34];
        for s = 1:numOfSess
            SubHours(s).SubID = subID;
            SubHours(s).Session = s;
            SubHours(s).BlockType = MeanPerc(vtfB(s)).BlockType;
            SubHours(s).HoursBetween = intersession(s);
            SubHours(s).PercError = MeanPerc(vtfB(s)).TrialError;
        end
    
        % Save all block info
        file = [subID '_SubDat'];
        TrialData = table2struct(TrialData,'ToScalar',true);
        SubPerc = MeanPerc;
        save([perSub file], 'TrialData', 'SubPerc', 'SubHours');
    
        % Save as table
        ReachPerc = struct2table(MeanPerc);
        SubHours = struct2table(SubHours);
    
    catch ME
        disp(['ERROR.... ' subID ': ' block ' - ' num2str(t)])
        SubHours = struct2table(SubHours);
        error = 1;
        rethrow(ME);
        return
    end
end