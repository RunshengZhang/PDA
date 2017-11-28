% Main - test only
% Yunyi

clear;
clc;

%%  0. Set Parameters
testbench = { 'ami33', 'ami49', 'apte', 'COMPARATOR_V2_VAR_K2', 'hp' };
name = char(testbench(2));
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
h_placement = h_packing( h_tree, asf_placement,asf_contour_top, asf_contour_bottom, block );

[ area, hpwl ] = evaluate( h_placement, block, net );
