% Update HB* tree
% Nov 21
% Yunyi

% Description:
%   Update hierarchical HB* tree. with the new crossover operator. First parent is the current member
%   in population, second parent is chosen based on HPWL ranking. It works for testbench "ami33" and "ami49"
%   in which symmetry blocks dominate.

% Outline:
%   1)  Contour-node-related update of h-tree;
%   2)  Choose the second parent based on fitness using ranking;
%   3)  Select a node (not root, not contour) from parent 2, inherit its subtree;
%   4)  Pick remaining tree from parent 1;
%   5)  Update tree, left/right parent nodes;
%   6)  Generate new tree;
%   7)  Redo NP times.

function h_tree_new = update_h_tree( h_tree, asf_contour, asf_contour_new, block, algo, hpwl )

%   Input: h_tree, asf_contour, asf_contour_new are structs.

NP          = algo.NP;
h_tree_new  = struct();
name        = fieldnames(asf_contour);

%%  1. Contour-node-related Update
for n = 1:NP
    tree = h_tree.(name{n});                                            %   Current h_tree
    tree_new = [];                                                      %   New h_tree
    [contour_number, ~] = size(asf_contour.(name{n}));
    [contour_number_new, ~] = size(asf_contour_new.(name{n}));

    if contour_number_new > contour_number
        %   Case 1: Add new contour nodes
        for i = (contour_number+1):contour_number_new
            contour_tree(i - contour_number) = [-i, -i+1, 0];           %   New contour tree to be added
        end
        index = find(tree == (-contour_number));                        %   Last contour node in h_tree
        tree_new(1:index) = tree(1:index);
        temp = tree((index+1):end);
        tree_new((index+1):(index+1+contour_number_new-contour_number)) = contour_tree; %   Insert contour tree
        tree_new = [tree_new; temp];                                    %   Updated h_tree
    elseif contour_number_new < contour_number
        %   Case 2: Relocate dangling nodes

    end
end

