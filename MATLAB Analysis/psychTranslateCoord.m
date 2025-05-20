function pixPos = psychTranslateCoord(pos,Calib,grid)
    MIN_X = grid.xpos(1);
    MAX_X = grid.xpos(5);
    MIN_Y = grid.ypos(1);
    MAX_Y = grid.ypos(5);
    MIN_Z = grid.zpos(1);
    MAX_Z = grid.zpos(5);

    user = Calib.userEdge;
    currX = pos(1);
    currY = pos(2);
    currZ = pos(3);
    
    % find polynomial coefficients
    coX = polyfit([user(1,1) user(2,1)], [MIN_X MAX_X], 1);
    coY = polyfit([user(2,2) user(1,2)], [MIN_Y MAX_Y], 1);
    coZ = polyfit([user(1,3) user(2,3)], [MIN_Z MAX_Z], 1);
    
    pixPos(1) = currX*coX(1) + coX(2);
    pixPos(2) = currY*coY(1) + coY(2);
    pixPos(3) = currZ*coZ(1) + coZ(2);
end