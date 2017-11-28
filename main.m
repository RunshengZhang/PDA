% Analog Placement Main Flow - Single Objective GA
% Yunyi
% Oct 26 2017

function [ placement, area, hpwl ] = place()

%%  0. Set Parameters
testbench = { 'ami33', 'ami49', 'apte', 'COMPARATOR_V2_VAR_K2', 'hp' };
name = char(testbench(3));
algo = set_algorithm_param();           %   e.g. population, itermax ...

%%  1. Parse Inputs
[block, net, S] = read_input( name );                 

%%  2. Initial Tree, Placement, Evaluation
%   2.1 Generate a Population of Random Representative ASF B* tree
asf_tree = generate_asf_tree( S, algo );

%   2.2 Pack ASF B* tree
[ asf_placement, asf_contour_top, asf_contour_bottom ] = asf_packing( asf_tree, block, S );

%   2.3 Generate Random HB* tree
h_tree = generate_h_tree( asf_contour_top, block, S );

%   2.4 Pack HB* tree
h_placement = h_packing( h_tree, asf_placement, asf_contour_top, asf_contour_bottom, block );

%   2.5 Evaluate Cost
[ area, hpwl ] = evaluate( h_placement, block, net );

%%  3. Optimization Loop using Single Objective GA
for i = 1:algo.itermax
    %   3.1 Update Population (Crossover, Mutation)
    asf_tree_new = update_asf_tree( asf_tree, algo, hpwl, S );                      %   ASF tree
    [ asf_placement_new, asf_contour_top_new, asf_contour_bottom_new ] = asf_packing( asf_tree_new, block, S );    %   ASF Packing
    [h_tree_new, asf_contour_top_new] = update_h_tree( h_tree, asf_contour_top, asf_contour_top_new, algo, hpwl );   %   HB tree
    h_placement_new = h_packing( h_tree_new, asf_placement_new, asf_contour_top_new, asf_contour_bottom_new, block );            %   HB Packing

    %   3.2 Evaluate Cost
    [ area_new, hpwl_new ] = evaluate( h_placement_new, block, net );

    %   3.3 Selection
    [ asf_tree, asf_contour_top, h_tree, h_placement, area, hpwl ] = selection( asf_tree, asf_contour_top, h_tree, h_placement, area, hpwl, asf_tree_new, asf_contour_top_new, h_tree_new, h_placement_new, area_new, hpwl_new, algo, block ); 
end

%%  4. Final Result, Summary, and Plotting
[ placement, area_best, hpwl_best ] = final( h_placement, area, hpwl );
