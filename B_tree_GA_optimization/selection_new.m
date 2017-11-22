% Selection
% Yunyi
% Nov 13

% Description:
%   Select better results from both old and new population together

function [ tree, placement, area, hpwl ] = selection( tree, placement, area, hpwl, tree_new, placement_new, area_new, hpwl_new, algo, block_area ); 

%   Input: tree, tree_new, placement, placement_new, area, area_new, hpwl, hpwl_new, algo, block_area
%   Output: tree, placement, area, hpwl

DS = algo.DS;
AP = algo.AP;
NP = algo.NP;

%%  1. Merge Old and New Population
tree_new(:,:,((NP+1):(2*NP)))       = tree(:,:,1:end);
placement_new(:,:,((NP+1):(2*NP)))  = placement(:,:,1:end);
area_new                            = [area_new, area];
hpwl_new                            = [hpwl_new, hpwl];

%%  2. Compute Feasibility from Constraint Violation
area_const = block_area / ( 1 - DS/100 );
feasible   = (area_new < area_const);

%%  3. Selection
if sum(feasible) < NP
    %   Select all feasible member
    index_1 = find(feasible);
    tree(:,:,1:length(index_1)) = tree_new(:,:,index_1);
    placement(:,:,1:length(index_1)) = placement_new(:,:,index_1);
    area(1:length(index_1)) = area_new(index_1);
    hpwl(1:length(index_1)) = hpwl_new(index_1);
    %   Select member with best Area from the rest
    list = area_new.*(~feasible) + area_new.*(feasible).*max(area_new);
    for i = 1:(NP - length(index_1))
        temp = max(list);
        [~,index_2(i)] = min(list);
        list(index_2(i)) = temp;
    end
    tree(:,:,((length(index_1)+1):NP)) = tree_new(:,:,index_2);
    placement(:,:,((length(index_1)+1):NP)) = placement_new(:,:,index_2);
    area((length(index_1)+1):NP) = area_new(index_2);
    hpwl((length(index_1)+1):NP) = hpwl_new(index_2);
elseif sum(feasible) >= NP
    %   Select member with best HPWL among them
    list = hpwl_new.*feasible + hpwl_new.*(~feasible).*max(hpwl_new);
    for i = 1:NP
        temp = max(list);
        [~,index_1(i)] = min(list);
        list(index_1(i)) = temp;
    end
    tree(:,:,1:NP) = tree_new(:,:,index_1);
    placement(:,:,1:NP) = placement_new(:,:,index_1);
    area(1:NP) = area_new(index_1);
    hpwl(1:NP) = hpwl_new(index_1);
end
