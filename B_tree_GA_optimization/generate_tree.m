% Generate Tree
% Yunyi
% Oct 29 
% Generate a random B* tree with travesal order

% Rules:
%   1)  If a node is selected as left-parent, 
%       itself and its succeeding nodes are deleted from both parent lists; 

function b_tree = generate_tree( block, algo )

%%  1. Initialize Arrays
NP             = algo.NP;                               %   Size of population
[block_number, ~] = size(block);
tree            = zeros(block_number, 3);
b_tree          = zeros(block_number, 3, NP);

%%  2. Generate Random Tree
for n = 1:NP
    perm                = randperm(block_number);
    tree(1,:)           = [perm(1), 0, 0];              %   Root of tree
    left_parents        = [tree(1,1)];                  %   Feasible left-parent list
    right_parents       = [tree(1,1)];                  %   Feasible right-parent list

    for i = 2:block_number
        tree(i, 1) = perm(i);
        %   Decide right-parent or left-parent randomly
        if (randi([0,1],1) == 1)
            tree(i, 2) = 0;                             %   Only left-parent
            index = randi(length(left_parents));        %   Pick randomly from feasible parents
            tree(i, 3) = left_parents(index);
            left_parents(index:end) = [];               %   Delete succeedings from feasible left-parent list
            index = find(right_parents==tree(i,3));
            if isempty(index)
                index = 1;                              %   Clear all
            end
            right_parents(index:end) = [];              %   Delete succeedings from feasible right-parent list
        else
            tree(i, 3) = 0;                             %   Only right-parent
            index = randi(length(right_parents));       %   Pick randomly from feasible parents
            tree(i, 2) = right_parents(index);
            right_parents(index) = [];                  %   Delete from feasible right-parent list
        end

        %   Update feasible parent lists
        left_parents = [left_parents, tree(i,1)];
        right_parents = [right_parents, tree(i,1)];
    end

    b_tree(:,:,n) = tree;
end
