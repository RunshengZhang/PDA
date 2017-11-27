% Select Parents - Random
% Yunyi
% Nov 26

% Description:
%   Parent 1 is the current member. Parent 2 is selected randomly. 
%   This is used for updating asf_tree in "ami33" and "ami49", and for updating h_tree in "apte", "Comparator", and "hp".

function [parent_1, parent_2] = select_parents_random( tree, hpwl, n )

name = fieldnames(tree);
NP = length(hpwl);

%   First Parent
index_1 = n;
parent_1 = tree.(name{index_1});

%   Second Parent
flag = 1;
while flag == 1
    index_2 = randi(NP);
    if index_2 ~= index_1
        flag = 0;
    end
end
parent_2 = tree.(name{index_2});

end
