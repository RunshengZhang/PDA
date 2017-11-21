% Selection
% Yunyi
% Nov 1

function [ tree, placement, area, hpwl ] = selection( tree, placement, area, hpwl, tree_new, placement_new, area_new, hpwl_new, algo, block_area ); 

%   Input: tree, tree_new, placement, placement_new, area, area_new, hpwl, hpwl_new, algo, block_area
%   Output: tree, placement, area, hpwl

DS = algo.DS;
AP = algo.AP;
NP = algo.NP;
update = zeros(1,NP);

%%  1. Compute Area Constraint
area_const = block_area / ( 1 - DS/100 );

%%  2. Compute Feasibility from Constraint Violation
feasible        = (area < area_const);
feasible_new    = (area_new < area_const);

%%  3. Tournament Selection

                %   Rule 1:
                %       If both are feasible, select according to acceptance probability;
                %   Rule 2:
                %       If both are infeasible, select the one with smaller violation;
                %   Rule 3:
                %       If only one is feasible, select the feasible one.

update     = (feasible == 1).*(feasible_new == 1).*((hpwl_new <= hpwl) + (hpwl_new >= hpwl).*(rand(1) < AP)) ... 
           + (feasible == 0).*(feasible_new == 0).*(area_new <= area) ...
           + (feasible == 0).*(feasible_new == 1);

%%  4. Update Population, Area, and HPWL
area = area_new.*update + area.*(1-update);
hpwl = hpwl_new.*update + hpwl.*(1-update);
for n = 1:NP
    tree(:,:,n)         = tree_new(:,:,n) * update(n) + tree(:,:,n) * (1-update(n));
    placement(:,:,n)    = placement_new(:,:,n) * update(n) + placement(:,:,n) * (1-update(n));
end
