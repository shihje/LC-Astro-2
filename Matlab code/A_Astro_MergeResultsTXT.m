%% astrocyte version of A_GRABNE_MergeResultsTXT

clear all; close all; clc;

% Combine results file together
AN = 'DbhAstro07';
FolderName = '20220525';
FList = {
    'Stack01Results.txt'
    %'Stack02Results.txt'
% %     'Stack03Results.txt'
%      'Stack04Results.txt'
    };
P = [pwd filesep AN filesep FolderName filesep];

% Load size
n = zeros(2,length(FList));
for i = 1:length(FList)
    X = load([P FList{i}]);
    n(:,i) = size(X);
end
All = zeros(sum(n(1,:))-length(FList),n(2,1));

% Combine and save; assume first line is the MXP data
k = 0;
for i = 1:length(FList)
    X = load([P FList{i}]);
    n = size(X,1);
    All((1:n-1)+k,:) = X(2:end,:);
    k = k+n-1;
end
save([P 'CombinedResults'],'All');