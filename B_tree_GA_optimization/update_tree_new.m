% Update Tree - Version 2
% Yunyi
% Nov 16

% Change Log:
%   Nov 16: Change the rule for cut point. Pick a node (not root) from parent 2, and it's subtree is
%           inherited. This subtree is adopted as the root of the offspring. Rest blocks are selected 
%           from parent 1 while keeping the relative position as much as possible.

% Outline:
%   1)  Choose two parents based on their fitness using ranking;
%   2)  Select a node (not root) from parent 2, inherit its subtree;
%   3)  Pick remaining tree from parent 1;
%   4)  Update tree and left/right parent nodes;
%   5)  Generate new tree;
%   6)  Redo NP times.

function tree_new = update_tree( tree, algo, hpwl )

[block_number, ~, ~] = size(tree);
NP = algo.NP;
tree_new = zeros(block_number, 3, NP);

for n = 1:NP

    %%   1. Choose Parents
    [parent_1, parent_2] = select_parents( tree, hpwl, n );

    %%   2. Select Subtree from the Second Parent
    index_start = randi([2,block_number]);                %   Select a non-root node
    perm = parent_2(1:(index_start-1), 1);                %   Previous nodes
    index_2 = find(ismember(parent_2((index_start+1):end, 2), perm),1);
    index_3 = find(ismember(parent_2((index_start+1):end, 3), perm),1);
    if isempty(index_2)
        index_2 = block_number - length(perm);
    end
    if isempty(index_3)
        index_3 = block_number - length(perm);
    end
    index_stop = min(index_2, index_3) - 1 + index_start;
    subtree = parent_2(index_start:index_stop, :);
    
    %%   3. Select Remaining Tree from the First Parent (same order)
    rest = ~ismember(parent_1(:,1), subtree(:,1));
    rest = parent_1(find(rest), :);

    %%   4. Update Tree and Parent Nodes
    %   Append new tree
    offspring = subtree;                  
    offspring(1,2:3) = [0,0];                               %   Make the first node of subtree as root

    %   Update parent nodes (based on "generate_tree.m")
    [subtree_number, ~] = size(offspring);
    left_parents = [offspring(1,1)];
    right_parents = [offspring(1,1)];

    for i = 2:subtree_number
        if offspring(i, 2) == 0
            %   Only left parent
            index = find(ismember(left_parents, offspring(i, 3)));
            left_parents(index:end) = [];
            index = find(right_parents == offspring(i, 3));
            if isempty(index)
                index = 1;                              
            end
            right_parents(index:end) = [];
        elseif offspring(i, 3) == 0
            %   Only right parent
            index = find(ismember(right_parents, offspring(i, 2)));
            right_parents(index) = [];    
        end
        left_parents = [left_parents, offspring(i,1)];
        right_parents = [right_parents, offspring(i,1)];
    end
    
    %%  5. Generate New Tree
    %   Try to keep the relative position in the first parent

    [rest_number, ~] = size(rest);
    newtree = [];

    for i = 1:rest_number
        newtree(i,1) = rest(i,1);
        if ismember(rest(i,3), left_parents)
            %   Keep same left parent
            newtree(i, 2) = 0;
            newtree(i, 3) = rest(i, 3);
            index = find(ismember(left_parents, newtree(i, 3)));
            left_parents(index:end) = [];
            index = find(right_parents == newtree(i, 3));
            if isempty(index)
                index = 1;                              
            end
            right_parents(index:end) = [];
        elseif ismember(rest(i,2), right_parents)
            %   Keep same right parent
            newtree(i, 3) = 0;
            newtree(i, 2) = rest(i, 2);
            index = find(ismember(right_parents, newtree(i, 2)));
            right_parents(index) = []; 
        elseif (randi([0,1],1) == 1 && ~isempty(left_parents))
            %   Pick parent randomly (left)
            newtree(i, 2) = 0;                          %   Only left-parent
            index = randi(length(left_parents));        %   Pick randomly from feasible parents
            newtree(i, 3) = left_parents(index);
            left_parents(index:end) = [];               %   Delete succeedings from feasible left-parent list
            index = find(right_parents==newtree(i,3));
            if isempty(index)
                index = 1;                              %   Clear all
            end
            right_parents(index:end) = [];              %   Delete succeedings from feasible right-parent list
        else 
            %   Pick parent randomly (right)
            newtree(i, 3) = 0;                          %   Only right-parent
            index = randi(length(right_parents));       %   Pick randomly from feasible parents
            newtree(i, 2) = right_parents(index);
            right_parents(index) = [];                  %   Delete from feasible right-parent list
        end

        %   Update feasible parent nodes
        left_parents = [left_parents, newtree(i,1)];
        right_parents = [right_parents, newtree(i,1)];
    end
    
    offspring = [offspring; newtree];
    tree_new(:,:,n) = offspring;
end
