clear all; close all; clc;

P = '/Users/gabidrummond/Dropbox (MIT)/Sur lab stuff/LC_Astro/DbhAstro06/'
%F:\Documents\00 Projects\00 LC_DecisionUncertainty\GRAB-NE\Behavior\PrelimAnalysis\';

FN = {
    'DbhAstro0620220419-001_dataAstro'
    'DbhAstro0620220420-001_dataAstro'
%     'GRABACC01_20200220-001_dataGRABNE'
%     'GRABACC02_20200206-001_dataGRABNE'
%      'GRABACC02_20200211-001_dataGRABNE'
%      'GRABACC03_20200206-001_dataGRABNE'
    };

for f = 1:length(FN)
    load([P FN{f}]);
    
    
    % set up
    t2PH = dataAstro.t2PH;
    dFF = dataAstro.fluo;
    dFF = (dFF - mean(dFF))./mean(dFF)*100;
    fps = mean(diff(t2PH));
    win = [-1 5];
    winResp = [.1 10];
    winITI = [0 win(2)];
    winBL = [win(1) -0.5];
    %     selROI = [15 25 16 26 17 27; 58 59 60 68 69 70; 74 75 76 84 85 86; 8 9 18 19 28 29];
    tStart = dataAstro.beh22PH(:,1);
    fore = dataAstro.beh22PH(:,5);
    RT = dataAstro.beh22PH(:,6);
    beh22PH = dataAstro.beh22PH;
    
    % Find indices of t2PH and lever
    tAlign = tStart + fore; % Align to tone
    % tAlign(:,1) = tStart + fore + RT;
    idStart2PH = nan(size(tStart));
    for i = 1:length(tStart)
        if ~isempty(find(t2PH > (tAlign(i)) ,1))
            idStart2PH(i) = find(t2PH > (tAlign(i)),1)-1;
        end
    end
    NE = dFF(:,1);
    
    
    % Create raster 2PH
    [A,iR] = makeRaster(NE,idStart2PH(~isnan(idStart2PH)),round(win/fps));
    tR2PH = linspace(win(1),win(2),size(A,2));
    A = bsxfun(@minus,A,nanmean(A(:,tR2PH > winBL(1) & tR2PH < winBL(2)),2));
    R = nan(length(idStart2PH),size(A,2));
    R(~isnan(idStart2PH),:) = A;
    R(isnan(R)) = 0;
    
    peak = nanmax(R(:,tR2PH > winResp(1) & tR2PH < winResp(2)),[],2);
    avg = nanmean(R(:,tR2PH > winResp(1) & tR2PH < winResp(2)),2);
    
    for j = 1:4
        NEpeak(j,f) = mean(peak(beh22PH(:,3) == j));
        NEavg(j,f) = mean(avg(beh22PH(:,3) == j));
    end
end

%%
figure;
% subplot(2,1,1)
hold all;
plot(1:4,NEpeak,'color',[0.5 0.5 0.5])
[m,err] = mean_sem(NEpeak,2);
errorbar(1:4,m,err,'-ok','markerfacecolor','k')
xlim([0.5 4.5])
set(gca,'xtick',1:4,'xticklabel',{'H' 'M' 'CR' 'FA'})
ylabel('Peak GRABNE DFF (%)')
setUpPlot


r = NEpeak';
                tbl = table(r(:,1),r(:,2),r(:,3),r(:,4),'VariableNames',{'c1','c2','c3','c4'});
                meas = table([1 2 3 4]','VariableNames',{'Measurements'});
                rm = fitrm(tbl,'c1-c4~1','WithinDesign',meas);
                ranovatbl = ranova(rm);
                fprintf('REPEATED MEASUREMENT ANOVA\n')
                compTBL = multcompare(rm,'Measurements')
% 
% subplot(2,1,2)
% plot(1:4,NEavg)
% [m,err] = mean_sem(NEpeak,2);
% errorbar(1:4,m,err)
