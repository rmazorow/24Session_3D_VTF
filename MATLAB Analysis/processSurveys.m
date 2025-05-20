function processSurveys(subs,root,saveDir)
%% DataConsolidation.m
% This function takes all subject's .mat files and consolidates them
%
% Variables:
%   subID       String of the subject
%   myRootDir   Root directory of subject's data files
% 
% Output:
%   Survey       Creates a file of subject's consolidated data

% trial branch leaves each NaN'ed out

    dataDir = [root 'SurveyResults/'];
    subNum = length(subs);
    index = 1;

    varNames = ["SubID" "SusAvg" "ImiInterest" "ImiEffort" "ImiValue" "ImiCompetence"...
        "ImiPressure" "ImiChoice" "QuestAvg" "qItem1" "qItem2" "qItem3"];
    subSurvs{1} = 'Statement';
    for i = 1:subNum
        subSurvs{i+1} = subs{i};
    end

    SUS = array2table(zeros(10,length(subSurvs)),'VariableNames',subSurvs);
    IMI = array2table(zeros(37,length(subSurvs)),'VariableNames',subSurvs);
    QUEST1 = array2table(zeros(9,length(subSurvs)),'VariableNames',subSurvs);
    QUEST2 = array2table(zeros(9,length(subSurvs)),'VariableNames',subSurvs);
    %Open = array2table(zeros(10,length(subSurvs)),'VariableNames',subSurvs);

    subID = cell(subNum,1);
    susA = NaN(subNum,1);
    intrst = NaN(subNum,1);
    effort = NaN(subNum,1);
    value = NaN(subNum,1);
    comptn = NaN(subNum,1);
    prssur = NaN(subNum,1);
    choice = NaN(subNum,1);
    questS = NaN(subNum,7);
    quest1 = cell(subNum,1);
    quest2 = cell(subNum,1);
    quest3 = cell(subNum,1);

    for s = 1:length(subs)
        sID = subs{s};
        saveSub = [saveDir 'perSub/' sID '/'];
        fileName = [dataDir sID '_Survey.xlsx'];
        disp(['    Evaluating ' sID])

        if ~exist(fileName, 'file')
            
        else
            sus = readtable(fileName, 'Sheet','sus',...
                'Range','A1:B10','ReadVariableNames',false);
            sus = renamevars(sus,'Var1','Statement');
            sus = renamevars(sus,'Var2','Score');
            Survey.sus = sus;
        
            imi = readtable(fileName, 'Sheet','imi',...
                'ReadVariableNames',false);
            imi = renamevars(imi,'Var1','Statement');
            imi = renamevars(imi,'Var2','Score');
            Survey.imi = imi;
        
            quest = readtable(fileName, 'Sheet','quest',...
                'Range','A1:C9','ReadVariableNames',false);
            quest = renamevars(quest,'Var1','Statement');
            quest = renamevars(quest,'Var2','Score');
            quest = renamevars(quest,'Var3','Comments');
            Survey.quest = quest;
            
            % open = readtable(fileName, 'Sheet','questionnaire',...
            %     'ReadVariableNames',false);
            % open = renamevars(open,'Var1','Statement');
            % open = renamevars(open,'Var2','Comments');
            % Survey.open = open;
            
            % Add subject surveys scores to master documents
            if s == 1
                SUS.Statement = sus.Statement;
                IMI.Statement = imi.Statement;
                QUEST1.Statement = quest.Statement;
                QUEST2.Statement = quest.Statement;
                %Open.Statement = open.Statement;
            end
    
            eval(sprintf('SUS.%s = sus.Score;', sID));
            eval(sprintf('IMI.%s = imi.Score;', sID));
            eval(sprintf('QUEST1.%s = quest.Score;', sID));
            eval(sprintf('QUEST2.%s = quest.Comments;', sID));
            %eval(sprintf('Open.%s = open.Comments;', sID));
        
            imi_intrst = ((8-imi{2,2})+imi{12,2}+imi{19,2}+imi{21,2}+(8-imi{23,2})+imi{29,2}+imi{31,2})/7;
            imi_effort = (imi{5,2}+imi{8,2}+(8-imi{25,2})+(8-imi{27,2})+imi{36,2})/5;
            imi_value  = (imi{3,2}+imi{13,2}+imi{24,2}+imi{26,2}+imi{30,2}+imi{33,2}+imi{37,2})/7;
            imi_comptn = (imi{1,2}+imi{6,2}+imi{7,2}+imi{9,2}+(8-imi{11,2})+imi{17,2}+(8-imi{30,2}))/6;
            imi_prssur = ((8-imi{10,2})+imi{14,2}+imi{20,2}+(8-imi{32,2})+imi{34,2})/5;
            imi_choice = ((8-imi{4,2})+(8-imi{15,2})+imi{16,2}+(8-imi{18,2})+imi{22,2}+(8-imi{28,2})+(8-imi{35,2}))/7;
            quest_avg  = mean(quest{1:6,2});
            quest_itm  = quest{7:9,3};
            sus_avg    = ((sus{1,2}-1)+(5-sus{2,2})+(sus{3,2}-1)+(5-sus{4,2})+(sus{5,2}-1)+(5-sus{6,2})+(sus{7,2}-1)+(5-sus{8,2})+(sus{9,2}-1)+(5-sus{10,2}))*2.5;
        
            scores.susAvg = sus_avg;
            scores.imiIntrst = imi_intrst;
            scores.imiEffort = imi_effort;
            scores.imiValue = imi_value;
            scores.imiComptn = imi_comptn;
            scores.imiPrssur = imi_prssur;
            scores.imiChoice = imi_choice;
            scores.questAvg = quest_avg;
            scores.questIt1 = quest_itm{1};
            scores.questIt2 = quest_itm{2};
            scores.questIt3 = quest_itm{3};
        
            Survey.scores = scores;
            save([saveSub 'Survey'], 'Survey');
    
            subID{index} = sID;
            susA(index) = sus_avg;
            intrst(index) = imi_intrst;
            effort(index) = imi_effort;
            value(index) = imi_value;
            comptn(index) = imi_comptn;
            prssur(index) = imi_prssur;
            choice(index) = imi_choice;
            questS(index,:) = [quest{1,2} quest{2,2} quest{3,2} ...
                quest{4,2} quest{5,2} quest{6,2} quest_avg];
            quest1{index} = quest_itm{1};
            quest2{index} = quest_itm{2};
            quest3{index} = quest_itm{3};

            index = index + 1;
        end
    end

    SurveyScores.SubID = subID;
    SurveyScores.SusAvg = susA;
    SurveyScores.ImiInterest = intrst;
    SurveyScores.ImiEffort = effort;
    SurveyScores.ImiValue = value;
    SurveyScores.ImiCompetence = comptn;
    SurveyScores.ImiPressure = prssur;
    SurveyScores.ImiChoice = choice;
    SurveyScores.QuestWeight = questS(:,1);
    SurveyScores.QuestSafety = questS(:,2);
    SurveyScores.QuestEase = questS(:,3);
    SurveyScores.QuestComfort = questS(:,4);
    SurveyScores.QuestEffect = questS(:,5);
    SurveyScores.QuestService = questS(:,6);
    SurveyScores.QuestAvg = questS(:,7);
    SurveyScores.qItem1 = quest1;
    SurveyScores.qItem2 = quest2;
    SurveyScores.qItem3 = quest3;

    save([saveDir 'SurveyScores'], 'SurveyScores');
end