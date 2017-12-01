% Selection
% Yunyi
% Nov 28

function    [ asf_tree, asf_contour_top, asf_contour_bottom, h_tree, h_placement, area, hpwl ] = selection( asf_tree, asf_contour_top, asf_contour_bottom, h_tree, h_placement, area, hpwl, asf_tree_new, asf_contour_top_new, asf_contour_bottom_new, h_tree_new, h_placement_new, area_new, hpwl_new, algo, block ) 

DS = algo.DS;
AP = algo.AP;
NP = algo.NP;
name = fieldnames(asf_tree);
update = zeros(1,NP);

%%  1. Compute Area Constraint
[block_number, ~] = size(block);
temp = str2double(block(:,2:3));
block_area = sum(temp(:,1).*temp(:,2));
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
    if update(n) == 1
        asf_tree.(name{n}) = asf_tree_new.(name{n});
        asf_contour_top.(name{n}) = asf_contour_top_new.(name{n});
        asf_contour_bottom.(name{n}) = asf_contour_bottom_new.(name{n});
        h_tree.(name{n}) = h_tree_new.(name{n});
        h_placement.(name{n}) = h_placement_new.(name{n});
    end
end
