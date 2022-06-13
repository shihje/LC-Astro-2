%% Script to find frame 2 exclude after segmentation
% clearvars -except f2excl; close all; clc;
clear all; close all; clc;
P = 'C:\Users\Gabi\Dropbox (MIT)\pupil tracking\DataOpto20200227\';
FN = 'ANDBHArch11_spont1_dataTracking';
load([P FN]);


% FIND Frames 2 exclude =====================
perim = dataTracking.perim;
figure; plot(perim); ylim([0 1000]);
low = input('Enter lower threshold:\n');
high = input('Enter higher threshold:\n');
close;
options.threshold = [low high];
options.thDiff = 25;
options.windowSize = 50;
options.yLim = [low high];
options.startPosi = 1;
f2excl = clickF2Excl_II(perim,[],options);
% f2excl = clickF2Excl_II(Perim,f2excl,options);


% Extrapolate and calculate diameter =====================
pixelVal = 5.20;
subSampling = 2;
D = perim./pi*pixelVal*subSampling;
D = extrapolatePerim(D,f2excl,0);

% Find time of trigger
t = dataTracking.tStamps;
tTrigger = t(find(diff(dataTracking.events) > 0));
tStampsAdj = t - tTrigger(1);


% Save data =====================
dataTracking.f2excl = f2excl;
dataTracking.diameter = D; % in um
dataTracking.tTrigger = tTrigger;
dataTracking.tStampsAdj = tStampsAdj;

uisave('dataTracking',[P filesep FN]);


% Display data =====================
f = figure;
currPos = get(f,'position');
scrsz = get(groot,'ScreenSize');
set(f,'position',[scrsz(1)+50,scrsz(2)+200,scrsz(3)-100,scrsz(4)-400]);

a(1) = subplot(2,1,1);
plot(perim,'k');
M = max(perim)+100;
hold on
for i = 1:length(f2excl)
    plot([f2excl(i) f2excl(i)],[0 M],':r')
end
hold off
ylim([low high]);
xlim([0 length(perim)]);
setUpPlot;



a(2) = subplot(2,1,2);
plot(D,'r','linewidth',2);
% ylim([low high])
setUpPlot;
title('Corrected trace');
xlim([0 length(perim)]);
linkaxes(a,'x');