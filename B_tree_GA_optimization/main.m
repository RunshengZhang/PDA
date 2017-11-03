% B* tree GA Optimization
% Yunyi
% Oct 29 2017
% A testbench using single-objective GA to optimize B*-tree placement

%%  0. Set Testbench and Global Parameters
algo = set_algorithm_param();           %   e.g. population, itermax ...

block = {   'bk1',2,3;
            'bk2',2,2;
            'bk3',2,1;
            'bk4',3,1;
            'bk5',2,4;
            'bk6',2,2;
            'bk7',3,3;
            'bk8',3,1;
            'bk9',1,2;
            'bk10',1,3
        };
block = string(block);

net.net1 = [2,5];
net.net2 = [1,3,7,10];
net.net3 = [2,7,8];
net.net4 = [4,5];
net.net5 = [6,9];
net.net6 = [9,10];
net.net7 = [1,2,3,4,6,7,9];
net.net8 = [1,2,3,5,7,8,9,10];

best_member = struct();

%%  2. Initial Tree, Placement, Evaluation
%   2.0 Calculate Block Area
block_area = compute_block_area( block );

%   2.1 Generate a Population of Random B* tree
tree = generate_tree( block, algo );

%   2.2 Pack  B* tree
placement = packing( tree, block );

%   2.3 Evaluate Cost
[ area, hpwl ] = evaluate( placement, block, net );

%%  3. Optimization Loop using Single Objective GA
for iteration = 1:algo.itermax
    %   3.1 Update Population (Crossover, Mutation)
    tree_new = update_tree( tree, algo );                             
    placement_new= packing( tree_new, block );    

    %   3.2 Evaluate Cost
    [ area_new, hpwl_new ] = evaluate( placement_new, block, net );

    %   3.3 Selection
    [ tree, placement, area, hpwl ] = selection( tree, placement, area, hpwl, tree_new, placement_new, area_new, hpwl_new, algo, block_area ); 

    %   3.4 Get Current Best Member
    best_member = get_best( tree, placement, area, hpwl, algo, block_area, iteration, best_member );
end

%%  4. Final Result, Summary, and Plotting
final_result = final( best_member );
status = plot_placement( final_result.placement, block );
