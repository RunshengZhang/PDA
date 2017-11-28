% Evaluate 
% Runsheng
% Nov 27

function [ area, hpwl ] = evaluate( placement, block, net )

[block_number,~] = size(block);
NP = size(fieldnames(placement),1);             % fieldnames return the n x 1 array   
net_name    = fieldnames(net);                  %   Net: struct  net_name is an array
net_number  = length(net_name);
area        = zeros(1,NP);
hpwl        = zeros(1,NP);

for n = 1:NP
    
    % build the field name
    name{n} = sprintf('NP%d', n);

    cur_placement = placement.(name{n});

    x_max       = zeros(1, block_number);           %   for computing area
    y_max       = zeros(1, block_number);
    w           = zeros(1, net_number);             %   for computing HPWL
    l           = zeros(1, net_number);

    %   2. Compute Area
    x_max = cur_placement(:,1) + cur_placement(:,3);    % NumberOfBlock x 1 array
    y_max = cur_placement(:,2) + cur_placement(:,4);
    x = max(x_max);
    y = max(y_max);
    area(n) = x*y;

    %   3. Compute HPWL
    for i = 1:net_number
        field = char(net_name(i));
        index = net.(field);
        center_x = cur_placement(index,1) + 0.5*cur_placement(index,3);
        center_y = cur_placement(index,2) + 0.5*cur_placement(index,4);
        w(i) = max(center_x) - min(center_x);
        l(i) = max(center_y) - min(center_y);
    end
    hpwl(n) = sum(w) + sum(l);
end
