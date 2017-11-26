% Generate Representative B*-tree
% Yunyi

% Change Log:
%   Nov 19: Take into account choosing representative block randomly.
%           The fourth column denotes representative block: choosing from 1 and 2.
%   Nov 20: Change parent updating procedure for self symmetry node.
%   Nov 26: Change data type of "asf_tree" to struct.

% Description:
%   Generate symmetry feasible representative B*-tree from symmetry group information;
%   Assume vertical axis!

function asf_tree = generate_asf_tree( S, algo )

asf_tree = struct();

for n = 1:algo.NP

    %%  1. Choose Representative Randomly
    clear R;
    [symmetry_pair_number,~] = size(S.pair);
    represent = randi([1,2], [1,symmetry_pair_number]);     %   Random symmetry pair representative
    for i = 1:symmetry_pair_number
        R(i,1:2) = [S.pair(i, represent(i)), represent(i)]; %   Second column is 1 or 2 for pairs
    end
    R_self = [S.self', ones(length(S.self), 1)];        %   Second column is 1 for selfs
    R = [R; R_self];                                    %   Add self symmetry

    %%  2. Initialize Arrays
    [block_number,~]= size(R);        
    perm            = randperm(block_number);           %   Random permutation
    tree(1,:)       = [R(perm(1),1),0,0,R(perm(1),2)];  %   Root of tree
    left_parents    = [tree(1,1)];                      %   Feasible left-parent list
    right_parents   = [tree(1,1)];                      %   Feasible right-parent list
    right_most      = [tree(1,1)];                      %   Right-most node

    %%  3. Generate Symmetry-Feasible Tree
    %   Use reverse tree structure: [self, right-parent, left-parent]
    for i = 2:block_number
        tree(i, 1) = R(perm(i), 1);
        tree(i, 4) = R(perm(i), 2);
        if ismember(tree(i, 1), S.pair)
            %   Current representative is a symmetry pair
            %   Decide right-parent or left-parent randomly
            if (randi([0,1],1) == 1)
                tree(i, 2) = 0;                         %   No right-parent
                index = randi(length(left_parents));    %   Pick randomly from feasible parents
                tree(i, 3) = left_parents(index);
                left_parents(index:end) = [];           %   Delete succeedings from feasible left-parent list
                index = find(right_parents==tree(i,3));
                if isempty(index)
                    index = 1;                          %   Clear all
                end
                right_parents(index:end) = [];          %   Delete succeedings from feasible right-parent list
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
            index = find(ismember(left_parents, tree(i, 3)));
            left_parents(index:end) = [];
            index = find(right_parents == tree(i, 3));
            if isempty(index)
                index = 1;                              
            end
            right_parents(index:end) = [];
        end

        %   Update feasible parent lists
        left_parents = [left_parents, tree(i,1)];
        right_parents = [right_parents, tree(i,1)];
    end

    name = sprintf('NP%d', n);
    asf_tree.(name) = tree;
end
