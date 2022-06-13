function childNode = XMLfindNode(theNode,str)
% Find a child node with name specified by string 'str'
numNodes = theNode.getLength;
childNode = [];
i = 0;
while isempty(childNode) || i < numNodes
    x = theNode.item(i);
    if strcmp(char(x.getNodeName),str)
        childNode = x;
    end
    i = i+1;
end
