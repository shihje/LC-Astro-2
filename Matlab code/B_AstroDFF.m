%% Astrocyte version of B_GRABNE_extractGRABNEtraces

clear all; close all; clc;

% User define params
AN = 'DbhAstro07';
FolderName = '20220519';
P = [pwd filesep AN filesep FolderName filesep];

%% Calculate t0 to align 2PH data to behavior %%%%%%%%%%%%%%%%%%%
fprintf('Calculate 2Photon t0\n')
FL = getfnamelist(P);
idx = findStrInFileList(FL,'.csv');
FN = FL{idx};
T = readtable([P FN]);
t = T.Time_ms_/1000;
V = T.Input0 > 0.03;
dV = [0; diff(V)];
t0 = t(find(dV > 0,1));
% save([P 'LEDtrace'],'T');
% figure;plot(t,dV);title('dV vs time(s)')

%% Calculate DFF-
fprintf('Calculate DFF\n')
FL = getfnamelist(P);
idx = findStrInFileList(FL,'CombinedResults');
FN = FL{idx};

load([P FN]);
dataFluo = All; % Non processed data
dataDFF = All;
dataDFF = dataDFF(1:end,:);
dFF = nan(size(dataDFF));
for i = 1:size(dataDFF,2)
    X = dataDFF(:,i);
%     X0 = mean(X);
    %X0 = min(X);
    X0 = mode(round(X));
    dFF(:,i) = detrend((X-X0)./X0*100);
%         dFF(:,i) = lowPassFilterButter(dFF(:,i),1,5,2);
end

%% Load XML file and extract relevant info
fprintf('Extract 2Photon timing of each frame from .xml file\n');
FL = getfnamelist(P);
idx = findStrInFileList(FL,[FolderName '.xml']);
FN = FL{idx};
t2PH = XMLfindRelativeTime([P FN]);
if length(t2PH) > size(dataDFF,1)
    t2PH = t2PH(1:size(dataDFF,1));
end
    
%% SOME FIGURES
figure;
subplot(2,1,1)
imagesc(dFF')
setUpPlot
title('DFF from all ROIs')

subplot(2,1,2)
plot(t2PH,dFF(:,1));
title('AVG DFF ALL ROI')
setUpPlot
xlim([t2PH(1) t2PH(end)])
%% SAVE

dataAstro.fluo = dataFluo;
dataAstro.dFF = dFF;
dataAstro.t2PH = t2PH;
dataAstro.t2PHBehStart = t0;
savename = [P FolderName '_dataAstro'];
save(savename,'dataAstro');