function pos = pixToOptoCoord3sess(pixPos,Calib,grid)
    % if there is a 5x5x5 grid, add 1 so center is at 3
    guiGrid = 6;
    % Center represents pixels of screens center
    center = grid.scrDesc(2,:);
    center(3) = guiGrid/2*grid.pixPerCm;
    % compDim represents total space on the screen
    % Since we want to be a cube, let's make x and y the minimum
    % of screen height/width
    minD = min(grid.scrDesc(3,:));
    comDim = [minD minD];
    comDim(3) = guiGrid*grid.pixPerCm;

    % userDim represents total space user can move
    userDim = (Calib.errPad(2,:) - Calib.errPad(1,:));

    scale = comDim./userDim;
    % y+ in cartesian is actually a decrease in y pixel location
    scale(2) = -1*scale(2);
    pos = (pixPos - center) ./ scale;
    pos = round(pos,5);
end