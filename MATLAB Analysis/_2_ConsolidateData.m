% Author: Rocky Mazorow
% Date: 11/5/2023

%clc 
%clear

disp('Select folder containing your data');
root = uigetdir('title', 'Select folder containing your data');

if ~exist(root, 'dir')
    disp('Wrong computer');
    return;
end

quit = 0;
data = [root 'processed_data/'];
saveDir = [root 'consolidated_data/'];
% subDone = {'WS_001','WS_002','WS_004','WS_005','WS_008',...
%         'WC_003','WC_004','WC_005','WC_006','WC_007','WC_008','WC_009',...
%         'WY_001','WY_002','WY_003','WS_007',...
%         'PxS_001',...
%         'PyC_002','PzC_003','PxC_004','PyC_005',...
%         'W03_YS016','W03_YS017'};
% subW = {'WS_003'};
subDone = {};
subW = {'WC_003','WC_004','WC_005','WC_006','WC_007','WC_008','WC_009',...
        'WS_001','WS_002','WS_003','WS_004','WS_005','WS_007','WS_008',...
        'WY_001','WY_002','W03_YS016','W03_YS017','WY_003','WS_010'};
subP = {};
subW03 = {};
allSubs = [subDone subW subP subW03];
numSub = length(allSubs);

numSess = 22;

if ~exist(saveDir, 'dir')
    mkdir(saveDir)
end

% Generate list for kinematic info
varNames = ["SubID" "Group" "Session" "Block" "BlockType" "BlockDim" "NumTrials" "TrialTime" ...
        "xError" "yError" "zError" "TotalError" "TrialError" "StabilVariat" "TrialStabil"...
        "xSpeed" "ySpeed" "zSpeed" "TotalSpeed" "TrialSpeed"...
        "xRatio" "yRatio" "zRatio" "TotalRatio" "TrialRatio" ...
        "SubmoveIndex" "xDot" "yDot" "zDot" "TotalDecomp" "PercValid" "PercMoveEarly"];
MeanPerc = array2table(zeros(0,length(varNames)),...
    'VariableNames',varNames);
Intersession = array2table(zeros(0,5),...
    'VariableNames',["SubID" "Session" "BlockType" "PercError" "HoursBetween"]);

% Generate list for sub info
subID = cell(numSub,1);
group = cell(numSub,1);
type = cell(numSub,1);
sex = cell(numSub,1);
hand = cell(numSub,1);
age = NaN(numSub,1);
avgSqz = NaN(numSub,1);
maxSqz = NaN(numSub,1);
xDim = NaN(numSub,1);
yDim = NaN(numSub,1);
zDim = NaN(numSub,1);
totHours = NaN(numSub,1);
s = 1;

%% Grab completed subject data
for d = 1:length(subDone)
    disp(subDone{d});

    % Save sub profile
    subDir = [data subDone{d} '/'];
    subFile = [subDone{d} '_Info.mat'];
    load([subDir subFile]);
    subID{s} = subDone{d};
    group{s} = Demo.Group;
    type{s} = Demo.Type;
    sex{s} = Demo.Sex;
    hand{s} = Demo.MoveHand;
    age(s) = str2double(Demo.Age);
    avgSqz(s) = Calib.avgSqueeze;
    maxSqz(s) = Calib.maxSqueeze;
    xDim(s) = Calib.userEdge(2,1) * 2;
    yDim(s) = Calib.userEdge(2,2) * 2;
    zDim(s) = Calib.userEdge(2,3) * 2;
    
    if exist([root 'raw_data/' subDone{d} '/P_22'], 'dir')
        listOfFiles = dir(fullfile([root 'raw_data/' subDone{d} '/V_01'],'*.mat'));
        trialFiles = extractfield(listOfFiles,'name');
        trialFiles = char(trialFiles);
        tri = find(str2num(trialFiles(:,7:9)) == 1);
        filename = listOfFiles(tri).name;
        startTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
        listOfFiles = dir(fullfile([root 'raw_data/' subDone{d} '/P_22'],'*.mat'));
        trialFiles = extractfield(listOfFiles,'name');
        trialFiles = char(trialFiles);
        filename = listOfFiles(1).name;
        endTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
        totHours = days((endTime - startTime));
    end
    s = s+1;

    % Compile subject reach data
    loadFrom = [saveDir 'perSub/' subDone{d} '/' subDone{d} '_SubDat.mat'];
    load(loadFrom, 'SubPerc', 'SubHours');
    SubPerc = struct2table(SubPerc);
    SubHours = struct2table(SubHours);
    MeanPerc = [MeanPerc; SubPerc];
    Intersession = [Intersession; SubHours];
end

%% Compile whole control
for wc = 1:length(subW)
    disp(subW{wc});

    % Save sub profile
    subDir = [data subW{wc} '/'];
    if strcmp(subW{wc}, 'WC_006')
        subFile = [subW{wc} '_Info_S1-3.mat'];
    elseif strcmp(subW{wc}, 'WC_007')
        subFile = [subW{wc} '_Info_S1-2.mat'];
    elseif strcmp(subW{wc}, 'WS_003')
        subFile = [subW{wc} '_Info_S1.mat'];
    elseif strcmp(subW{wc}, 'WS_008')
        subFile = [subW{wc} '_Info_S1_V1-T1.mat'];
    elseif strcmp(subW{wc}, 'WY_001')
        subFile = [subW{wc} '_Info_S1.mat'];
    elseif strcmp(subW{wc}, 'W03_YS016') || strcmp(subW{wc}, 'W03_YS017')
        subFile = [subW{wc} '_Info_3sess.mat'];
    else    
        subFile = [subW{wc} '_Info.mat'];
    end

    load([subDir subFile]);
    subID{s} = subW{wc};
    group{s} = Demo.Group;
    type{s} = Demo.Type;
    sex{s} = Demo.Sex;
    hand{s} = Demo.MoveHand;
    age(s) = str2double(Demo.Age);
    if strcmp(subW{wc}, 'W03_YS016')
        avgSqz(s) = 1.539;
        maxSqz(s) = 3.590;
    elseif strcmp(subW{wc}, 'W03_YS017')
        avgSqz(s) = 1.700;
        maxSqz(s) = 3.590;
    else
        avgSqz(s) = Calib.avgSqueeze;
        maxSqz(s) = Calib.maxSqueeze;
    end
    xDim(s) = Calib.userEdge(2,1) * 2;
    yDim(s) = Calib.userEdge(2,2) * 2;
    zDim(s) = Calib.userEdge(2,3) * 2;

    if exist([root 'raw_data/'  subW{wc} '/P_22'], 'dir')
        listOfFiles = dir(fullfile([root 'raw_data/'  subW{wc} '/V_01'],'*.mat'));
        trialFiles = extractfield(listOfFiles,'name');
        trialFiles = char(trialFiles);
        tri = find(str2num(trialFiles(:,7:9)) == 1);
        filename = listOfFiles(tri).name;
        startTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
        listOfFiles = dir(fullfile([root 'raw_data/'  subW{wc} '/P_22'],'*.mat'));
        trialFiles = extractfield(listOfFiles,'name');
        trialFiles = char(trialFiles);
        filename = listOfFiles(1).name;
        endTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
        totHours = days((endTime - startTime));
    end

    s = s+1;

    % Compile subject reach data
    [SubPerc, SubHours, error] = processSubjects(subW{wc}, Demo.Group, Calib, numSess, root);
    if error
        quit = 1;
        return
    end
    MeanPerc = [MeanPerc; SubPerc];
    Intersession = [Intersession; SubHours];
end
%% Compile partial control
if ~quit
    for pc = 1:length(subP)
        disp(subP{pc});
    
        % Save sub profile
        subDir = [data subP{pc} '/'];
        subFile = [subP{pc} '_Info.mat'];
        load([subDir subFile]);
        subID{s} = subP{pc};
        group{s} = Demo.Group;
        type{s} = Demo.Type;
        sex{s} = Demo.Sex;
        hand{s} = Demo.MoveHand;
        age(s) = str2double(Demo.Age);
        avgSqz(s) = Calib.avgSqueeze;
        maxSqz(s) = Calib.maxSqueeze;
        xDim(s) = Calib.userEdge(2,1) * 2;
        yDim(s) = Calib.userEdge(2,2) * 2;
        zDim(s) = Calib.userEdge(2,3) * 2;
    
        if exist([root 'raw_data/' subP{pc} '/P_22'], 'dir')
            listOfFiles = dir(fullfile([root 'raw_data/' subP{pc} '/V_01'],'*.mat'));
            trialFiles = extractfield(listOfFiles,'name');
            trialFiles = char(trialFiles);
            tri = find(str2num(trialFiles(:,7:9)) == 1);
            filename = listOfFiles(tri).name;
            startTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
            listOfFiles = dir(fullfile([root 'raw_data/' subP{pc} '/P_22'],'*.mat'));
            trialFiles = extractfield(listOfFiles,'name');
            trialFiles = char(trialFiles);
            filename = listOfFiles(1).name;
            endTime = datetime(filename(11:26),'InputFormat','yyyy-MM-dd_HH-mm');
            totHours = days((endTime - startTime));
        end
    
        s = s+1;
    
        % Compile subject reach data
        [SubPerc, SubHours, error] = processSubjects(subP{pc}, Demo.Group, Calib, numSess, root);
        if error
            quit = 1;
            return
        end
        MeanPerc = [MeanPerc; SubPerc];
        Intersession = [Intersession; SubHours];
    end
end

%% Compile all data
if ~quit
    Subs = table(cell(subID),cell(group),...
        cell(type),cell(sex),cell(hand),...
        age,avgSqz,maxSqz,xDim,yDim,zDim,...
        'VariableNames',["SubID" "Group" "Type" "Sex" "MoveHand"...
            "Age" "AvgSqz" "MaxSqz" "xDim" "yDim" "zDim"]);
    SubInfo = table2struct(Subs,'ToScalar',true);
    save([saveDir 'Cog_SubInfo'], 'SubInfo');
    
    ReachPerc = table2struct(MeanPerc,'ToScalar',true);
    IntersessionHours = table2struct(Intersession,'ToScalar',true);
    save([saveDir 'Cog_ReachData'], 'ReachPerc', 'MeanPerc', 'IntersessionHours');
    
    %disp('Consolidating Daily Scores...')
    %processDailySurveys(allSubs, group, root, saveDir);
    
    %disp('Consolidating Surveys...')
    %allSubs = {'W03_YS016' 'W03_YS017' 'WC_003' 'WC_004' 'WC_005' 'WC_006'...
    %   'WC_007' 'WC_008' 'WS_001' 'WS_002' 'WS_003' 'WS_004' 'WS_005' 'WS_007' 'WS_008'};
    %processSurveys(allSubs, root, saveDir);
end
