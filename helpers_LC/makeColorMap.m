function cmap = makeColorMap(color)

%input = 1x3 color
%output = 256x3 colormap

cmap = zeros(256,size(color,2));

for c = 1:size(color,2)
    cmap(:,c) = linspace(1,color(c),256);
end
