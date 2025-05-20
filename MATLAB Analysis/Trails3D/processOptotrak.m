% The raw data for optotrak flips x and y, so we need to correct this
% before analyzing
function [opto, interFirst, interLast] = processOptotrak(optotrak)

    interFirst = 0;
    interLast  = 0;
    
    % Switch optotrak columns and calc means
    ireds = optotrak(:,10:end);
    ireds(abs(ireds) > 10^6,:) = NaN;
    isPerfect = sum(isnan(ireds));
    if any(isPerfect == 0)
        if isPerfect(1) ~= 0
            ireds(:,1:3) = NaN;
        end
        if isPerfect(4) ~= 0
            ireds(:,4:6) = NaN;
        end
        if isPerfect(7) ~= 0
            ireds(:,7:9) = NaN;
        end
    end
    opto(:,2) = mean(ireds(:,1:3:end),2,'omitnan');
    opto(:,1) = mean(ireds(:,2:3:end),2,'omitnan');
    opto(:,3) = -1*mean(ireds(:,3:3:end),2,'omitnan');
    
    % Interpolate missing data
    if any(isnan(opto))
        x = opto(:,1);
        y = opto(:,2);
        z = opto(:,3);
    
        %figure;
        %subplot(2,1,1)
        %plot(1:length(x),x,1:length(y),y,1:length(z),z)
    
        if isnan(x(1)) || isnan(x(end))
            if isnan(x(1))
                interFirst = 1;
                start = find(~isnan(x),1,'first');
                x(1:start) = fillmissing(x(1:start),'spline','EndValues','nearest');
                y(1:start) = fillmissing(y(1:start),'spline','EndValues','nearest');
                z(1:start) = fillmissing(z(1:start),'spline','EndValues','nearest');
            else
                start = 1;
            end
    
            if isnan(x(end))
                interLast = 1;
                stop = find(~isnan(x),1,'last');
                x(stop:end) = fillmissing(x(stop:end),'spline','EndValues','nearest');
                y(stop:end) = fillmissing(y(stop:end),'spline','EndValues','nearest');
                z(stop:end) = fillmissing(z(stop:end),'spline','EndValues','nearest');
            else
                stop = length(x);
            end
            
            x(start:stop) = fillmissing(x(start:stop),'spline');
            y(start:stop) = fillmissing(y(start:stop),'spline');
            z(start:stop) = fillmissing(z(start:stop),'spline');
        else
            x = fillmissing(x,'spline');
            y = fillmissing(y,'spline');
            z = fillmissing(z,'spline');
        end
    
        %subplot(2,1,2)
        %plot(1:length(x),x,1:length(y),y,1:length(z),z)
    
        opto(:,1) = x;
        opto(:,2) = y;
        opto(:,3) = z;
    end
end