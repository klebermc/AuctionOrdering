
clear
clc
close all
i=1;

% The data files are in data/ at the repository root; the path is rebuilt in
% each load because the clearvars calls below would wipe a path variable.
load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'experiment_1.mat'))
mean(delta_battery.Variables)
median(delta_battery.Variables)

% figure(i);
% i=i+1;
% subplot(2,5,1); histogram(delta_battery.("mean random"),10); title("mean random");
% subplot(2,5,2); histogram(delta_battery.("median random"),10);title("median random");
% subplot(2,5,3); histogram(delta_battery.("std random"),10);title("std random");
% subplot(2,5,4); histogram(delta_battery.("min random"),10);title("min random");
% subplot(2,5,5); histogram(delta_battery.("max random"),10);title("max random");
% subplot(2,5,6); histogram(delta_battery.("mean auction"),10); title("mean auction");
% subplot(2,5,7); histogram(delta_battery.("median auction"),10);title("median auction");
% subplot(2,5,8); histogram(delta_battery.("std auction"),10);title("std auction");
% subplot(2,5,9); histogram(delta_battery.("min auction"),10);title("min auction");
% subplot(2,5,10); histogram(delta_battery.("max auction"),10);title("max auction");
% figure(i);
% i=i+1;
% subplot(1,4,1);normplot(delta_battery.("mean auction"))
% subplot(1,4,2);normplot(delta_battery.("mean random"))
% subplot(1,4,3);normplot(delta_battery.("median auction"))
% subplot(1,4,4);normplot(delta_battery.("median random"))

f=figure(i);
i=i+1;
f.Units='pixels';
f.OuterPosition=[1960,1168,560,422];
hist([delta_battery.("mean random") , delta_battery.("mean auction")]*100 ,8); legend("Random selection","Auction-based strategy");
xlabel('Battery usage, $\bar{bat}_R~[\%]$', 'Interpreter','latex', 'FontSize', 18)
ylabel("Frequency", 'Interpreter','latex', 'FontSize', 18)
ax = gca;
exportgraphics(ax,'histogram_bat_usage.pdf')

f=figure(i);
i=i+1;
f.Units='pixels';
f.OuterPosition=[2130,700,466,401];
boxplot([delta_battery.("mean random") , delta_battery.("mean auction")]*100, 'labels',{'Random','Auction-based'})
ylabel('Battery usage, $\bar{bat}_R~[\%]$', 'Interpreter','latex', 'FontSize', 18)
ax = gca;
ax.TickLabelInterpreter='latex';
ax.FontSize=18;
exportgraphics(ax,'TA_boxplot_experiment1.pdf')



%% experiment 2

clearvars -except i
load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'experiment_2.mat'))
mean(delta_battery.Variables)
median(delta_battery.Variables)

% figure(i);
% i=i+1;
% subplot(2,5,1); histogram(delta_battery.("mean random"),10); title("mean random");
% subplot(2,5,2); histogram(delta_battery.("median random"),10);title("median random");
% subplot(2,5,3); histogram(delta_battery.("std random"),10);title("std random");
% subplot(2,5,4); histogram(delta_battery.("min random"),10);title("min random");
% subplot(2,5,5); histogram(delta_battery.("max random"),10);title("max random");
% subplot(2,5,6); histogram(delta_battery.("mean auction"),10); title("mean auction");
% subplot(2,5,7); histogram(delta_battery.("median auction"),10);title("median auction");
% subplot(2,5,8); histogram(delta_battery.("std auction"),10);title("std auction");
% subplot(2,5,9); histogram(delta_battery.("min auction"),10);title("min auction");
% subplot(2,5,10); histogram(delta_battery.("max auction"),10);title("max auction");
% figure(i);
% i=i+1;
% subplot(1,4,1);normplot(delta_battery.("mean auction"))
% subplot(1,4,2);normplot(delta_battery.("mean random"))
% subplot(1,4,3);normplot(delta_battery.("median auction"))
% subplot(1,4,4);normplot(delta_battery.("median random"))

% figure(i);
% i=i+1;
% hist([delta_battery.("mean random") , delta_battery.("mean auction")] ,8); legend("random","auction");

f=figure(i);
i=i+1;
f.Units='pixels';
f.OuterPosition=[2130,700,466,401];
boxplot([delta_battery.("mean random") , delta_battery.("mean auction")]*100, 'labels',{'Random','Auction-based'})
ylabel('Battery usage, $\bar{bat}_R~[\%]$', 'Interpreter','latex', 'FontSize', 18)
ax = gca;
ax.TickLabelInterpreter='latex';
ax.FontSize=18;
exportgraphics(ax,'TA_boxplot_experiment2.pdf')

%% experiment 3

clearvars -except i
load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'experiment_3.mat'))
mean(delta_battery.Variables)
median(delta_battery.Variables)

% figure(i);
% i=i+1;
% subplot(2,5,1); histogram(delta_battery.("mean random"),10); title("mean random");
% subplot(2,5,2); histogram(delta_battery.("median random"),10);title("median random");
% subplot(2,5,3); histogram(delta_battery.("std random"),10);title("std random");
% subplot(2,5,4); histogram(delta_battery.("min random"),10);title("min random");
% subplot(2,5,5); histogram(delta_battery.("max random"),10);title("max random");
% subplot(2,5,6); histogram(delta_battery.("mean auction"),10); title("mean auction");
% subplot(2,5,7); histogram(delta_battery.("median auction"),10);title("median auction");
% subplot(2,5,8); histogram(delta_battery.("std auction"),10);title("std auction");
% subplot(2,5,9); histogram(delta_battery.("min auction"),10);title("min auction");
% subplot(2,5,10); histogram(delta_battery.("max auction"),10);title("max auction");
% figure(i);
% i=i+1;
% subplot(1,4,1);normplot(delta_battery.("mean auction"))
% subplot(1,4,2);normplot(delta_battery.("mean random"))
% subplot(1,4,3);normplot(delta_battery.("median auction"))
% subplot(1,4,4);normplot(delta_battery.("median random"))

% figure(i);
% i=i+1;
% hist([delta_battery.("mean random") , delta_battery.("mean auction")] ,8); legend("random","auction");

f=figure(i);
i=i+1;
f.Units='pixels';
f.OuterPosition=[2130,700,466,401];
boxplot([delta_battery.("mean random") , delta_battery.("mean auction")]*100, 'labels',{'Random','Auction-based'})
ylabel('Battery usage, $\bar{bat}_R~[\%]$', 'Interpreter','latex', 'FontSize', 18)
ax = gca;
ax.TickLabelInterpreter='latex';
ax.FontSize=18;
exportgraphics(ax,'TA_boxplot_experiment3.pdf')


%% HISTOGRAM INDIVIDUAL ROBOT
f=figure(i);
i=i+1;
f.Units='pixels';
f.OuterPosition=[1960,1168,560,422];

clear delta_bat

load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'delta_bat_auction.mat'))
delta_batAUCTION=delta_bat;
clear delta_bat

load(fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'delta_bat_random.mat'))
delta_batRANDOM=delta_bat;
clear delta_bat

hist([delta_batRANDOM',delta_batAUCTION']*100 ,8); legend("Random selection","Auction-based strategy");
 
xlabel('Battery usage individual robots, $\Delta bat_i~[\%]$', 'Interpreter','latex', 'FontSize',18)
ylabel("Frequency",'Interpreter','latex','FontSize',18)
ax=gcf;
exportgraphics(ax, 'battery_usage_single_run.pdf')
