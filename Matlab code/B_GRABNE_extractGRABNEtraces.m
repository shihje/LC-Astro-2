clear all; close all; clc;

% User define params
DataDrive = 'E:\LC_Astro_Project';
AN = 'DbhAstro07';
FolderName = '20220506';
P = [DataDrive filesep AN filesep FolderName filesep];
aqua = 0;

%% Calculate t0 to align 2PH data to behavior %%%%%%%%%%%%%%%%%%%
fprintf('Calculate 2Photon t0\n')
FL = getfnamelist(P);
idx = findStrInFileList(FL,'Voltage');
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

if ~aqua
    dataDFF = dataDFF(1:end,:);
    dFF = nan(size(dataDFF));
    for i = 1:size(dataDFF,2)
        X = dataDFF(:,i);
        X0 = nanmean(X);
        dFF(:,i) = detrend((X-X0)./X0*100);
    %         dFF(:,i) = lowPassFilterButter(dFF(:,i),1,5,2);
    end
else
    dFF = All;
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