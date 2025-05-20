% Randomly select targets for trial order
% Author: Rocky Mazorow
% Date Created: 2/7/2023

minZ = 1.5;
maxZ = 6;

targets = zeros(125,3);
xR = zeros(5,3);
yR = zeros(5,3);
zR = zeros(5,3);
xy = zeros(25,3);
yz = zeros(25,3);
zx = zeros(25,3);
index = 1;
xrow = 1;
yrow = 1;
zrow = 1;
xyrow = 1;
yzrow = 1;
zxrow = 1;

shift = (maxZ - minZ)/5;

for x=1:5
    for y=1:5
        for z=1:5
            targets(index,:) = [x y z];
            index = index + 1;

            if z==3 
                xy(xyrow,:) = [x y z];
                xyrow = xyrow + 1;
                if y==3
                    xR(xrow,:) = [x y z];
                    xrow = xrow + 1;
                end
            end
            if x==3
                yz(yzrow,:) = [x y z];
                yzrow = yzrow + 1;
                if z==3
                    yR(yrow,:) = [x y z];
                    yrow = yrow + 1;
                end
            end
            if y==3
                zx(zxrow,:) = [x y z];
                zxrow = zxrow + 1;
                if x==3
                    zR(zrow,:) = [x y z];
                    zrow = zrow + 1;
                end
            end
        end
    end
end

%% Define test-only and training-only targets
% From a 5x5x5 grid, define 25 test-only targets and put the rest in a
% training matrix.
% columns = {x,y,z}\

% Train targets needs to have the lowest, furthest target from reaching
% hand. All others will be built around this location.
% 
% Fixed 4/16/2024
% testTargs = [1 1 4; ...
%               1 2 3; ...
%               1 3 2; ...
%               1 4 1; ...
%               1 5 5; ...
% 
%               2 1 3; ...
%               2 2 2; ...
%               2 3 1; ...
%               2 4 5; ...
%               2 5 4; ...
% 
%               3 1 5; ...
%               3 2 4; ...
%               3 3 3; ...
%               3 4 2; ...
%               3 5 1; ...
% 
%               4 1 2; ...
%               4 2 1; ...
%               4 3 5; ...
%               4 4 4; ...
%               4 5 3; ...
% 
%               5 1 1; ...
%               5 2 5; ...
%               5 3 4; ...
%               5 4 3; ...
%               5 5 2];

testTargs = [1 1 2; ...
             1 2 3; ...
             1 3 4; ...
             1 4 5; ...
             1 5 1; ...

             2 1 3; ...
             2 2 4; ...
             2 3 5; ...
             2 4 1; ...
             2 5 2; ...

             3 1 1; ...
             3 2 2; ...
             3 3 3; ...
             3 4 4; ...
             3 5 5; ...

             4 1 4; ...
             4 2 5; ...
             4 3 1; ...
             4 4 2; ...
             4 5 3; ...

             5 1 5; ...
             5 2 1; ...
             5 3 2; ...
             5 4 3; ...
             5 5 4];

% Flip across z-axis for left hand moving...
%testTargs_left = testTargs_right;
%testTargs_left(:,1) = 5 - testTargs_right(:,1) + 1;


% Create array for train-only targets
x = setdiff(xR, testTargs, 'rows');
y = setdiff(yR, testTargs, 'rows');
z = setdiff(zR, testTargs, 'rows');
train1Targs.x = x;
train1Targs.y = y;
train1Targs.z = z;

xy = setdiff(xy, testTargs, 'rows');
yz = setdiff(yz, testTargs, 'rows');
zx = setdiff(zx, testTargs, 'rows');
train2Targs.xy = xy;
train2Targs.yz = yz;
train2Targs.zx = zx;

train3Targs = setdiff(targets, testTargs, 'rows');

% Save right handed targets
testTargs_right   = testTargs;
train1Targs_right = train1Targs;
train2Targs_right = train2Targs;
train3Targs_right = train3Targs;


% Save left handed targets
testTargs_left   = testTargs_right;
testTargs_left(:,1) = 6 - testTargs_right(:,1);
train1Targs_left = train1Targs_right;
train1Targs_left.x(:,1) = 6 - train1Targs_right.x(:,1);
train2Targs_left = train2Targs_right;
train2Targs_left.xy(:,1) = 6 - train2Targs_right.xy(:,1);
train2Targs_left.zx(:,1) = 6 - train2Targs_right.zx(:,1);
train3Targs_left = train3Targs_right;
train3Targs_left(:,1) = 6 - train3Targs_right(:,1);

% Save arrays
save("gridTargets.mat", "testTargs_right", "train1Targs_right", "train2Targs_right", "train3Targs_right", ...
        "testTargs_left", "train1Targs_left", "train2Targs_left", "train3Targs_left");
