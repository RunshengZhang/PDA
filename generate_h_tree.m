% Generate Random HB* Tree
% Yunyi
% Nov 5

% Change Log:
%   Dec 1:  Add another colomn in h_tree for rotation.

function h_tree = generate_h_tree( asf_contour_top, block, S )

%%  1. Obtain Symmetry Blocks
%   Symmetry blocks are skipped in HB* tree generation, since they are in hierarchy node
S.pair = reshape(S.pair, [1, length(S.pair(:,1))*2]);
S.self = reshape(S.self, [1, length(S.self)]);
sym = [S.pair, S.self];

%%  2. Initialize Arrays
name                = fieldnames(asf_contour_top);              %   A cell array with length NP
NP                  = size(name,1);
[block_number, ~]   = size(block);
block_number        = block_number + 1;                         %   Adding the hierarchy node
h_tree              = struct();

%%  3. Generate Random Tree
for n = 1:NP
    [contour_number, ~] = size(asf_contour_top.(name{n}));      %   Current member's contour number
    perm                = randperm(block_number);               %   Current member's block permutation
    rotation            = randi([0,1],[1, block_number]);       %   Random rotation
    tree                = zeros(block_number, 3);
    contour_tree        = zeros(contour_number, 3);
    left_parents        = [];
    right_parents       = [];

    %   3.1 Normal Tree
    for i = 1:block_number
        tree(i,1) = perm(i);

        %   Rotation
        if tree(i, 1) == block_number
            %   No rotation for hierarchy block
            tree(i ,4) = 0;
        else
            tree(i, 4) = rotation(i);
        end

        if ~ismember(perm(i), sym)
            %   Non-symmetry block: Decide right-parent or left-parent randomly            
            if (randi([0,1],1) == 1)           
                if isempty(left_parents) && isempty(right_parents)
                    tree(i,2:3) = [0, 0];                       %   Root
                else
                    tree(i, 2) = 0;                             %   Only left-parent
                    index = randi(length(left_parents));        %   Pick randomly from feasible parents
                    tree(i, 3) = left_parents(index);
                    left_parents(index:end) = [];               %   Delete succeedings from feasible left-parent list
                    index = find(right_parents==tree(i,3));
                    if isempty(index)
                        index = 1;                              %   Clear all
                    end
                    right_parents(index:end) = [];              %   Delete succeedings from feasible right-parent list
                end
            else
                if isempty(left_parents) && isempty(right_parents)
                    tree(i,2:3) = [0, 0];                       %   Root
                else
                    tree(i, 3) = 0;                             %   Only right-parent
                    index = randi(length(right_parents));       %   Pick randomly from feasible parents
                    tree(i, 2) = right_parents(index);
                    right_parents(index) = [];                  %   Delete from feasible right-parent list
                end
            end

            %   Update feasible parent lists
            right_parents = [right_parents, tree(i,1)];
            if tree(i,1) == block_number
                %   Hierarchy node
                contour_node = (-contour_number):-1;            %   Contour node ID starts from -1, -2 ...
                contour_node = fliplr(contour_node);
                left_parents = [left_parents, contour_node];    %   Add contour nodes as feasible left parents
            else
                left_parents = [left_parents, tree(i,1)];
            end 
        else
            %   Symmetry block
            tree(i,2:3) = [0, 0];                               %   Delete afterwards
        end
    end
    
    %   3.2 Delete Symmetry Blocks
    for i = 0:block_number-1
        if ismember(tree(block_number-i,1), sym)
            tree(block_number-i,:) = [];
        end
    end

    %   3.3 Contour Tree
    %       Generate Contour Tree
    contour_tree(:,1) = contour_node;
    contour_tree(1,2:4) = [0, block_number, 0];
    contour_tree(2:end,2:4) = [contour_tree(1:(end-1), 1), zeros(contour_number-1,1), zeros(contour_number-1,1)];

    %       Insert Contour Tree
    index = find(tree(:,3)<0, 1);
    if ~isempty(index)
        tree = [tree(1:(index-1),:); contour_tree; tree(index:end,:)];
    else 
        tree = [tree; contour_tree];                              %   Append at the end
    end
    
    h_tree.(name{n}) = tree;
end
