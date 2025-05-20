% Author: Rocky Mazorow
% Date Created: 4/12/2024
% Score trials as valid, invalid, or noisy Removed invalid trials that were not subject initiated


function processTrials_v2(root, subs, blocks, dimB)
    
    overwrite = 1;
    addBlock = 0;
    
    % Location of data to search through and where to save
    data = [root 'removDup_data/'];
    saveDir = [root 'processed_data/'];
    revDir = [root 'Validation_Reviewer_Forms/'];
    xlsNames = ["Session" "Block" "Trial" "Photodiode" "EarlyMove" "Squeeze" "StartSamp" " SqueezeSamp" "StabSamp" "CorrectSamp"];
    %index = 1;
    
    if ~exist(saveDir, 'dir')
        mkdir(saveDir)
    end
    
    numSub = length(subs);
    for s = 1:numSub
        sub = subs{s};
        if strcmp(sub(1:3),'W03')
            subName = sub;
        else
            subName = [sub(1:end-3) '_' sub(end-2:end)];
        end
        disp(subName)
        subData = [data subName '/'];
        saveSub = [saveDir subName '/'];
    
        % Generate table for trials
        trials = array2table(zeros(0,10),'VariableNames',xlsNames);
    
        if strcmp(sub(1),'W')
            blks = blocks(:,1);
            dims = dimB(:,1);
        elseif strcmp(sub(1:2),'Px')
            blks = blocks(:,2);
            dims = dimB(:,2);
        elseif strcmp(sub(1:2),'Py')
            blks = blocks(:,2);
            dims = dimB(:,3);
        elseif strcmp(sub(1:2),'Pz')
            blks = blocks(:,2);
            dims = dimB(:,4);
        end
    
        if ~overwrite
            T = readtable([revDir sub '_validTrials_rnm.xlsx'], ReadVariableNames = false);
            for r = 1:size(T,1)
                blockName{r} = [T.Var2{r} '_' num2str(T.Var1(r),'%02d')];
            end
        end
    
        % Copy appropriate blocks over
        for b = 1:length(blks)
            block = blks{b};
            if ~strcmp(block(1), 'P') && ~strcmp(block(1), 'M')
                disp(['  ' block])
                blockData = [subData block '/'];
    
                % Check if block exists
                if ~exist(blockData, 'dir')
                    disp('    No Block')
                else
                    saveBlock = [saveSub block '/'];
                    if ~exist(saveBlock, 'dir')
                        mkdir(saveBlock)
                    else
                        delete([saveBlock '*.mat']);
                    end
    
                    listOfFiles = dir(fullfile(blockData,'*.mat'));
                    numTrials = length(listOfFiles);
                    %disp(['Files: ' num2str(numTrials)]);
    
                    if overwrite
                        blk = cell(numTrials,10);
                    else
                        blockStart = find(strcmp(blockName,block),1,'first');
                        blockEnd   = find(strcmp(blockName,block),1,'last');
                        %disp(['Rows: ' num2str(blockStart) ' - ' num2str(blockEnd)]);
                        if isempty(blockStart) || isempty(blockEnd)
                            addBlock = 1;
                            blk = cell(numTrials, 10);
                        else
                            blk = table2cell(T(blockStart:blockEnd,:));
                        end
                    end
    
                    for t = 1:numTrials
                        if overwrite || addBlock
                            % Save trial data
                            underscore = strfind(block,'_');
                            sess = str2double(block(underscore+1:end));
                            blockType = block(1:underscore-1);
                            inferDiode = 0;
                            movedEarly = 0;
    
                            blk{t,1} = sess;
                            blk{t,2} = blockType;
                            blk{t,3} = t;
    
                            clear threshold timeSync photo squeeze
    
                            filename = listOfFiles(t).name;
                            copyFrom = [blockData filename];
                            load([blockData filename]);
                            %disp(['    trial: ' num2str(t)])
    
                            if stopFlag ~= -1
                                % Check if threshold variable exists for trial
                                if ~exist('threshold','var')
                                    threshold = 1.8;
                                end
    
                                % Review photo diode
                                clear ballPress photodiode
                                fs = 200;
                                cutoff = 10;
                                [d1, c1] = butter(4, cutoff/(fs/2), 'low');
                                [d2, c2] = butter(4, [59 61]./(fs/2), 'stop');
                                ballPress  = filter(d1,c1,odau_array(:,1));
                                photodiode = filter(d2,c2,odau_array(:,2));
    
                                % Check that ball is not squeezed at start of trial
                                % if any(ballPress(1:100,1) > threshold)
                                %     relax = find(ballPress(1:100,1) > threshold);
                                %     ballPress(relax,1) = threshold - 0.1;
                                % end
    
                                % Determine go cue
                                diodeThresh = 2;
                                photo = find(photodiode < diodeThresh);
                                if isempty(photo) || length(photo) == length(ballPress)
                                    blk{t,4} = 'B';

                                    if exist('timeSync','var')
                                        cue = round(timeSync(1)) - 84;
                                        inferDiode = 1;
                                    else
                                        cue = 350;
                                    end
                                else
                                    blk{t,4} = 'G';

                                    drops = sum(diff(photo) > 200);
                                    if drops > 0
                                        realStart = photo(1)+200;
                                        tempPhoto = photodiode(realStart:end,:);
                                        next = (realStart-1) + find(tempPhoto < diodeThresh);
                                        cue = next(1);
                                        
                                        blk{t,4} = 'N';
                                    else
                                        cue = photo(1);
                                    end
                                end
    
                                % Review squeeze ball
                                pressure = ballPress(cue+200:end);
                                squeeze = (cue+199) + find(pressure > threshold,1,'first');
    
                                % Only save data if not bad
                                if isempty(squeeze)
                                    blk{t,6} = 'B';
                                else
                                    above = find(pressure > threshold);
                                    diffS = diff(above);

                                    if sum(diffS == 1) >= size(diffS,1)*0.97
                                        blk{t,6} = 'G';
                                    elseif sum(diffS == 1) >= size(diffS,1)*0.8
                                        answer = "";
                                        disp(['above%: ' num2str( sum(diffS == 1)/size(diffS,1)*100 )])

                                        while strcmp(answer,"") || (~strcmp(answer,"B") && ~strcmp(answer,"G"))
                                            % Plot results and ask for input
                                            disp(['      TRIAL: ' num2str(t)])
                                            tName = [subName ': ' block ' - ' num2str(t)];
                                            label = ['Score: ' blk{t,6}];
                                            figure('Name',tName,'Units','normalized','Position',[0 0.5 0.5 0.5]);
                                            yline(threshold,'-b');
                                            hold on;
                                            xline(cue:cue+5,'-g');
                                            xline(squeeze:squeeze+5,'-r');
                                            plot(ballPress,'-k');
                                            hold off;
                                            answer = upper(inputdlg(label,tName,[1 7]));

                                            if strcmp(answer,"R")
                                                [x,~] = ginput(1);
                                                squeeze = round(x);
                                            end
                                        end

                                        close all;
                                        blk{t,6} = answer;
                                    else
                                        blk{t,6} = 'B';
                                    end
                                end
    
                                if ~strcmp(blk{t,6},'B')
                                    % Determine if moved early
                                    if strcmp(sub(1:3),'W03') && b < 8
                                        opto = processOptotrak(optotrak_array(cue+1:squeeze-200,:));
                                    else
                                        opto = processOptotrak(optotrak_array(101:squeeze,:));
                                    end

                                    dist = NaN(length(opto)-1,1);
                                    for l = 1:length(opto)-1
                                        dx = opto(l+1,1) - opto(l,1);
                                        dy = opto(l+1,2) - opto(l,2);
                                        dz = opto(l+1,3) - opto(l,3);
                                        dist(l) = sqrt(dx^2 + dy^2 + dz^2);
                                    end
                                    speed = dist * 200;
                                    peak = max(speed);
                                    perc = speed ./ peak * 100;
                                    if strcmp(sub(1:3),'W03') && b < 8
                                        startMove = cue + find(perc >= 10, 1);
                                    else
                                        startMove = 100 + find(perc >= 10, 1);
                                    end
                                    %figure; plot3(opto(:,1), opto(:,2), opto(:,3))
                                    if startMove < cue
                                        movedEarly = 1;
                                        if strcmp(blk{t,2},'R')
                                            blk{t,5} = 'B';
                                        else
                                            blk{t,5} = 'E';
                                        end
                                    else
                                        blk{t,5} = 'G';
                                        % startMove = cue;
                                    end

                                    blk{t,7} = startMove;
                                    blk{t,8} = squeeze;
                                else
                                    blk{t,7} = 'NaN';
                                    blk{t,8} = 'NaN';
                                    blk{t,9} = 'NaN';
                                    blk{t,10} = 'NaN';
                                end
                            else
                                blk{t,4} = 'NaN';
                                blk{t,5} = 'NaN';
                                blk{t,6} = 'NaN';
                                blk{t,7} = 'NaN';
                                blk{t,8} = 'NaN';
                                blk{t,9} = 'NaN';
                                blk{t,10} = 'NaN';
                            end
                        end
    
                        if ~strcmp(blk{t,6},'B')
                            if ~exist('photodiode','var')
                                % Redefine variables
                                clear ballPress photodiode threshold timeSync photo squeeze
    
                                filename = listOfFiles(t).name;
                                copyFrom = [blockData filename];
                                load([blockData filename]);


                                if ~exist('threshold','var')
                                    threshold = 1.8;
                                end

                                fs = 200;
                                cutoff = 10;
                                [d1, c1] = butter(4, cutoff/(fs/2), 'low');
                                [d2, c2] = butter(4, [59 61]./(fs/2), 'stop');
                                ballPress  = filter(d1,c1,odau_array(:,1));
                                photodiode = filter(d2,c2,odau_array(:,2));
                                diodeThresh = 2;

                                if strcmp(blk{t,4},'B')
                                    inferDiode = 1;
                                else
                                    inferDiode = 0;
                                end
                                if strcmp(blk{t,5},'E')
                                    movedEarly = 1;
                                else
                                    movedEarly = 0;
                                end
                            end

                            % Change photodiode to one line at go cue for
                            % reach, stabilize, and correct
                            timePoints = NaN(4,1);
    
                            % Start and squeeze for reach
                            timePoints(1) = blk{t,7}; % Start move
                            timePoints(2) = blk{t,8}; % squeeze
                            [~, inferStartR, inferEndR] = processOptotrak(optotrak_array(timePoints(1):timePoints(2),:));
    
                            if stopFlag ~= -2
                                % Start of stabilization
                                photo = timePoints(2) + find(photodiode(timePoints(2):end) < diodeThresh);
                                drops = timePoints(2) + find(ballPress(timePoints(2):end,1) < 1.1);
                                df = diff(drops);
                                release = drops(find(df == 1, 1, 'first')+1);

                                if ~isempty(release) && sum(df == 1) >= size(df,1)*0.97
                                    release = drops(find(df == 1, 1, 'first')+1);
                                else
                                    release = -1;
                                end
    
                                if release == -1
                                    stabilize = NaN;
                                elseif isempty(photo) || length(photo) == length(ballPress)
                                    if exist('timeSync','var') && (timeSync(2)+500) < length(ballPress)
                                        stabilize = round(timeSync(3)) - 30;
                                    elseif (release+500) < size(ballPress)
                                        stabilize = release;
                                    else
                                        stabilize = NaN;
                                    end
                                elseif (photo(1)+500) < size(ballPress,1)
                                    stabilize = photo(1);
                                else
                                    stabilize = NaN;
                                end
                                timePoints(3) = stabilize;

                                if isnan(timePoints(3))
                                    inferStartS = 0;
                                    inferEndS = 0;
                                else
                                    [~, inferStartS, inferEndS] = processOptotrak(optotrak_array(timePoints(2):timePoints(3),:));
                                end
                            else
                                timePoints(3) = NaN;
                                inferStartS = 0;
                                inferEndS = 0;
                            end
    
                            % Start of correction
                            if stopFlag < -2 && ~isnan(stabilize)
                                photo = stabilize + find(photodiode(stabilize:end) < 2);
                                if isempty(photo)
                                    if exist('timeSync','var') && timeSync(4) < length(ballPress)
                                        correct = round(timeSync(4)) - 30;
                                        inferDiode = 1;
                                    elseif release + 600 < length(ballPress)
                                        % Else add 3 seconds
                                        correct = release + 600;
                                        inferDiode = 1;
                                    else
                                        correct = NaN;
                                    end
                                else
                                    correct = photo(1);
                                end
                                timePoints(4) = correct;
                                if isnan(timePoints(4))
                                    inferStartC = 0;
                                    inferEndC = 0;
                                else
                                    [~, inferStartC, inferEndC] = processOptotrak(optotrak_array(timePoints(3):timePoints(4),:));
                                end
                            else
                                timePoints(4) = NaN;
                                inferStartC = 0;
                                inferEndC = 0;
                            end
    
                            blk{t,9} = timePoints(3);
                            blk{t,10} = timePoints(4);

                            % Determine trial dimension
                            trialDimension = dims{b};
                            if ~exist('segment', 'var')
                                segment = NaN;
                            end
                            if ~exist('startFlag', 'var')
                                startFlag = NaN;
                            end

                            processedOdau  = [ballPress, photodiode];
                            processedOpto = processOptotrak(optotrak_array);
                            save([saveBlock filename],'processedOdau','processedOpto','segment','prevPx','prevUs',...
                                'targPx','targUs','timePoints','startFlag','stopFlag','trialDimension','threshold',...
                                'inferDiode','movedEarly','optotrak_array','odau_array',...
                                'inferStartR','inferEndR','inferStartS','inferEndS','inferStartC','inferEndC');
    
                        end
                    end
    
                    blkT = array2table(blk,'VariableNames',xlsNames);
                    if addBlock
                        T = [T; blkT];
                        trials = T;
                    else
                        trials = [trials; blkT];
                    end
                end
            end
    
            if overwrite || addBlock
                eval(sprintf('writeFile = [revDir ''%s_validTrials_rnm.xlsx''];',sub));
                if exist(writeFile, 'file')
                    delete(writeFile);
                end
    
                writetable(trials,writeFile);
                %disp('    written')
            end
        end
    
        % Copy Info file
        subData = [data subName '/'];
        subInfo = [subData '*.mat'];
        status = copyfile(subInfo, saveSub);
        addBlock = 0;
    end
end