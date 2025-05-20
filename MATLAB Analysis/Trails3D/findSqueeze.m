% Author: Rocky Mazorow
% Date Created: 8/19/2024

% returns all sample rows above squeeze threshols

function didSqueeze = findSqueeze(odau, maxSqz)   
    threshold = 1.2;
    smooth = smoothdata(odau,'movmean',5);
    didSqueeze = find(smooth > threshold);
end