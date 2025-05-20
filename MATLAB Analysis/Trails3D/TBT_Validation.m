% Author: Rocky Mazorow
% Date Created: 8/22/2024

% This script visually shows the results of the Trails B inspired task

clear
clc

good = [0 0.6470 0.6410];
correction = [0.9290 0.6940 0.1250];
error = [0.7350 0.0780 0.0840];

% Plot figure
figure
%centers = [target(:,1) target(:,2)];
%radii = width;
% Fix the axis limits.
xlim([-70 70])
ylim([-70 70])
% Set the axis aspect ratio to 1:1.
axis square
% Display the circles.
%viscircles(centers,radii,'Color','k'); 
circles(targets(:,1),targets(:,2),targets(:,3),'facecolor','none','edgecolor','black')
hold on;
circles(sqzAt(:,1),sqzAt(:,2),sqzAt(:,3),'color',good)
text(letters(:,1),letters(:,2),letterOrder,'FontSize',14, ...
    'HorizontalAlignment','center','VerticalAlignment','middle')
text(sqzAt(:,1),sqzAt(:,2),num2cell(1:length(sqzAt)),'FontSize',14,'color','white', ...
    'HorizontalAlignment','center','VerticalAlignment','middle')
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);