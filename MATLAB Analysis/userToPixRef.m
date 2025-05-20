function pixPos = userToPixRef(userPos,Calib)
    % Define min and max for screen and optotrak
    MIN_X = 215;
    MAX_X = 809;
    MIN_Y = 87;
    MAX_Y = 681;
    MIN_Z = 27;
    MAX_Z = 121.5;
    user = Calib.userEdge;

    % Find polynomial coefficients
    coX = polyfit([user(1,1) user(2,1)], [MIN_X MAX_X], 1);
    coY = polyfit([user(2,2) user(1,2)], [MIN_Y MAX_Y], 1);
    coZ = polyfit([user(1,3) user(2,3)], [MIN_Z MAX_Z], 1);

    % Translate position
    len = size(userPos,1);
    for l = 1:len
        currX = userPos(l,1);
        currY = userPos(l,2);
        currZ = userPos(l,3);
    
        pixPos(l,1) = currX*coX(1) + coX(2);
        pixPos(l,2) = currY*coY(1) + coY(2);
        pixPos(l,3) = currZ*coZ(1) + coZ(2);
    
        pixPos(l,:) = round(pixPos(l,:) * 10000) / 10000;
    end
end