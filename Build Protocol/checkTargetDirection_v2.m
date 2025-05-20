% Author: Rocky Mazorow
% Date Created: 4/13/2023

% Check number of target that involve yp, down, left, right movement.

function [n1,p1,n2,p2,n3,p3] = checkTargetDirection_v2(Trial,dim,ignore)
    if ~exist('ignore','var')
        ignore = -1;
    end

    if ~exist('dim','var')
        dim = 3;
    end

    if dim == 2
        % For 2D, we will consider x as dim1 and y as dim 2 regardless of
        % plane
        p1Index = 1;
        n1Index = 1;
        p2Index = 1;
        n2Index = 1;
        p1 = NaN(1,4);
        n1 = NaN(1,4);
        p2 = NaN(1,4);
        n2 = NaN(1,4);
        p3 = NaN(1,4);
        n3 = NaN(1,4);
    
        % Columns: session, total trial, block trial, previous target, current target
        prev = [3 3];
    
        for t=1:size(Trial,1)
            if ignore == 1 
                curr = [Trial(t,2) Trial(t,3)];
            elseif ignore == 2
                curr = [Trial(t,1) Trial(t,3)];
            elseif ignore == 3
                curr = [Trial(t,1) Trial(t,2)];
            else
                curr = [Trial(t,1) Trial(t,2) Trial(t,3)];
            end
    
            % Check dim 1
            if prev(1) < curr(1)
                p1(p1Index,:) = [prev(1) prev(2) curr(1) curr(2)];
                p1Index = p1Index + 1;
            end
    
            if prev(1) > curr(1)
                n1(n1Index,:) = [prev(1) prev(2) curr(1) curr(2)];
                n1Index = n1Index + 1;
            end
    
            % Check if left
            if prev(2) > curr(2)
                n2(n2Index,:) = [prev(1) prev(2) curr(1) curr(2)];
                n2Index = n2Index + 1;
            end
    
            % Check if right
            if prev(2) < curr(2)
                p2(p2Index,:) = [prev(1) prev(2) curr(1) curr(2)];
                p2Index = p2Index + 1;
            end
            prev = curr;
        end

    elseif dim == 3
        p1Index = 1;
        n1Index = 1;
        p2Index = 1;
        n2Index = 1;
        p3Index = 1;
        n3Index = 1;
        p1 = NaN(1,6);
        n1 = NaN(1,6);
        p2 = NaN(1,6);
        n2 = NaN(1,6);
        p3 = NaN(1,6);
        n3 = NaN(1,6);
    
        % Columns: session, total trial, block trial, previous target, current target
        prev = [3 3 3];
    
        for t=1:size(Trial,1)
            curr = [Trial(t,1) Trial(t,2) Trial(t,3)];
    
            % Check if left
            if prev(1) > curr(1)
                n1(n1Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                n1Index = n1Index + 1;
            end
    
            % Check if right
            if prev(1) < curr(1)
                p1(p1Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                p1Index = p1Index + 1;
            end

            % Check if up
            if prev(2) < curr(2)
                p2(p2Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                p2Index = p2Index + 1;
            end
    
            % Check if down
            if prev(2) > curr(2)
                n2(n2Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                n2Index = n2Index + 1;
            end
    
            % Check if out
            if prev(3) > curr(3)
                n3(n3Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                n3Index = n3Index + 1;
            end
    
            % Check if in
            if prev(3) < curr(3)
                p3(p3Index,:) = [prev(1) prev(2) prev(3) curr(1) curr(2) curr(3)];
                p3Index = p3Index + 1;
            end
    
            prev = curr;
        end
    end
end