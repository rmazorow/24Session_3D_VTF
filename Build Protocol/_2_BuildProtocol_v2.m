% Author: Rocky Mazorow
% Date Created: 4/4/2023

% Build protocol for right hand moving...
% Then flip along x=3 (6 total length) for left hand moving
%     left = right;
%     left(:,1) = 6 - right(:,1);

% Creates a table holding following trial parameters and writes to csv:
%   SessionNum  - Should match name of file
%   TotalTrial  - Trial number of whole experiment
%   BlockName   - V = Vis to shown target, R = Vis to remembered target, N = Intrinsic, C = VTF 3D Training, T = VTF Test, S = Sham, M = table-mouth-table
%   BlockTrial  - Trial number of specific block
%   TriTn2e     - 0 = test, 1 = training, 2 = table-mouth-table
%   VisFb       - 0 = no, 1 = yes
%   VTFx        - 0 = no, 1 = yes
%   VTFy        - 0 = no, 1 = yes
%   VTFz        - 0 = no, 1 = yes
%   TargX       - Target's x location as reference to 5x5x5 cube
%   TargY       - Target's y location as reference to 5x5x5 cube
%   TargZ       - Target's z location as reference to 5x5x5 cube

clear
clc

% Name protocol (Test or Prac)
proto = 'Test';
version = '_v2';

% Name experiment (W = whole field, P = partial field)
exp = {'W' 'P'};
dim = ['x','y','z'];
block = '';
stopFlag = false;

% Load targets and shorten name
load("gridTargets.mat");

% Set order of 1D and 2D reaches
nums = 200;
for day = 1:6
    % 1D
    disp(['1D: Day ' num2str(day)])
    random = ShuffleTargets(train1Targs_right.x,nums,1);
    eval(sprintf('targs1D_%d = random;',day+1))

    % 2D
    good = false;
    disp(['2D: Day ' num2str(day)])
    while ~good
        random = ShuffleTargets(train2Targs_right.xy,nums,2);

        % Check the direction of each target for balance
        [n1_2,p1_2,n2_2,p2_2,n3_2,p3_2] = checkTargetDirection_v2(random,2,3);   
    
        % disp(['x-: ' num2str(size(n1T,1))])
        % disp(['x+: ' num2str(size(p1T,1))])
        % disp(['y-: ' num2str(size(n2T,1))])
        % disp(['y+: ' num2str(size(p2T,1))])
        
        if (size(n1_2,1)<25 || size(p1_2,1)<25 || size(n2_2,1)<25 || size(p2_2,1)<25 || ...
                abs(size(n1_2,1)-size(p1_2,1))>2 || abs(size(n2_2,1)-size(p2_2,1))>2)
            good = false;
            disp('      redo B')
        else
            good = true;
            disp('      good')
        end
    end

    eval(sprintf('targs2D_%d = random;',day+8));
end

% Run whole field study first
for e = 1:2
    if stopFlag == true
        break;
    end

    if strcmp(exp{e},'P')
        group = 3;
    else
        group =  1;
    end
    
    for g = 1:group
        disp(['determining experiment ' exp{e} ' ' num2str(g) '...'])
        % Load protocol details
        if strcmp(proto,'Prac')
            if strcmp(exp{e},'W')
                [Sess,BlockName,NumTrials,TrialType,FieldMove,VisFB,VTF] = readvars('Protocols_Plans/Whole_Practice_Protocol.xlsx','Sheet','Sheet1','Range','A2:H25');
            elseif strcmp(exp{e},'P')
                [Sess,BlockName,NumTrials,TrialType,FieldMove,VisFB,VTF] = readvars(['Protocols_Plans/Part_Practice_Protocol_' num2str(g) '.xlsx'],'Sheet','Sheet1','Range','A2:H25');
            end
        elseif strcmp(proto,'Test')
            if strcmp(exp{e},'W')
                [Sess,BlockName,NumTrials,TrialType,FieldMove,VisFB,VTF] = readvars('Protocols_Plans/Whole_Test_Protocol.xlsx','Sheet','Sheet1','Range','A2:H44');
            elseif strcmp(exp{e},'P')
                [Sess,BlockName,NumTrials,TrialType,FieldMove,VisFB,VTF] = readvars(['Protocols_Plans/Part_Test_Protocol_' num2str(g) '.xlsx'],'Sheet','Sheet1','Range','A2:H44');
            end
        end
    
        numSess = max(Sess);
        total = 1;
    
        % keep track of test and C train days to make two protocols match
        tsRow = 1;
        t1Row = 1;
        t2Row = 1;
        t3Row = 1;
        
        for s=1:numSess
            if stopFlag == true
                break;
            end
    
            disp(['determining session ' num2str(s) '...'])
            clear TrialParams TrialParams1 TrialParams2 TrialParams3 TrialParams_left blocks move;
            inSess = find(Sess==s);
            start = inSess(1);
            stop = inSess(end);
            index = 1;
        
            b = start;
            while b <= stop
                if stopFlag == true
                    break;
                end
    
                pBlock = block;
                bName = [BlockName{b} '_' num2str(s,'%02d')];
                block = BlockName{b};
                if ~strcmp(pBlock,block)
                    disp(['    determining block ' bName '...'])
                end
                indB = index;
                totB = total;
    
                % If test block
                if TrialType(b) == 0
                    if strcmp(exp{e},'P')
                        targs = WholeProto(testInd(tsRow,1):testInd(tsRow,2),9:11);
                        tsRow = tsRow + 1;
                        if VTF(b) == 0
                            VT = [0 0 0];
                        else
                            VT = [1 1 1];
                        end
                    else
                        targs = ShuffleTargets(testTargs_right,NumTrials(b),3);
                        testInd(tsRow,:) = [total total+NumTrials(b)-1];
                        tsRow = tsRow + 1;
                        if VTF(b) == 0
                            VT = [0 0 0];
                        else
                            VT = [1 1 1];
                        end
                    end
            
                % If train block
                elseif TrialType(b) == 1
                    if strcmp(exp{e},'P')
                        if strcmp(block(1),'A')
                            if strcmp(FieldMove(b),'x')
                                eval(sprintf('targs = targs1D_%d;',s));
                                VT = [1 0 0]; 
                            elseif strcmp(FieldMove(b),'y')
                                eval(sprintf('temp = targs1D_%d;',s));
                                targs = [temp(:,3) temp(:,1) temp(:,2)];
                                VT = [0 1 0]; 
                            elseif strcmp(FieldMove(b),'z')
                                eval(sprintf('temp = targs1D_%d;',s));
                                targs = [temp(:,2) temp(:,3) temp(:,1)];
                                VT = [0 0 1]; 
                            end
                        elseif strcmp(block(1),'B')
                            if strcmp(FieldMove(b),'xy')
                                eval(sprintf('targs = targs2D_%d;',s));
                                VT = [1 1 0]; 
                            elseif strcmp(FieldMove(b),'yz')
                                eval(sprintf('temp = targs2D_%d;',s));
                                targs = [temp(:,3) temp(:,1) temp(:,2)];
                                VT = [0 1 1]; 
                            elseif strcmp(FieldMove(b),'zx')
                                eval(sprintf('temp = targs2D_%d;',s));
                                targs = [temp(:,2) temp(:,3) temp(:,1)];
                                VT = [1 0 1]; 
                            end
                        elseif strcmp(block(1),'C')
                            targs = WholeProto(trn3Ind(t3Row,1):trn3Ind(t3Row,2),9:11);
                            t3Row = t3Row + 1;
                            VT = [1 1 1]; 
                        end
                    else
                        targs = ShuffleTargets(train3Targs_right,NumTrials(b),3);
                        trn3Ind(t3Row,:) = [total total+NumTrials(b)-1];
                        t3Row = t3Row + 1;
                        VT = [1 1 1]; 
                    end
                        
                % If table to mouth
                elseif TrialType(b) == 2
                    targs = repmat([1 5 1],[NumTrials(b) 1]);
                    VT = [1 1 1];
        
                % If trail making
                elseif TrialType(b) == 3
                    targs = repmat([NaN NaN NaN],[NumTrials(b) 1]);
                    VT = [1 1 1];
                end
        

                n1 = NaN(1,6);
                p1 = NaN(1,6);
                n2 = NaN(1,6);
                p2 = NaN(1,6);
                n3 = NaN(1,6);
                p3 = NaN(1,6);

                for t=1:NumTrials(b)
                    if strcmp(exp{e},'P')                    
                        PartsProto(total,:)  = [s,total,t,TrialType(b),VisFB(b),VT(1),VT(2),VT(3),targs(t,1),targs(t,2),targs(t,3)];
                        parts_blocks(total,1) = string(bName);
                        parts_move(total,1) = string(FieldMove(b));
                    else
                        WholeProto(total,:)  = [s,total,t,TrialType(b),VisFB(b),VT(1),VT(2),VT(3),targs(t,1),targs(t,2),targs(t,3)];
                        whole_blocks(total,1) = string(bName);
                        whole_move(total,1) = string(FieldMove(b));
                    end
                    TrialParams(index,:) = [s,total,t,TrialType(b),VisFB(b),VT(1),VT(2),VT(3),targs(t,1),targs(t,2),targs(t,3)];
                    blocks(index,1) = string(bName);
                    move(index,1) = string(FieldMove(b));
                    index = index+1;
                    total = total+1;
                end
                
                if TrialType(b) == 0 || TrialType(b) == 1
                    if strcmp(block(1),'C')
                        % Check the direction of each target for balance
                        [n1_3,p1_3,n2_3,p2_3,n3_3,p3_3] = checkTargetDirection_v2(TrialParams(index-NumTrials(b):end,9:11));
                
                        if ~strcmp(proto,'Prac')
                            if (size(n1_3,1)<9 || size(p1_3,1)<9 || size(n2_3,1)<9 || size(p2_3,1)<9 || size(n3_3,1)<9 || size(p3_3,1)<9 ||...
                                    abs(size(n1_3,1)-size(p1_3,1))>2 || abs(size(n2_3,1)-size(p2_3,1))>2 || abs(size(n3_3,1)-size(p3_3,1))>2)
                                b = b - 1;
                                index = indB;
                                total = totB;
                                disp('      redo C')
                            else
                                n1 = [n1; n1_3];
                                p1 = [p1; p1_3];
                                n2 = [n2; n2_3];
                                p2 = [p2; p2_3];
                                n3 = [n3; n3_3];
                                p3 = [p3; p3_3];
                                disp('      good')
                            end
                        else
                            if (size(n1_3,1)<25 || size(p1_3,1)<25 || size(n2_3,1)<25 || size(p2_3,1)<25 || size(n3_3,1)<25 || size(p3_3,1)<25 ||...
                                    abs(size(n1_3,1)-size(p1_3,1))>2 || abs(size(n2_3,1)-size(p2_3,1))>2 || abs(size(n3_3,1)-size(p3_3,1))>2)
                                b = b - 1;
                                index = indB;
                                total = totB;
                                disp('      redo C')
                            else
                                n1 = [n1; n1_3];
                                p1 = [p1; p1_3];
                                n2 = [n2; n2_3];
                                p2 = [p2; p2_3];
                                n3 = [n3; n3_3];
                                p3 = [p3; p3_3];
                                disp('      good')
                            end
                            %stopFlag = true;
                        end
                    end
                end
                b = b+1;
            end

            if strcmp(exp{e},'P') && g == 1
                PartProto_1 = PartsProto;
            end
        
            % Check that folder exists (or make new folder) for experiment
            if strcmp(proto,'Prac')
                dirName = [exp{e} '_Prac_Protocol'];
            else
                dirName = [exp{e} num2str(numSess) '_Protocol_v2'];
            end
            if ~exist(dirName, 'dir')
               mkdir(dirName)
            end
            names = {'SessionNum','TotalTrial','BlockTrial','TrialType','VisFb','VTFx','VTFy','VTFz','TargX','TargY','TargZ'};
        
            % Save specific groups if part training
            if strcmp(exp{e},'P')
                sessName = [exp{e} dim(g) num2str(numSess) '_Session' num2str(s)];
    
                % Save right moving data
                tbl1 = array2table(TrialParams,'VariableNames',names);
                tbl1.BlockName = blocks;
                tbl1.FieldMove = move;
                tbl1 = movevars(tbl1,'BlockName','After','TotalTrial');
                tbl1 = movevars(tbl1,'FieldMove','After','TrialType');
                writetable(tbl1,[dirName '/' sessName '_right' version '.csv'],'Delimiter',',');
                
                % Save left moving data
                TrialParams_left = TrialParams;
                TrialParams_left(:,9) = 6 - TrialParams(:,9);
                
                tbl2 = array2table(TrialParams_left,'VariableNames',names);
                tbl2.BlockName = blocks;
                tbl2.FieldMove = move;
                tbl2 = movevars(tbl2,'BlockName','After','TotalTrial');
                tbl2 = movevars(tbl2,'FieldMove','After','TrialType');
                writetable(tbl2,[dirName '/' sessName '_left' version '.csv'],'Delimiter',',');
            else
                % Save right moving data
                sessName = [exp{e} num2str(numSess) '_Session' num2str(s)];
                filename = [dirName '/' sessName];
                tbl1 = array2table(TrialParams,'VariableNames',names);
                tbl1.BlockName = blocks;
                tbl1.FieldMove = move;
                tbl1 = movevars(tbl1,'BlockName','After','TotalTrial');
                tbl1 = movevars(tbl1,'FieldMove','After','TrialType');
                writetable(tbl1,[filename  '_right' version '.csv'],'Delimiter',',');
                
                % Save left moving data
                TrialParams_left = TrialParams;
                TrialParams_left(:,9) = 6 - TrialParams(:,9);
                
                tbl2 = array2table(TrialParams_left,'VariableNames',names);
                tbl2.BlockName = blocks;
                tbl2.FieldMove = move;
                tbl2 = movevars(tbl2,'BlockName','After','TotalTrial');
                tbl2 = movevars(tbl2,'FieldMove','After','TrialType');
                writetable(tbl2,[filename  '_left' version '.csv'],'Delimiter',',');
            end
        end

        % Write total protocols
        if strcmp(exp{e},'W')
            Whole = array2table(WholeProto,'VariableNames',names);
            Whole.BlockName = whole_blocks;
            Whole.FieldMove = whole_move;
            Whole = movevars(Whole,'BlockName','After','TotalTrial');
            Whole = movevars(Whole,'FieldMove','After','TrialType');
        elseif strcmp(exp{e},'P')
            Parts = array2table(PartsProto,'VariableNames',names);
            Parts.BlockName = parts_blocks;
            Parts.FieldMove = parts_move;
            Parts = movevars(Parts,'BlockName','After','TotalTrial');
            Parts = movevars(Parts,'FieldMove','After','TrialType');
            eval(sprintf('Parts_%d = Parts;',g));
        end
        
    end
end

if stopFlag == false
    save(['ProtocolTarget' version], 'Whole', 'Parts_1', 'Parts_2', 'Parts_3');
    disp('Saved!')
end
