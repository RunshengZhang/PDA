% Generate Representative B*-tree
% Yunyi

% Description:
%   Generate symmetry feasible representative B*-tree from symmetry group information;
%   Assume vertical axis!

% -----------------------------------------------------
% Need to use traversal order!!!
% -----------------------------------------------------

function tree = generate_asf_tree( S )

%%  2. Initialize Arrays
R               = [ S.pair(:,2); S.self ];          %   Representative
block_number    = length(R);        
perm            = randperm(block_number);           %   Random permutation
tree(1,:)       = [R(perm(1)), 0, 0];               %   Root of tree
left_parents    = [tree(1,1)];                      %   Feasible left-parent list
right_parents   = [tree(1,1)];                      %   Feasible right-parent list
right_most      = [tree(1,1)];                      %   Right-most node

%%  3. Generate Symmetry-Feasible Tree
%   Use reverse tree structure: [self, right-parent, left-parent]
for i = 2:block_number
    tree(i, 1) = R(perm(i));
    if sum(ismember(S.pair(:,2), tree(i, 1))) == 1
        %   Current representative is a symmetry pair
        %   Decide right-parent or left-parent randomly
        if (randi([0,1],1) == 1)
            tree(i, 2) = 0;                         %   No right-parent
            index = randi(length(left_parents));    %   Pick randomly from feasible parents
            tree(i, 3) = left_parents(index);
            left_parents(index) = [];               %   Delete from feasible left-parent list
            %   Update right-most node
            if tree(i, 3) == right_most
                right_most = tree(i, 1);
            end
        else
            tree(i, 3) = 0;                         %   No left-parent
            index = randi(length(right_parents));   %   Pick randomly from feasible parents
            tree(i, 2) = right_parents(index);
            right_parents(index) = [];              %   Delete from feasible right-parent list
        end
    else
        %   Current representative is a self symmetry 
        %   In right-most branch ONLY
        tree(i, 2) = 0;                             %   No right-parent
        tree(i, 3) = right_most;                    %   Left-parent is right-most node
        right_most = tree(i, 1);                    %   Update right-most node
        left_parents(left_parents==tree(i, 3)) = []; %   Update left-parent
    end

    %   Update feasible parent lists
    left_parents = [left_parents, tree(i,1)];
    right_parents = [right_parents, tree(i,1)];
end
