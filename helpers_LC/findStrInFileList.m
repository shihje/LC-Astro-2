function fileID = findStrInFileList(fnamelist,str)

fileID = [];
i = 1;
for i = 1:length(fnamelist)
    if ~isempty(regexpi(fnamelist{i},str))
        fileID = [fileID i];
    end
end
