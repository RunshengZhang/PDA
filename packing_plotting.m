% Packing and Plotting of a B* Tree
% Yunyi
% Oct 21, 2017

%%  1. Define Blocks
block = [   "bk1",2,3;
            "bk2",2,2;
            "bk3",2,1;
            "bk4",3,1;
            "bk5",2,4;
            "bk6",2,2;
            "bk7",3,3;
            "bk8",3,1];

%%  2. Define Tree Structure
%   element: [permutation_order, right-parent, left-parent]
tree = [    1,0,0;
            2,1,0;
            4,2,0;
            6,4,0;
            3,0,1;
            5,3,0;
            7,5,0;
            8,0,3];

%%  3. Packing
placement = packing( block, tree );

%%  4. Plotting
status = plot_placement( placement, block );
