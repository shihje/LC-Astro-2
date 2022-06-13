function relativeTime = XMLfindRelativeTime(FNameXML)
% Find relative time for each 2photon in .xml file FNameXML

% Parameters
maxNumberOfFrames = 50000;

% Load XML and find node sequence
theNode = xmlread(FNameXML);
X = XMLfindNode(theNode,'PVScan');
seqNode = XMLfindNode(X,'Sequence');
n = seqNode.getLength;

% Calculate i values at each 10%
idxPrint = round(0:n/10:n);
str = {'0%% ','10%% ','20%% ','30%% ','40%% ','50%% ','60%% ','70%% ','80%% ','90%% ','100%% '};
kk = 1;

% For each node under sequence find relativeTime value
k = 1;
relativeTime = nan(maxNumberOfFrames,1);
for i = 0:n-1
    if i == idxPrint(kk); fprintf(str{kk}),kk = kk+1; end;
    currNode = seqNode.item(i);
    if strcmp(currNode.getNodeName,'Frame')
        A = currNode.getAttributes;
        nA = A.getLength;
        for j = 0:nA-1
            currAtt = A.item(j);
            if strcmp(currAtt.getName,'relativeTime')
                relativeTime(k) = str2double(currAtt.getValue);
                k = k+1;
            end
        end
    end
end
relativeTime = relativeTime(~isnan(relativeTime));
fprintf(str{kk});
fprintf('\n')
