function pos = pixToOptoCoord(pixPos,Calib,grid)
    MIN_X = grid.xpos(1);
    MAX_X = grid.xpos(5);
    MIN_Y = grid.ypos(1);
    MAX_Y = grid.ypos(5);
    MIN_Z = grid.zpos(1);
    MAX_Z = grid.zpos(5);

    user = Calib.userEdge;
    currX = pixPos(1);
    currY = pixPos(2);
    currZ = pixPos(3);
    
    % find polynomial coefficients
    coX = polyfit([MIN_X MAX_X], [user(1,1) user(2,1)], 1);
    coY = polyfit([MIN_Y MAX_Y], [user(2,2) user(1,2)], 1);
    coZ = polyfit([MIN_Z MAX_Z], [user(1,3) user(2,3)], 1);
    
    pos(1) = currX*coX(1) + coX(2);
    pos(2) = currY*coY(1) + coY(2);
    pos(3) = currZ*coZ(1) + coZ(2);
    
    pos = round(pos * 10000) / 10000;
end