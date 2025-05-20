% Author: Rocky Mazorow
% Date Created: 4/19/2024
% 
% Randomly generate numTrials targets from list that do not repeat and
% are not a neighbor of previous target
% Dims will determine the minimum error
%    1 = 1D (x);   minDist = sqrt(1)
%    2 = 2D (xy);  minDist = sqrt(2)
%    3 = 3D (xyz); minDist = sqrt(3)

function random = ShuffleTargets(targs,numTrials,dims)

    % Create trial length list and shuffle target list
    mult = ceil(numTrials / length(targs));
    targets = repmat(targs,mult,1);
    targets = targets(1:numTrials,:);
    random = targets(randperm(size(targets, 1)), :);
    isNeighbor = true;
    tries = 1;

    % Set minimum next target distance
    if dims == 2
        minDist = sqrt(2);
        cutoff = 100;
    elseif dims == 3
        minDist = sqrt(3);
        cutoff = 20;
    else
        minDist = 0;
        cutoff = 100;
    end

    % Go through list, if next item is neighbor, swap with random position
    % and recheck
    while isNeighbor
        if tries > cutoff
            random = targets(randperm(size(targets, 1)), :);
            tries = 1;
        end

        isNeighbor = false;
        for t=1:numTrials    
            % Load previous and current target. If starting, assume prev=home
            if t == 1
                p = [3,3,3];
            else
                p = random(t-1,:);
            end
            c = random(t,:);
            % disp(['p= (' num2str(p(1)) ',' num2str(p(2)) ',' num2str(p(3)) ')'])
            % disp(['c= (' num2str(c(1)) ',' num2str(c(2)) ',' num2str(c(3)) ')'])
            % disp('')
    
            % Check if neighbor (distance<2)
            dist = sqrt((p(1) - c(1))^2 + (p(2) - c(2))^2 + (p(3) - c(3))^2);
            if dist <= minDist
                %disp(['   Try: ' num2str(tries) ', ' num2str(dist)])
                isNeighbor = true;

                % Swap with other row
                r = randi([1,numTrials]);
                random(t,:) = random(r,:);
                random(r,:) = c;
                tries = tries + 1;
                % Break out of for and recheck
                break;
            end
        end
    end

    random = random(1:numTrials,:);
end