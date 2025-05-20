% Author: Rocky Mazorow
% Date Created: 1/3/202
% Removed duplicate trials that were not subject initiated


function removeDupTrials(root, subs, blocks)

    % Location of data to search through and where to save
    data = [root 'raw_data/'];
    pRoot = [root 'Trails3D/p_data/'];
    mRoot = [root 'm_data/'];
    eRoot = [root 'removDup_data/'];
    
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
        
        if strcmp(sub(1),'W')
            blks = blocks(:,1);
        elseif strcmp(sub(1),'P')
            blks = blocks(:,2);
        end
    
        % Copy appropriate blocks over
        for b = 1:length(blks)
            disp(['  ' blks{b}])
            block = blks{b};
            blockType = block(1);
            blockData = [subData block '/'];

            % Check if block exists
            if ~exist(blockData, 'dir')
                disp('    No Block')
            else            
                if strcmp(blockType,'P')
                    saveBlock = [pRoot '/' subName '/' block '/'];
                elseif strcmp(blockType,'M')
                    saveBlock = [mRoot '/' subName '/' block '/'];
                else
                    saveBlock = [eRoot '/' subName '/' block '/'];
                end

                if ~exist(saveBlock, 'dir')
                    mkdir(saveBlock)
                else
                    delete([saveBlock '*.mat']);
                end
        
                listOfFiles = dir(fullfile(blockData,'*.mat'));
                numTrials = length(listOfFiles);
                if numTrials == 0
                    disp('    No Trials')
                else
                    prev = listOfFiles(1).name;
                    copyFrom = [blockData prev];
                    status = copyfile(copyFrom, saveBlock);
                    for t = 2:numTrials
                        curr = listOfFiles(t).name;
    
                        copyFrom = [blockData curr];
                        status = copyfile(copyFrom, saveBlock);
                        if str2double(prev(7:9)) == str2double(curr(7:9))
                            disp(['    Duplicate trial: ' curr(7:9)])
                            delete([saveBlock prev]);
                        end
                        prev = curr;
                    end
                end
            end
        end
        % Copy Info file
        %subInfo = [subData subName '_Info.mat'];
        subInfo = [subData '*.mat'];
        status = copyfile(subInfo, [pRoot '/' subName '/']);
        disp(['Copied ' subInfo ': ' num2str(status)])
        status = copyfile(subInfo, [mRoot '/' subName '/']);
        disp(['Copied ' subInfo ': ' num2str(status)])
        status = copyfile(subInfo, [eRoot '/' subName '/']);
        disp(['Copied ' subInfo ': ' num2str(status)])
    end
end
