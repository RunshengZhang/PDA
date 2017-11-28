% Evaluate 
% Yunyi
% Oct 30

function [ area, hpwl ] = evaluate( placement, block, net )

[block_number,~,NP] = size(placement);          %   placement: 3-D matrix
net_name    = fieldnames(net);                  %   Net: struct
net_number  = length(net_name);
area        = zeros(1,NP);
hpwl        = zeros(1,NP);

for n = 1:NP
    x_max       = zeros(1, block_number);           %   for computing area
    y_max       = zeros(1, block_number);
    w           = zeros(1, net_number);             %   for computing HPWL
    l           = zeros(1, net_number);

    %   1. Sort Placement
    for i = 1:block_number
        placement_ordered(i,1:2,n) = placement(find(placement(:,1,n)==i),2:3,n);
    end

    %   2. Compute Area
    x_max = placement_ordered(:,1,n) + str2double(block(:,2));
    y_max = placement_ordered(:,2,n) + str2double(block(:,3));
    x = max(x_max);
    y = max(y_max);
    area(n) = x*y;

    %   3. Compute HPWL
    for i = 1:net_number
        field = char(net_name(i));
        index = net.(field);
        center_x = placement_ordered(index,1,n) + 0.5*str2double(block(index,2));
        center_y = placement_ordered(index,2,n) + 0.5*str2double(block(index,3));
        w(i) = max(center_x) - min(center_x);
        l(i) = max(center_y) - min(center_y);
    end
    hpwl(n) = sum(w) + sum(l);
end
