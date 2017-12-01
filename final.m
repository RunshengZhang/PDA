% Final function used to wrap up the result 
% Runsheng Zhang
% Nov 28(Happy Thanksgiving)(The first Tue after Thanksgiving!)

function [ placement_best, area_best, hpwl_best ] = final( h_placement,h_tree, area, hpwl, S)

    NP = size(fieldnames(h_placement),1);

    for n = 1 : NP
        
        name{n} = sprintf('NP%d', n);

    end

    [hpwl_best, best_hpwl_index] = min(hpwl)
    area_best = area(best_hpwl_index);


 

    placement_best = h_placement.(name{best_hpwl_index})
    h_tree_best = h_tree.(name{best_hpwl_index})


    for i = 1:size(placement_best,1)
        label{i} = sprintf('%d', i);
        if ismember(i,S.pair)
            rectangle('Position', placement_best(i,:),'Facecolor',[1,0,0]);
        elseif ismember(i,S.self)
            rectangle('Position', placement_best(i,:),'Facecolor',[0,0,1]);
        else
            rectangle('Position', placement_best(i,:),'Facecolor',[0,1,0]);
        end 
        text(placement_best(i,1)+(placement_best(i,3)/2) , placement_best(i,2) + (placement_best(i,4)/2) , label{i} );




    end




