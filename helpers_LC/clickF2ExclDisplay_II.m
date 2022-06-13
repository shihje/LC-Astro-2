function clickF2ExclDisplay_II(Perim,frametoexcl,win_posi,options)

    % OPTIONS:
% options.windowSize: Number of frame per window. Default : 50
% options.yLim: Y axis limit of window. Default : [0 1000]

% DEFAULT VALUES
windowSize = 50;
YL = [0 1000];

% =========================================================================
% SOME CHECKUPS

if nargin > 3
    if isfield(options,'windowSize'); windowSize = options.windowSize; end
    if isfield(options,'yLim'); YL = options.yLim; end
end

if frametoexcl < 1
    frametoexcl(frametoexcl < 1) = [];
end
% =========================================================================

% Define graph params
lA = length(Perim); % to set maximum value of window
nXL = ceil(lA/windowSize);
XL(:,1) = (0:nXL-1)*windowSize;
XL(:,2) = (1:nXL)*windowSize;
current_XL = XL(win_posi,:);
i_ftl = find(frametoexcl >= current_XL(1) & frametoexcl <= current_XL(2));
if current_XL(1) < 1
    current_XL(1) = 1;
elseif current_XL(2) > length(Perim);
    current_XL(2) = length(Perim);
end

% Display graph
plot(current_XL(1):current_XL(2),Perim(current_XL(1):current_XL(2)),'k','linewidth',2);
hold on; 
plot(frametoexcl(i_ftl),Perim(frametoexcl(i_ftl)),'rx');
for i = 1:length(i_ftl)
    plot([frametoexcl(i_ftl(i)) frametoexcl(i_ftl(i))],YL,'r');
end
hold off;
setUpPlot;

% Adjust graph params
xlim(XL(win_posi,:)); % Set xlim to the current window
ylim(YL)
xlabel('Frame #')
ylabel('Diameter')

% Adjust instructions text
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10+3/40),'Press ESC to exit and save.','fontweight','bold','fontsize',12);
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10+2/40),'D: next window')
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10+1/40),'S: previouswindow')
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10+0/40),'F: FFWD to next frame to exclude','color','b')
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10-1/40),'A: REW to previous frame to exclude','color','b')
text(XL(win_posi,1)+1,YL(1)+diff(YL)*(9/10-2/40),'Mouse right-click: delete','color','r')

