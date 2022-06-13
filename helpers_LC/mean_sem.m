function [m,s] = mean_sem(X,dim)

if nargin < 2
    dim = 1;
end

if any(isnan(X(:)))
    m = nanmean(X,dim);
    s = bsxfun(@rdivide,nanstd(X,0,dim),sqrt(sum(~isnan(X),dim)));
elseif isempty(X)
    m = nan;
    s = nan;
else  
    m = mean(X,dim);
    s = std(X,0,dim)/sqrt(size(X,dim));
end