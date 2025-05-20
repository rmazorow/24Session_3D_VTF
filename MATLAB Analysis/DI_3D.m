% Edited by Rocky Mazorow
% 5/25/2023
% Made it work with Optotrak data

function DIvalue = DI_3D(axis1,axis2,axis3,SampleRate)

cf_pos = 4;  % 4 Hz cf ends up making the data look nice when plotted..
[b,a] = butter(2, cf_pos/(SampleRate/2));
p1 = filtfilt(b,a,axis1);
p2 = filtfilt(b,a,axis2);
p3 = filtfilt(b,a,axis3);

% Compute velocity;
v1 = SampleRate*filtfilt(b,a,diff(p1)); % Data from the target are sampled at 200 Hz
v1 = filtfilt(b,a,v1);
v2 = SampleRate*filtfilt(b,a,diff(p2));
v2 = filtfilt(b,a,v2);
v3 = SampleRate*filtfilt(b,a,diff(p3));
v3 = filtfilt(b,a,v3);

notP1 = sqrt(v2.^2+v3.^2);
notP2 = sqrt(v1.^2+v3.^2);
notP3 = sqrt(v1.^2+v2.^2);

notMax1 = max(abs(notP1));
notMax2 = max(abs(notP2));
notMax3 = max(abs(notP3));
delta_1 = sum(abs(diff(p1)));
delta_2 = sum(abs(diff(p2)));
delta_3 = sum(abs(diff(p3)));

part1 = (abs(diff(p1)/delta_1).*(notMax1-abs(notP1))/notMax1);
part2 = (abs(diff(p2)/delta_2).*(notMax2-abs(notP2))/notMax2);
part3 = (abs(diff(p3)/delta_3).*(notMax3-abs(notP3))/notMax3);

DIvalue = 1/3*sum(part1+part2+part3);
