% Compute Block Area
% Yunyi
% Nov 1

function block_area = compute_block_area( block )

[block_number, ~] = size(block);
temp = str2double(block(:,2:3));
block_area = sum(temp(:,1).*temp(:,2));
