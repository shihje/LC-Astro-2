function [color,accent] = setColor()
% function color = setColor()
% 
% bitDepth = 8;
% color.gray = [81 81 81];
% color.lightgray = [150 150 150];
% color.blue2 = [0 153 218];
% color.lightBlue2 = [153 214 240];
% color.blue = [0 107 173];
% color.red = [237 0 45];
% color.navy = [3 60 117];
% color.green = [0 166 100];
% color.lightBlue = [148 192 224];
% color.lightRed = [245 152 161];
% color.greenBlue = [43 187 173];
% color.orange = [241 86 35];
% color.lightOrange = [249 187 167];
% color.purple = [88 37 130];
% color.lightPurple = [172 146 193];
% color.yellow = [255 230 0];

bitDepth = 8;
color.gray = [81 81 81];
color.lightgray = [150 150 150];
color.blue2 = [0 153 218];
color.lightBlue2 = [153 214 240];
color.blue3 = [34 45 128];
color.blue = [0 107 173];
color.red = [237 0 45];
color.navy = [3 60 117];
color.green = [0 166 100];
color.lightBlue = [148 192 224];
color.lightRed = [245 152 161];
color.greenBlue = [43 187 173];
color.lightGreenBlue = [170 228 222];
color.orange = [241 86 35];
color.lightOrange = [249 187 167];
color.purple = [180 30 142];
color.lightPurple = [172 146 193];
color.yellow = [255 230 0];
color.magenta = [236 0 140];
color.lightMagenta = [246 173 205];
color.aqua = [0 177 205];
color.pink = [239 63 107];


f = fieldnames(color);
for i = 1:length(f)
    c = getfield(color, f{i});
    c = c/(2^bitDepth-1);
    color = setfield(color, f{i}, c);
end

accent{1} = color.blue2;
accent{2} = color.red;
accent{3} = color.green;
accent{4} = color.orange;
accent{5} = color.purple;
accent{6} = color.blue2;
accent{7} = color.greenBlue;
accent{8} = color.navy;
accent{9} = [0 0 0];
accent{10} = color.gray;