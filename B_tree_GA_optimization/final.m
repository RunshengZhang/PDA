% Final Result
% Yunyi
% Nov 1

function final_result = final( best )

final.tree = best.tree(:,:,end);
final.placement = best.placement(:,:,end);
final.area = best.area(end);
final.hpwl = best.hpwl(end);

final_result = final;
