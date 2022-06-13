function f2Excl = clickF2Excl_II(Perim,f2Excl,options)
    % Draw a graph which you can click on to select frame to exclude.
    % Second version with some new features
    % frameToExcl: If already frametToExcl have been identified it will build
    % on that. Leave empty to initialize.
    % Now with better initialization of frameToExcl.
    % New A and F key to reward or fastforward to next frame to exclude.
    
    % OPTIONS:
    % options.startPosi: Frame to display 1st. Default : 1;
    % options.threshold: Upper and lower threshold to automatically exclude frames. [min max]. default is [0 1200];
    % options.thDiff: Threshold to automatically exclude sawtooth part of the trace. default is 100;
    % options.windowSize: Number of frame per window. Default : 50
    % options.yLim: Y axis limit of window. Default : [0 1000]
    
    % DEFAULT VALUES
    startPosi = 1;
    thresh = [0 1200];
    thDiff = 100;
    windowSize = 50;
    YL = [0 1000];
    
    % =========================================================================
    % SOME CHECKUPS
    
    if nargin > 2
        if isfield(options,'startPosi'); startPosi = options.startPosi; end
        if isfield(options,'threshold'); thresh = options.threshold; end
        if isfield(options,'thDiff'); thDiff = options.thDiff; end
        if isfield(options,'windowSize'); windowSize = options.windowSize; end
        if isfield(options,'yLim'); YL = options.yLim; end
    end
    % =========================================================================
    
    
    try
        
        %% initialize frameToExcl if empty
        
        if ~isempty(f2Excl)
            if size(f2Excl,1) == 1;
                f2Excl = f2Excl';
            end
        end
        
            f2Excl = [f2Excl; find(Perim < thresh(1) | Perim > thresh(2))];
            f2Excl = [f2Excl; find(abs(diff([0; Perim])) > thDiff)];
            f2Excl = unique(f2Excl);
%         end
        
        i = length(f2Excl);
        
        % Defining parameter for window
        lA = length(Perim); % to set maximum value of window
        win_lim = ceil(lA/windowSize);
        startPosi = floor(startPosi/windowSize) + 1;
        
        % Defining Keyboard input
%         if strcmp(computer,'MACI64'); escapeKey = KbName('ESCAPE');
%         else escapeKey = KbName('esc'); end
%         sKey = KbName('s');
%         dKey = KbName('d');
%         aKey = KbName('a');
%         fKey = KbName('f');
        % ASCII NUMBER
        sKey = 115;
        dKey = 100;
        aKey = 97;
        fKey = 102;
        escapeKey = 27;
        ESC = 1; S = 0; D = 0; A = 0; F = 0;
        
        
        scrsz = get(0,'ScreenSize');
        fig = figure;
        if ~strcmp(computer,'MACI64'); P_f = get(gcf,'Position'); set(gcf,'Position',[0.5*scrsz(3)-P_f(3) 0.5*scrsz(4)-P_f(4) P_f(3)*2 P_f(4)*2]); end
        while ESC % Run until ESC is pressed
            clickF2ExclDisplay_II(Perim,f2Excl,startPosi,options);
            
            while ~any([D S A F]) && ESC
                [x,~,button] = ginput(1);
                if button <= 3 % mouse click
                    if button == 3 % left click to delete
                        if any(f2Excl == round(x))
                            i2Remove = find(f2Excl == round(x));
                            f2Excl(i2Remove) = [];
                            i = i-1;
                            clickF2ExclDisplay_II(Perim,f2Excl,startPosi,options);
                        end
                    else
                        if round(x) > 0; % exclude clicks outside the window
                            f2Excl(i) = round(x);
                        end
                        hold on;
                        plot(f2Excl(i),Perim(f2Excl(i)),'xr');
                        plot([f2Excl(i) f2Excl(i)],YL,'r');
                        drawnow;
                        hold off;
                        if f2Excl(i) < 1
                            f2Excl(i) = 1;
                        elseif f2Excl(i) > lA
                            f2Excl(i) = lA;
                        end
                        i = i+1;
                    end
                else % keyboard hit
                    ESC = ~(escapeKey == button);
                    S = sKey == button;
                    D = dKey == button;
                    A = aKey == button;
                    F = fKey == button;
                end
            end
            
            f2Excl = sort(unique(f2Excl));
            
            if D % Go to next window
                startPosi = startPosi+1;
                D = 0;
            elseif S % Go to previous window
                startPosi = startPosi-1;
                S = 0;
            elseif A % Reward to previous frametoexcl
                currFrame = (startPosi - 1)*windowSize;
                f2rew = f2Excl(find(f2Excl < currFrame,1,'last'));
                if ~isempty(f2rew)
                    startPosi = floor(f2rew/windowSize) + 1;
                else
                    startPosi = 1;
                end
                A = 0;
            elseif F % Fastforward to next frametoexcl
                currFrame = startPosi*windowSize;
                f2fast = f2Excl(find(f2Excl >= currFrame,1,'first'));
                if ~isempty(f2fast)
                    startPosi = floor(f2fast/windowSize) + 1;
                else
                    startPosi = win_lim;
                end
                F = 0;
            end
            
            if startPosi < 1
                startPosi = 1;
            elseif startPosi > win_lim
                startPosi = win_lim;
            end
        end
        close(fig);
        f2Excl(f2Excl == 0) = [];
        f2Excl = sort(unique(f2Excl));
        
    catch
        close(fig);
        f2Excl(f2Excl == 0) = [];
        f2Excl = sort(unique(f2Excl));
        fprintf('ERROR WHILE RUNNING clickF2Excl_II\n');
    end
