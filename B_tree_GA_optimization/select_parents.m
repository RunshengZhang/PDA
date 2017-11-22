% Select Parents
% Yunyi
% Nov 12

% Description:
%   Select parents for crossover based on fitness rankings. Better results have larger ranking,
%   and they are more likely to be selected as parents

function [parent_1, parent_2] = select_parents( tree, hpwl, n )

%   Fitness Ranking
[~,~,ranking] = unique(hpwl.*(-1));             %   Better results have larger ranking
ranking = ranking./sum(ranking);                %   Normalized ranking
for i = 1:length(ranking)
    ranking_summed(i) = sum(ranking(1:i));      %   Summed(integrated) ranking
end

%   First Parent
x = rand(1);
index_1 = find(ranking_summed >= x, 1);
parent_1 = tree(:,:,index_1);

%   Second Parent
flag = 1;
while flag == 1
    x = rand(1);
    index_2 = find(ranking_summed >= x, 1);
    flag = (index_2 == index_1);                %   Second parent must be different from the first
end
parent_2 = tree(:,:,index_2);

end
