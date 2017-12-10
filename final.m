% Final function used to wrap up the result 
% Runsheng Zhang
% Nov 28(Happy Thanksgiving)(The first Tue after Thanksgiving!)

function final_result = final( best_member, S, algo)

    %   Final Result
    final_result.placement = best_member.placement(:,:,algo.itermax);
    final_result.area = best_member.area(algo.itermax);
    final_result.hpwl = best_member.hpwl(algo.itermax);

    %   Plot Placement
    for i = 1:size(final_result.placement,1)
        label{i} = sprintf('%d', i);
        if ismember(i,S.pair)
            rectangle('Position', final_result.placement(i,:),'Facecolor',[255/256,120/256,130/256]);
        elseif ismember(i,S.self)
            rectangle('Position', final_result.placement(i,:),'Facecolor',[255/256,120/256,130/256]);
        else
            rectangle('Position', final_result.placement(i,:),'Facecolor',[253/256,216/256,160/256]);
        end 
        text(final_result.placement(i,1)+(final_result.placement(i,3)/2) , final_result.placement(i,2) + (final_result.placement(i,4)/2) , label{i} );
    end
