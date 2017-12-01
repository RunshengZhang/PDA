% Get Current Best Member
% Yunyi
% Nov 28

function best = get_best( h_placement, area, hpwl, block, algo, iteration, best )

NP          = algo.NP;
DS          = algo.DS;
i           = iteration;
name        = fieldnames(h_placement);

temp        = str2double(block(:,2:3));
block_area  = sum(temp(:,1).*temp(:,2));
area_const  = block_area / ( 1 - DS/100 );
feasible    = (area < area_const);

if sum(feasible)==0
    %   No member satisfies area constraint -> select the one with least area
    [~, index] = min(area);
    best.placement(:,:,i) = h_placement.(name{index});
    best.area(i) = area(index);
    best.hpwl(i) = hpwl(index);
elseif sum(feasible)~=0
    %   At least one member satisfies area constraint -> select the one with least HPWL among them
    temp = max(hpwl);
    [~, index] = min(hpwl.*feasible + temp*(~feasible));
    best.placement(:,:,i) = h_placement.(name{index});
    best.area(i) = area(index);
    best.hpwl(i) = hpwl(index);
end
