% Update Tree
% Yunyi
% Oct 31

% Description:
%   1)  For each population, choose another parent that is different from itself;
%   2)  Cut the second parent (randomly choose left or right);
%   3)  Pick remaining blocks;
%   4)  Update tree and left/right parent nodes;
%       4.1)    Append subtree and update parent nodes (left/right sensitive);
%   5)  Generate new tree;
%   6)  Combine new tree (left/right sensitive);

function tree_new = update_tree( tree, algo )

[block_number, ~, ~] = size(tree);
NP = algo.NP;
tree_new = zeros(block_number, 3, NP);

for n = 1:NP

    %%   1. Choose Parents
    parent_1 = tree(:,:,n);                         %   First parent is itself
    flag = 1;
    while flag == 1
        index = randi(NP);
        flag = (index == n);                        %   Second parent must be different from the first
    end
    parent_2 = tree(:,:,index);

    %%   2. Cut the Second Parent
    cut_point = { 'left_tree', 'right_tree' };
    cut_point = char(cut_point(randi(2)));          %   Randomly decide which subtree to preserve
    
    switch cut_point
        case 'left_tree'
            %   Left tree is preserved
            index = find(parent_2(:,3) == parent_2(1,1));
            if isempty(index)
                index = block_number + 1;           %   If no right tree
            end
            subtree = parent_2(1:(index-1),:);     
        case 'right_tree'
            %   Right tree is preserved
            index = find(parent_2(:,3) == parent_2(1,1));
            subtree = [parent_2(1,:); parent_2(index:end,:)];
    end

    %%   3. Select Remaining Blocks from the First Parent (same order)
    rest = ~ismember(parent_1(:,1), subtree(:,1));
    rest = parent_1(:,1) .* rest;
    rest = rest(rest ~= 0);

    %%   4. Update Tree and Parent Nodes
    transplant_point = { 'left_tree', 'right_tree' };
    transplant_point = char(transplant_point(randi(2)));    %   Randomly decide where to transplant the subtree
    
    switch transplant_point
        case 'left_tree'
            %   Append subtree
            [m,~] = size(subtree);                      
            if strcmp(cut_point, 'right_tree')
                if m > 1
                    subtree(2,[2,3]) = subtree(2,[3,2]);    %   Exchange right/left parent
                end
            end
            offspring = subtree;
            %   Update parent nodes
            left_parents = ~ismember(offspring(:,1), offspring(:,3));
            left_parents = offspring(:,1) .* left_parents;
            left_parents = left_parents(left_parents ~= 0)';
            right_parents = ~ismember(offspring(:,1), [offspring(:,2), offspring(:,3)]); %   To obey traversal rule
            right_parents = offspring(:,1) .* right_parents;
            right_parents = right_parents(right_parents ~= 0)';
        case 'right_tree'
            %   Append root of tree
            [m,~] = size(subtree);
            if strcmp(cut_point, 'left_tree')
                if m > 1
                    subtree(2,[2,3]) = subtree(2,[3,2]);    %   Exchange right/left parent
                end
            end
            offspring = subtree(1,:);
            %   Update parent nodes
            left_parents = [];
            right_parents = offspring(1,1);
    end

    %%  5. Generate New Tree (based on "generate_tree.m")
    newtree = [];
    for i = 1:length(rest)
        newtree(i,1) = rest(i);
        %   Decide right-parent or left-parent randomly
        if (randi([0,1],1) == 1 && ~isempty(left_parents))
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
            newtree(i, 3) = 0;                          %   Only right-parent
            index = randi(length(right_parents));       %   Pick randomly from feasible parents
            newtree(i, 2) = right_parents(index);
            right_parents(index) = [];                  %   Delete from feasible right-parent list
        end

        %   Update feasible parent lists
        left_parents = [left_parents, newtree(i,1)];
        right_parents = [right_parents, newtree(i,1)];
    end

    %%  6. Combine New Tree 
    switch transplant_point
        case 'left_tree'
            offspring = [offspring; newtree];
        case 'right_tree'
            offspring = [offspring; newtree; subtree(2:end,:)];
    end

    tree_new(:,:,n) = offspring;

end
