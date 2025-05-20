% Author: Rocky Mazorow
% Date Created: 1/5/2024

% Pulls subject daily survey score, normalized error, pace

function processDailySurveys(subs,groups,root,saveDir)
    sess = [2 3 4 5 6 7 9 10 11 12 13 14 16 17 18 19 20 21];
    indices  = [5 6 7 8 9 10 15 16 17 18 19 20 25 26 27 28 29 30];
    indices = indices - 1; % subtract one to add to starting index
    numBlks = 34;
    subSess = length(sess);
    subNum = length(subs);
    %varNames = ["SubID" "Session" "Score" "NormError" "Pace"];
    %DailySurvey = array2table(zeros(subNum*subSess,length(varNames)),'VariableNames',varNames);

    subID = cell(subNum*subSess,1);
    group = cell(subNum*subSess,1);
    session = NaN(subNum*subSess,1);
    score = NaN(subNum*subSess,1);
    error = NaN(subNum*subSess,1);
    speed = NaN(subNum*subSess,1);
    path = NaN(subNum*subSess,1);
    index = 1;

    daily = readtable([root 'consolidated_data/DailyTrainingSurvey.xlsx'],...
            'Range','A:D','ReadVariableNames',true);
    load([root 'consolidated_data/ReachData.mat'], 'MeanPerc');

    for s = 1:subNum
        sID = subs{s};
        grp = groups{s};
        subStart = numBlks*(s-1) + 1;
        disp(sID)

        for t = 1:subSess
            subID{index} = sID;
            group{index} = grp;
            session(index) = sess(t);
            dayScore = daily{strcmp(daily.SubID,sID) & str2double(daily.Session)==sess(t), 4};

            %disp([sID ': Session ' num2str(sess(t))])
            %disp(['    .' num2str(dayScore) '.'])
            % if session score exists
            if ~isempty(dayScore)
                score(index) = dayScore;
                row = subStart + indices(t);
                error(index) = MeanPerc.TrialError(row);
                speed(index) = MeanPerc.TrialSpeed(row);
                path(index) = MeanPerc.TrialRatio(row);
            end
            index = index + 1;
        end
    end

    DailySurvey.SubID = subID;
    DailySurvey.Group = group;
    DailySurvey.Session = session;
    DailySurvey.Score = score;
    DailySurvey.Error = error;
    DailySurvey.Speed = speed;
    DailySurvey.PathRatio = path;
    save([saveDir 'DailySurveys'], 'DailySurvey');
end