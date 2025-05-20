% Edited by Rocky Mazorow
% 4/19/2023
% Made it work with Optotrak data

function DI_all = DIalgorithm_3D(MoveData)
% algorithm to connvert data from endpoinnt coordinates into joint angle
% coordinnates.
% outputs DI values for joint encoding (DIj) and endpoint encoding (DIe).
% input: some portionn of the TARGETDATA matrix
%
% R Scheidt & R Rayes
% 3/15/22

%MoveData = MoveData(~isnan(MoveData(:,1)),:);
xPos = MoveData(:,1);
yPos = MoveData(:,2);
zPos = MoveData(:,3);

% Determine how many out of sight groupings there are
nans = find(isnan(xPos));
if length(nans) == length(xPos)
    DI_all = NaN;
elseif ~isempty(nans)
    if nans(1) > 1
        groups(1,:) = [1 nans(1)-1];
        count = 2;
    else
        count = 1;
    end
    for i=1:length(nans)-1
        if nans(i+1) - nans(i) > 1
            groups(count,1) = nans(i)+1;
            groups(count,2) = nans(i+1)-1;
            count = count + 1;
        end
    end
    if nans(end) < length(xPos)
        groups(count,:) = [nans(i+1)+1 length(xPos)];
    end

    DIs = NaN(size(groups,1),3);
    for d = 1:size(groups,1)
        if (groups(d,2) - groups(d,1)) > 6
            x = xPos(groups(d,1):groups(d,2));
            y = yPos(groups(d,1):groups(d,2));
            z = zPos(groups(d,1):groups(d,2));
            DIs(d,1) = DI_3D(x,y,z,200);
        end
    end
    DI_all = mean(DIs,'omitnan');
    DI_all = DI_all(1);
else
    DI_all = DI_3D(xPos,yPos,zPos,200);
    DI_all = DI_all(1);
end