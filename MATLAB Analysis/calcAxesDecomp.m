% Author: Rocky Mazorow
% Date Created: 4/23/2023

function [axes,total,axesPerSamp,totalPerSamp] = calcAxesDecomp(movements)
    % Define variables
    dims = size(movements,2);
    length = size(movements,1)-1;
    axesPerSamp = NaN(length,dims);
    totalPerSamp = NaN(length,1);
    line = [1 1] / sqrt(2);
    unitM = line(1);

    if length < 1
        axes = NaN(1,dims);
        total = NaN;
    else
        % Create unit vectors for each axes
        if dims == 2
            unitX = [1 0];
            unitY = [0 1];  
        elseif dims == 3
            unitX = [1 0 0];
            unitY = [0 1 0];
            unitZ = [0 0 1];
        end
    
        for i=1:length
            vect = abs(movements(i+1,:) - movements(i,:));
            if dims == 2
                mag  = sqrt(vect(1)^2 + vect(2)^2);
            elseif dims == 3
                mag  = sqrt(vect(1)^2 + vect(2)^2 + vect(3)^2);
            end
            unit = vect/mag;
    
            % dot product of each axis
            axesPerSamp(i,1) = dot(unit, unitX);
            axesPerSamp(i,2) = dot(unit, unitY);
            if dims == 3
                axesPerSamp(i,3) = dot(unit, unitZ);
            end
    
            if dims == 2 
                samp = 1-(axesPerSamp(i,1) * axesPerSamp(i,2)) / unitM^2;
                % Round to 3 decimal places
                totalPerSamp(i,1) = round(samp*10000)/10000;
            elseif dims == 3
                samp = 1-(axesPerSamp(i,1) * axesPerSamp(i,2) * axesPerSamp(i,3)) / unitM^3;  
                totalPerSamp(i,1) = round(samp*10000)/10000;
            end
        end
    
        axes = mean(axesPerSamp,'omitnan');
        total = mean(totalPerSamp,'omitnan');
    end
end