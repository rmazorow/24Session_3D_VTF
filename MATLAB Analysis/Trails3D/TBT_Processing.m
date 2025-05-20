% Author: Rocky Mazorow
% Date Created: 8/19/2024

% This script visually shows the results of the Trails B inspired task
 
clear
clc

%% Target Plot
grid = load('gridData_fullscreen.mat');
root = 'p_data/';
saveTo = 'p_processed/';

listOfFiles = dir(root);
%subs = extractfield(listOfFiles(4:end-1),'name');
subs = {'WY_001','WY_002','WY_003a'};
blocks = {'P_01'};%,'P_08','P_15','P_22'};
overwrite = 1;

varNames = ["SubID" "Session" "MeanError" "NumCharacters"];
%trials = array2table(zeros(0,length(varNames)),'VariableNames',varNames);

if ~exist('TrialData','var') %&& ~overwrite
    load([saveTo 'TBT.mat']); 
end

for s = 1:length(subs)
    disp(subs{s})

    idx = strcmp(trials.SubID, subs{s});
    if ~overwrite
        if any(idx)
            continue;
        end
    else
        if any(idx)
            row = find(idx == 1);
        else
            row = size(trials,1)+1;
        end
    end

    % load subject info
    if strcmp(subs{s},'WC_006')
        load([root subs{s} '/' subs{s} '_Info_S1-3.mat']);
    elseif strcmp(subs{s},'WC_007') || strcmp(subs{s},'WS_009')
        load([root subs{s} '/' subs{s} '_Info_S1-2.mat']);
    elseif strcmp(subs{s},'WS_007')
        load([root subs{s} '/' subs{s} '_Info_V1.mat']);
    elseif strcmp(subs{s},'WS_003') %|| strcmp(subs{s},'WY_001')
        load([root subs{s} '/' subs{s} '_Info_S1.mat']);
    elseif strcmp(subs{s},'W03_YS016')
        load([root subs{s} '/' subs{s} '_Info_S4.mat']);
    else
        load([root subs{s} '/' subs{s} '_Info.mat']);
    end

    % create save folder
    saveTri = [saveTo subs{s} '/'];
    if ~exist(saveTri, 'dir')
        mkdir(saveTri);
    end

    blk = cell(length(blocks), 4);

    for b = 1:1%length(blocks)
        if ((strcmp(subs{s},'WC_006') || strcmp(subs{s},'WC_007') || ...
             strcmp(subs{s},'WS_003') || strcmp(subs{s},'WS_007') || ...
             strcmp(subs{s},'WY_001') || strcmp(subs{s},'W03_YS016')) && b > 1)
            load([root subs{s} '/' subs{s} '_Info.mat']);
        end

        % load TBT trial
        block = blocks{b};
        blockDir = [root subs{s} '/' block '/'];
        if ~exist(blockDir, 'dir')
            disp('Block Empty');
            blk{b,1} = subs{s};
            blk{b,2} = str2double(block(end-1:end));
            blk{b,3} = NaN;
            blk{b,4} = NaN;
        else
            clear circleGridUs 

            listOfFiles = dir(fullfile(blockDir,'*.mat'));
            trialFiles = extractfield(listOfFiles,'name');
            load([blockDir trialFiles{end}]); 
    
            calcLetter = false;
            
            if ~exist('circleGridUs','var')
                circleGridUs = pixToOptoCoord(letterGridPx,Calib,grid);
                calcLetter = true;
                disp("true")
            end
            
            dim = Calib.userEdge(2,:) * 2;
            dimLen = sqrt(dim(1)^2 + dim(2)^2 + dim(3)^2);
            dim = dim(1,1:2);
            targets = circleGridUs(:,1:2) ./ dim * 100;
            
            % Fix width to a polynomial and adjust for screen
            dimZ = unique(circleGridUs(:,3));
            % find polynomial coefficients
            coZ = polyfit([dimZ(1) dimZ(5)], [2 9], 1);
            targets(:,3) = circleGridUs(:,3).*coZ(1) + coZ(2);
            
            if calcLetter
                letterGridUs = circleGridUs;
                letterGridUs(:,2) = letterGridUs(:,2);% + (targets(:,3)+7);
            end
            letters = letterGridUs(:,1:2) ./ dim * 100;
            letterOrder = fixedLetters';
            
            %% Find squeezes
            clear optotrak press sqz sqzAt sqzPx
            optotrak = processOptotrak(optotrak_array(1:end,:));
            optotrak = rotoTranslateCoord(optotrak,Calib.R_matrix,Calib.origin);
            
            fs = 200;
            cutoff = 10;
            [d1, c1] = butter(4, cutoff/(fs/2), 'low');
            odau = filter(d1,c1,odau_array(100:end,1));
    
            press = findSqueeze(odau, Calib.maxSqueeze);           
            sqz = press([1; find(diff(press)>1)+1]);
            sqzAt = optotrak(sqz,:);
            sqzPx(:,1:2) = sqzAt(:,1:2) ./ dim * 100;
            sqzPx(:,3) = sqzAt(:,3).*coZ(1) + coZ(2);
            neg = find(sqzPx(:,3) < 0);
            if ~isempty(neg)
                sqzPx(neg,3) = 1;
            end
            y = odau(sqz);

            userError =  NaN(24,1);
            userLetter = NaN(24,1);
            userOrder = cell(length(sqz),1);

            % Plot results and ask for input
            for u = 1:length(sqz)
                figure('Units','normalized','Position',[0 0 0.5 0.2]);
                plot(odau);
                hold on;
                scatter(sqz(u),y(u)),'.';
                hold off;
    
                figure('Units','normalized','Position',[0 0.6 0.5 0.6]);
                centers = [targets(:,1) targets(:,2)];
                radii = targets(:,3);
                % Display the circles
                viscircles(centers,radii,'Color','k');  
                xlim([-70 70])
                ylim([-70 70])              
                axis square
                hold on; 
                viscircles([sqzPx(u,1) sqzPx(u,2)],sqzPx(u,3),'Color','g');  
                text(letters(:,1),letters(:,2),letterOrder,'Color','r')
                hold off;
                
                while isempty(userOrder{u}) || strcmp(userOrder(u),"")
                    userOrder(u) = upper(inputdlg('What character?','Character',[1 7]));
                end
                if ~strcmp(userOrder(u),'-1')
                    index = find(strcmp(letterOrder,userOrder(u)));
                    userLetter(index) = u;
                    % Analyze target capture
                    dimErr = circleGridUs(index,:) - sqzAt(u,:);
                    userError(index) = sqrt((dimErr(1))^2 + (dimErr(2))^2 + (dimErr(3))^2) / dimLen * 100;
                else
                    disp('unknown')
                end
                close all;
            end

            userReponse = [letterOrder, num2cell(userLetter), num2cell(userError)];
            userReponse = sortrows(userReponse,2);
    
            save([saveTri subs{s} '-' blocks{b}],'userReponse');

            blk{b,1} = subs{s};
            blk{b,2} = str2double(block(end-1:end));
            blk{b,3} = mean(userError,'omitnan');
            blk{b,4} = sum(~isnan(userLetter));
        end
    end

    blkT = array2table(blk,'VariableNames',varNames);
    trials(row,:) = blkT;

end

TrialData = table2struct(trials,'ToScalar',true);
save([saveTo 'TBT'],'TrialData', 'trials');