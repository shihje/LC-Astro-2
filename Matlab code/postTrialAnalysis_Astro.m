%% extract behavior for n+1 trials 

clear all; close all; clc;

% User define params
AN = 'DbhAstro06';
FolderName = '20220419-001';
P = 'C:\Users\Sur Lab\Dropbox (Personal)\LC_Astro\DbhAstro06\20220419-001\'
%[pwd filesep AN filesep FolderName filesep];

% Load astrocyte data 
FL = getfnamelist(P);
idx = findStrInFileList(FL,'dataAstro');
FNAstro = FL{idx};
load([P FNAstro]);

%% Load behavior
fprintf('Load behavior\n')
FL = getfnamelist(P);
idx = findStrInFileList(FL,'ToneDisc');
FN = FL{idx};
load([P FN])
dataBEH= data;
clear data;

% Load lick/lever and resample to resLever
resLever = 100; % in Hz
tArduino = dataBEH.response.dataArduino(:,1);
levPos = dataBEH.response.dataArduino(:,2);
lick1 = dataBEH.response.dataArduino(:,3);
lick2 = dataBEH.response.dataArduino(:,4);
levSpeed = [0; abs(diff(levPos))]; % convert to absolute speed
fprintf('Resample data from arduino\n');
[levPosRs,tArduinoRs] = resample(levPos,tArduino,100);
[levSpeedRs,tArduinoRs] = resample(levSpeed,tArduino,100);
[lick1Rs,tArduinoRs] = resample(lick1,tArduino,100);
[lick2Rs,tArduinoRs] = resample(lick2,tArduino,100);

%% Create MTX to align behavior to time stamps of Ephys
%   [trial id    tstamps(start)   Trial type  Difficulty  Fore RT]
% -------------
fprintf('Create behavior matrix\n');
MTXResp = dataBEH.response.respMTX;
MTXTrialType = dataBEH.params.MTXTrialType;
nTrials = size(MTXResp,1);
MTXTrialType = MTXTrialType(1:nTrials,:);

tStart = MTXResp(:,1) - MTXResp(1,1) + dataAstro.t2PHBehStart;
tStartBeh = MTXResp(:,1);

% Determine trial type
H = MTXTrialType(:,3) >= 5 & MTXResp(:,3) > 0;
M = MTXTrialType(:,3) >= 5 & MTXResp(:,3) < 1;
CR = MTXTrialType(:,3) < 5 & MTXResp(:,3) < 1;
FA = MTXTrialType(:,3) < 5 & MTXResp(:,3) > 0;
trialType = H*1 + M*2 + CR*3 + FA*4; % 1 = H 2 = M 3 = CR 4 = FA
trialType(MTXResp(:,6) > 0) = nan; % nan if early

% Difficulty
diffLevel = nan(nTrials,1);
idx = MTXTrialType(:,3) > 4; % GO
diffLevel(idx) = 9-MTXTrialType(idx,3);
idx = MTXTrialType(:,3) < 5; % NO-GO
diffLevel(idx) = 5-MTXTrialType(idx,3);

fore = MTXTrialType(:,4);%MTXResp(:,2)-MTXResp(:,1);
RT = MTXResp(:,4)-MTXResp(:,2);


%% 

% pull out trial types with FA preceding a hit
trialTypepostFA = nan(size(idx)); 
for i = 1:length(idx)
   if trialType(i) == 4 & trialType(i + 1) == 1
        trialTypepostFA(i+1) = 1;
   else if trialType(i) == 4 & trialType(i + 1) ==2
           trialTypepostFA(i+1) =2; 
       else if trialType(i)== 4 & trialType(i + 1) == 3
               trialTypepostFA(i+1) = 3; 
           else if  trialType(i)== 4 & trialType(i + 1) == 4
                   trialTypepostFA(i+1)=4;
               end 
           end
       end
   end
end 

%%
% MTX to align stuff
beh22PH = [tStart tStartBeh trialTypepostFA diffLevel fore RT];
beh22PHInfo = {'tstamps(ephys)'; 'tStamps(beh)';   'Trial type post FA';  'Difficulty';  'Fore'; 'RT'};
        
%% 

% set up
t2PH = dataAstro.t2PH;
dFF = dataAstro.dFF;
fps = mean(diff(t2PH));
win = [-1 5];
winResp = [0 1];
winITI = [0 win(2)];
winBL = [win(1) 0];
selROI = [1];

% Find indices of t2PH and lever
tAlign(:,1) = tStart + fore; % Align to tone
% %tAlign(:,1) = tStart + fore + RT;%align to press
% 
% 
idStart2PH = nan(size(tStart));
for i = 1:length(tStart)
    if ~isempty(find(t2PH > (tAlign(i,1)) ,1))
        idStart2PH(i) = find(t2PH > (tAlign(i,1)),1)-1;
    end    
end
% 
% % some figure set up
TITLE = {'Post FA- Hit','Post FA - Miss','Post FA- CR','Post FA- FA'};
c = setColor;
cA(:,1) = c.blue2;
cA(:,2) = [0 0 0];
cA(:,3) = c.purple;
cA(:,4) = c.red;

nROI = size(dFF,2);

for i = 1:nROI
    NE = dFF(:,i);
    
%      % Create raster 2PH
    [A,iR] = makeRaster(NE,idStart2PH(~isnan(idStart2PH)),round(win/fps));
    tR2PH = linspace(win(1),win(2),size(A,2));
    A = bsxfun(@minus,A,nanmean(A(:,tR2PH > winBL(1) & tR2PH < winBL(2)),2));
    R = nan(length(idStart2PH),size(A,2));
    R(~isnan(idStart2PH),:) = A;
    R(isnan(R)) = 0;
    
    peakNE(:,i) = nanmax(R(:,tR2PH > winResp(1) & tR2PH < winResp(2)),[],2);
    peakNEITI(:,i) = nanmax(R(:,tR2PH > winITI(1) & tR2PH < winITI(2)),[],2);
    
    % Make figure
    if intersect(i,selROI)
        figure;
        setFigure('large')
        set(gcf,'name',['ROI #' num2str(i)])
    end
%     
    for j = 1:4
        [m, err] = mean_sem(R(beh22PH(:,3) == j,:),1);
        
        if j == 1
            mH(:,i) = m;
            errH(:,i) = err;
            peakNEH(:,i) = peakNE(beh22PH(:,3) == j,i);
        end
        if j == 3
            peakNEITICR(:,i) = peakNEITI(beh22PH(:,3) == j,i);
        end
        if j == 4
            mFA(:,i) = m;
            errFA(:,i) = err;
        end
           if intersect(i,selROI)
            ax = subplot(2,4,j);
            selRT = RT(beh22PH(:,3) == j);
            [~,iSort] = sort(selRT);
            A = R(beh22PH(:,3) == j,:);
            imagesc(A(iSort,:),[-2 5]);
            %             if j == 2
            colormap(ax,gray)
            %             else
            %                 colormap(ax,makeColorMap(cA(:,j)'));
            % %             end
            title(TITLE{j})
            axis off
            setUpPlot
            
            
            subplot(2,4,j+4)
            boundedline(tR2PH,m,err,'cmap',cA(:,j)');
            setUpPlot
            xlim(win)
            ylabel('Astrocyte DFF (%)')
            ylim([-2 50])
            xlabel('Time - tone-aligned (s)')
        end
    end
end
