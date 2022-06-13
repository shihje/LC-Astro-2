function displayDataGRABNE(P)

load(P);

%% Temporary function
%% Display example trace from ROI #1 (average of whole FOV)

% set up
t2PH = dataGRABNE.t2PH;
dFF = dataGRABNE.fluo;
dFF = (dFF - mean(dFF))./mean(dFF)*100;
fps = mean(diff(t2PH));
win = [-1 3];
winResp = [0 1];
winITI = [0 win(2)];
winBL = [win(1) -0.5];
selROI = [1];
tStart = dataGRABNE.beh22PH(:,1);
fore = dataGRABNE.beh22PH(:,5);
RT = dataGRABNE.beh22PH(:,6);
beh22PH = dataGRABNE.beh22PH;

% Find indices of t2PH and lever
tAlign(:,1) = tStart + fore; % Align to tone
% tAlign(:,1) = tStart + fore + RT;
idStart2PH = nan(size(tStart));
for i = 1:length(tStart)
    if ~isempty(find(t2PH > (tAlign(i,1)) ,1))
        idStart2PH(i) = find(t2PH > (tAlign(i,1)),1)-1;
    end    
end

% some figure set up
TITLE = {'Hit','Miss','CR','FA'};
c = setColor;
cA(:,1) = c.blue2;
cA(:,2) = [0 0 0];
cA(:,3) = c.purple;
cA(:,4) = c.red;

nROI = size(dFF,2);

for i = 1:nROI
    NE = dFF(:,i);
    
    
    % Create raster 2PH
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
        fig = figure;
        setFigure('large')
        set(gcf,'name',['ROI #' num2str(i)])
    end
    
    for j = 1:4
        [m, err] = mean_sem(R(beh22PH(:,3) == j,:),1);
        mAll(:,i,j) = m;
        
        if j == 1
%                     figure(251)
%         hold all
%         plot(tR2PH,m)
% 
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
            figure(fig)
            ax = subplot(2,4,j);
            selRT = RT(beh22PH(:,3) == j);
            [~,iSort] = sort(selRT);
            A = R(beh22PH(:,3) == j,:);
            imagesc(A(iSort,:),[-2 10]);
            %             if j == 2
            colormap(ax,gray)
            %             else
            %                 colormap(ax,makeColorMap(cA(:,j)'));
            % %             end
            title(TITLE{j})
            axis off
            setUpPlotCompact
            
            
            subplot(2,4,j+4)
            boundedline(tR2PH,m,err,'cmap',cA(:,j)');
            setUpPlotCompact
            xlim(win)
            ylabel('GRABNE DFF (%)')
%             ylim([-2 20])
            xlabel('Time - tone-aligned (s)')
            
%             figure(123)
%             hold all
%              boundedline(tR2PH,m,err,'cmap',cA(:,j)')
        end
    end
end
