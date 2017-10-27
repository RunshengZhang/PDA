% B* tree Packing
% Yunyi
% Oct 21, 2017

function placement = packing(block, tree)

[block_number, m] = size(block);
perm = tree(:,1);

%   Clear everything
placement = zeros(block_number,3);
x = 0;
y = 0;

%   The Root
placement(1,:) = [perm(1), x, y];

for i = 2:block_number
    if (tree(i,2)~=0 && tree(i,3) == 0)
    %   Current block is the left child
        parent      = tree(i,2);
        x_parent    = placement(find(perm == parent),2);
        w_parent    = str2double(block(parent,2));
        x           = x_parent + w_parent;
        w           = str2double(block(perm(i),2));
        %   Decide y coordinate by checking perm to find x overlap
        y_max = 0;
        for j = 1:(i-1)                                
            x_perm = placement(j, 2);
            w_perm = str2double(block(perm(j),2));
            %   Check overlap
            if (x < (x_perm + w_perm)) && ((x + w) > x_perm)   
                y_max = max(y_max, placement(j,3)+str2double(block(perm(j),3))); %   Update y_max
            end
        end
        y           = y_max;
        placement(i,:) = [perm(i), x, y];
    elseif (tree(i,2)==0 && tree(i,3) ~= 0)
    %   Current block is the right child
        parent      = tree(i,3);
        x_parent    = placement(find(perm == parent),2);
        x           = x_parent;
        w           = str2double(block(perm(i),2));
        %   Decide y coordinate by checking perm to find x overlap
        y_max = 0;
        for j = 1:(i-1)                                
            x_perm = placement(j, 2);
            w_perm = str2double(block(perm(j),2));
            % Check overlap
            if (x < (x_perm + w_perm)) && ((x + w) > x_perm)   
                y_max = max(y_max, placement(j,3)+str2double(block(perm(j),3))); %   Update y_max
            end
        end
        y           = y_max;
        placement(i,:) = [perm(i), x, y];
    else
        error('Tree structure error!');
    end
end
