% Update ASF B* Tree
% Nov 19
% Yunyi

% Change Log:
%   Nov 26: Change data type of "asf_tree" and "asf_tree_new" to struct.

% Description:
%   Update ASF representative B* tree with the new crossover operator; First parent is the current member
%   in population, second parent is chosen based on HPWL ranking. It works for testbench "apte", 
%   "comparator", and "hp", in which symmetry blocks dominate.

% Outline:
%   1)  Choose the second parent based on fitness using ranking;
%   2)  Select a node (not root) from parent 2, inherit its subtree;
%   3)  Pick remaining tree from parent 1;
%   4)  Update tree, left/right parent nodes, and right-most node;
%   5)  Generate new tree;
%   6)  Redo NP times.

function asf_tree_new = update_asf_tree( asf_tree, algo, hpwl, S )

name = fieldnames(asf_tree);
NP = algo.NP;
asf_tree_new = struct();

for n = 1:NP

    %%   1. Choose Parents
    [parent_1, parent_2] = select_parents( asf_tree, hpwl, n );

    %%   2. Select Subtree from the Second Parent
    [block_number, ~] = size(parent_2);
    index_start = randi([2,block_number]);                  %   Select a non-root node
    perm = parent_2(1:(index_start-1), 1);                  %   Previous nodes
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
    %   Need to delete repeated symmetry pair representative

    rest = ~ismember(parent_1(:,1), subtree(:,1));
    rest = parent_1(find(rest), :);
    repeat = find(sum(ismember(S.pair, subtree(:,1)), 2));          
    repeat = reshape(S.pair(repeat, :), 1, []);             %   Find all representative in subtree
    rest(find(ismember(rest(:,1), repeat)), :) = [];        %   Delete repeated representative

    %%   4. Update Tree and Parent Nodes
    %       4.1 Append new tree
    offspring = subtree;                  
    offspring(1,2:3) = [0,0];                               %   Make the first node of subtree as root

    %       4.2 Update parent nodes (based on "generate_tree.m")
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

    %       4.3 Update right-most node
    %       Search the right-most tree in offspring to find the right-most node
    flag = 1;
    index = 1;                                              %   Start from the root
    while flag == 1    
        right_most = offspring(index,1);                    %   Update right-most node
        index = find(ismember(offspring(:,3), right_most)); %   Find its right child
        if isempty(index)
            flag = 0;                                       %   Final right-most child is found
        end
    end

    %%  5. Generate New Tree
    %   Try to keep the relative position in the first parent;
    %   Special rule applys for self symmetry node.

    [rest_number, ~] = size(rest);
    newtree = [];

    for i = 1:rest_number
        newtree(i,1) = rest(i,1);
        newtree(i,4) = rest(i,4);
        if ismember(newtree(i,1), S.self)
            %   Append self symmetry block to right-most node
            newtree(i, 2) = 0;                              %   No right-parent
            newtree(i, 3) = right_most;                     %   Left-parent is right-most node
            right_most = newtree(i, 1);                     %   Update right-most node
            index = find(ismember(left_parents, newtree(i, 3)));
            left_parents(index:end) = [];
            index = find(right_parents == newtree(i, 3));
            if isempty(index)
                index = 1;                              
            end
            right_parents(index:end) = [];
        elseif ismember(rest(i,3), left_parents)
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
    asf_tree_new.(name{n}) = offspring;
end
