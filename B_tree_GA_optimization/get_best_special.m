% Get Current Best Member -- SPECIAL VERSION FOR RANDOM TEST
% Yunyi
% Nov 1

function best = get_best_special( tree, placement, area, hpwl, algo, block_area, best )

NP          = algo.NP;
DS          = algo.DS;
i           = 1;
area_const  = block_area / ( 1 - DS/100 );
feasible    = (area < area_const);

if sum(feasible)==0
    %   No member satisfies area constraint -> select the one with least area
    [~, index] = min(area);
    best.tree(:,:,i) = tree(:,:,index);
    best.placement(:,:,i) = placement(:,:,index);
    best.area(i) = area(index);
    best.hpwl(i) = hpwl(index);
elseif sum(feasible)~=0
    %   At least one member satisfies area constraint -> select the one with least HPWL among them
    temp = max(hpwl);
    [~, index] = min(hpwl.*feasible + temp*(~feasible));
    best.tree(:,:,i) = tree(:,:,index);
    best.placement(:,:,i) = placement(:,:,index);
    best.area(i) = area(index);
    best.hpwl(i) = hpwl(index);
end

