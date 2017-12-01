% Update HB* tree
% Nov 21
% Yunyi

% Change Log:
%   Nov 27: Use two different parent-selecting function;
%           Fix bugs with contour_tree;
%   Nov 28: Update asf_contour_new when updating the h_tree;
%   Nov 29: Fix bugs with contour_tree problem;
%           Testbench-specific parent selection.
%   Dec 1:  Update to deal with rotation.

% Description:
%   Update hierarchical HB* tree. with the new crossover operator. First parent is the current member
%   in population, second parent is chosen based on HPWL ranking (for "ami33" and "ami49") or randomly
%   (for "apte", "hp"). DO NOT update h-tree for comparator.

% Outline:
%   1)  Contour-node-related update of h-tree;
%           Case 1: Add new contour nodes;
%           Case 2: Relocate dangling nodes, and delete old contour nodes.
%   2)  Choose the second parent based on fitness using ranking;
%   3)  Select a node (not root, not contour) from parent 2, inherit its subtree;
%   4)  Pick remaining tree from parent 1;
%   5)  Update tree, left/right parent nodes;
%   6)  Generate new tree;
%   7)  Redo NP times.

function [h_tree_new, asf_contour_temp, placement_temp] = update_h_tree( h_tree, asf_contour, asf_contour_new, placement, algo, hpwl, testbench )

NP                  = algo.NP;
h_tree_new          = struct();
asf_contour_temp    = struct();
placement_temp      = struct();
name                = fieldnames(asf_contour);

%%  1. Contour-node-related Update
for n = 1:NP
    tree = h_tree.(name{n});                                            %   Old h_tree
    tree_new = tree;                                                    %   New h_tree
    [contour_number, ~] = size(asf_contour.(name{n}));
    [contour_number_new, ~] = size(asf_contour_new.(name{n}));
    [block_number, ~] = size(tree);

    if contour_number_new > contour_number
        %   Case 1: Add new contour nodes
        tree_new = [];
        contour_tree = [];
        for i = (contour_number+1):contour_number_new
            contour_tree(i - contour_number,:) = [-i, -i+1, 0, 0];      %   New contour tree to be added
        end
        index = find(tree(:,1) == (-contour_number));                   %   Last contour node in h_tree
        tree_new(1:index, :) = tree(1:index, :);
        temp = tree((index+1):end, :);
        tree_new = [tree_new; contour_tree; temp];                      %   Insert new contour tree
    
    elseif contour_number_new < contour_number
        %   Case 2: Relocate dangling nodes, and delete old contour nodes
        %   a)  Relocate children of old contour nodes
        contour_old = [-contour_number:1:-contour_number_new - 1];      %   Old contour nodes
        contour_old = fliplr(contour_old);
        
        for i = 1:length(contour_old)
            %  a.1) Find the subtree to be relocated
            index_start = find(ismember(tree(:,3), contour_old(i)));    %   Contour node right child
            if ~isempty(index_start)
                %   Contour node has child
                tree_new = [];
                perm = tree(1:(index_start-1), 1);                      %   Previous nodes
                index_2 = find(ismember(tree((index_start+1):end, 2), perm),1);
                index_3 = find(ismember(tree((index_start+1):end, 3), perm),1);
                if isempty(index_2)
                    index_2 = block_number - length(perm);
                end
                if isempty(index_3)
                    index_3 = block_number - length(perm);
                end
                index_stop = min(index_2, index_3) - 1 + index_start;
                subtree = tree(index_start:index_stop, :);              %   Subtree to be relocated

                %   a.2) Delete the subtree from old tree
                for j = 1:(index_stop-index_start+1)
                    index = find(ismember(tree(:,1), subtree(j, 1)));
                    tree(index, :) = [];
                end

                %   a.3) Find the node to relocate to
                index = find(ismember(tree(:,3), -contour_number_new)); %   Nearest contour node right child
                if isempty(index)
                    %   No right child -> Append to the nearest contour node
                    index = find(ismember(tree(:,1), -contour_number_new)); %   Nearest contour node index
                    tree_new(1:index, :) = tree(1:index, :);
                    temp = tree((index+1):end, :);
                    subtree(1,2:3) = [0, tree(index, 1)];
                    tree_new = [tree_new; subtree;, temp];              %   Append 
                else
                    %   Right child exists -> Find its left-most child
                    flag = 1;
                    while flag == 1
                        index_2 = find(ismember(tree(:,2), tree(index,1)));
                        if isempty(index_2)
                            flag = 0;                                   %   Left-most child is found
                        else
                            index = index_2;
                        end                       
                    end
                    %   Append to this left-most child
                    tree_new(1:index, :) = tree(1:index, :);
                    temp = tree((index+1):end, :);
                    subtree(1,2:3) = [tree(index, 1), 0];
                    tree_new = [tree_new; subtree;, temp];              %   Append               
                end
            
            tree = tree_new;                                            %   Do the update iteratively!
            end            
        end

        %   b)  Delete old contour ndoes
        for i = 1:length(contour_old)
            index = find(ismember(tree_new(:,1), contour_old(i)));
            tree_new(index, :) = [];
        end
    end

    h_tree.(name{n}) = tree_new;                                        %   Replace original tree
end

%   No need to update h-tree for "comparator"
if strcmp(testbench,'COMPARATOR_V2_VAR_K2')
    h_tree_new = h_tree;
    asf_contour_temp = asf_contour_new;
    placement_temp = placement;
    return;
end

%   --------------------------------------------------------------------------------------------------------
for n = 1:NP

    %%  2. Choose Parents
    if strcmp(testbench,'apte')||strcmp(testbench,'hp')
        [parent_1, parent_2, parent_2_index] = select_parents_random( h_tree, hpwl, n );    %   For "apte", "hp"
    elseif strcmp(testbench,'ami33')||strcmp(testbench,'ami49')
        [parent_1, parent_2, parent_2_index] = select_parents( h_tree, hpwl, n );           %   For "ami33", "ami49"
    end

    %%   3. Select Subtree from the Second Parent
    [block_number, ~] = size(parent_2);

    flag = 1;
    while flag == 1   
        index_start = randi([2,block_number]);                  %   Select a non-root node
        if parent_2(index_start, 1) < 0
            flag = 1;                                           %   Cannot select contour nodes
        else
            flag = 0;                                           
        end
    end

    perm = parent_2(1:(index_start-1), 1);                      %   Previous nodes
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

    %%   4. Select Remaining Tree from the First Parent (same order)
    %   If hierarchy node is in "subtree", delete all contour nodes in "rest"
    rest = ~ismember(parent_1(:,1), subtree(:,1));
    rest = parent_1(find(rest), :);

    index = find(parent_2(:,1) == (-1));
    hier_node = parent_2(index, 3);                             %   Hierarchy node ID in "subtree"
    if ~isempty(find(subtree(:,1) == hier_node))
        index = find(rest(:,1) < 0);
        rest(index,:) = [];                                     %   Delete redundant contour nodes
        asf_contour_temp.(name{n}) = asf_contour_new.(name{parent_2_index});    %   Update asf contour
        placement_temp.(name{n}) = placement.(name{parent_2_index});
    else
        asf_contour_temp.(name{n}) = asf_contour_new.(name{n});
        placement_temp.(name{n}) = placement.(name{n});
    end

    %%   5. Update Tree and Parent Nodes
     %   Append new tree
    offspring = subtree;                  
    offspring(1,2:3) = [0,0];                                   %   Make the first node of subtree as root
    
    %   Update parent nodes (based on "generate_tree.m")
    [subtree_number, ~] = size(offspring);
    left_parents = [];
    right_parents = [];

    for i = 1:subtree_number
        if offspring(i, 1) > 0
        %   Deal with only non-contour nodes
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

            %   Add feasible parents
            right_parents = [right_parents, offspring(i,1)];
            if offspring(i, 1) == hier_node
                [contour_number, ~] = size(asf_contour_new.(name{parent_2_index}));
                contour_node = (-contour_number):-1;
                contour_node = fliplr(contour_node);
                left_parents = [left_parents, contour_node];
            else
                left_parents = [left_parents, offspring(i,1)];
            end
        end
    end

    %%  6. Generate New Tree
    %   Try to keep the relative position in the first parent

    %   6.1 Decide if "rest" has hierarchy node
    flag = any(ismember(rest(:,1), hier_node));
    if flag == 1
        index = find(rest(:,1) < 0);
        contour_number = length(index);                             %   Contour number in "rest"
        rest(index, :) = [];                                        %   Delete contour tree in "rest"
    end

    %   6.2 Generate Tree
    [rest_number, ~] = size(rest);
    newtree = [];

    for i = 1:rest_number
        newtree(i,1) = rest(i,1);
        if ismember(rest(i,3), left_parents) && (rest(i,3)>0)
            %   Keep same left parent
            newtree(i, 2) = 0;
            newtree(i, 3) = rest(i, 3);
            newtree(i, 4) = rest(i ,4);                             %   Keep same rotation
            index = find(ismember(left_parents, newtree(i, 3)));
            left_parents(index:end) = [];
            index = find(right_parents == newtree(i, 3));
            if isempty(index)
                index = 1;                              
            end
            right_parents(index:end) = [];
        elseif ismember(rest(i,2), right_parents) && (rest(i,2)>0)
            %   Keep same right parent
            newtree(i, 3) = 0;
            newtree(i, 2) = rest(i, 2);
            newtree(i, 4) = rest(i ,4);                             %   Keep same rotation
            index = find(ismember(right_parents, newtree(i, 2)));
            right_parents(index) = []; 
        elseif (randi([0,1],1) == 1 && ~isempty(left_parents))
            %   Pick parent randomly (left)
            newtree(i, 2) = 0;                          %   Only left-parent
            newtree(i ,4) = randi([0,1]);               %   Random rotation
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
            newtree(i, 4) = randi([0,1]);               %   Random rotation
            index = randi(length(right_parents));       %   Pick randomly from feasible parents
            newtree(i, 2) = right_parents(index);
            right_parents(index) = [];                  %   Delete from feasible right-parent list
        end

        %   Update feasible parent lists
        right_parents = [right_parents, rest(i,1)];
        if rest(i,1) == hier_node
            %   Hierarchy node
            contour_node = (-contour_number):-1;            %   Contour node ID starts from -1, -2 ...
            contour_node = fliplr(contour_node);
            left_parents = [left_parents, contour_node];    %   Add contour nodes as feasible left parents
        else
            left_parents = [left_parents, rest(i,1)];
        end 
    end

    %   6.3 Contour Tree
    if (flag == 1) || ((flag == 0) && (isempty(find(subtree(:,1)<0))))
        %   "rest" has hierarchy node, or "subtree" has hierarchy node but no contour tree
        %   Generate Contour Tree
        contour_tree = [];
        contour_tree(:,1) = contour_node;
        contour_tree(1,2:4) = [0, hier_node, 0];
        contour_tree(2:end,2:4) = [contour_tree(1:(end-1), 1), zeros(contour_number-1,1), zeros(contour_number-1,1)];

        %   Insert Contour Tree
        index = find(newtree(:,3)<0, 1);
        if ~isempty(index)
            newtree = [newtree(1:(index-1),:); contour_tree; newtree(index:end,:)];
        else
            newtree = [newtree; contour_tree];
        end
    end

    offspring = [offspring; newtree];
    h_tree_new.(name{n}) = offspring;
end
