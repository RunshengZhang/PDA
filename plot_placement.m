% Plot Placement
% Yunyi
% Oct 21, 2017

function status = plot_placement( placement, block )

[block_number, m] = size(block);
pos = zeros(1,4);
color =  [112/255,176/255,241/255];

for i = 1:block_number
    pos(1) = placement(i,2);
    pos(2) = placement(i,3);
    pos(3) = str2double(block(placement(i,1),2));
    pos(4) = str2double(block(placement(i,1),3));
    rectangle('Position', pos,'FaceColor',color);
    text(pos(1)+0.5,pos(2)+0.5,char(block(placement(i,1),1)));
end

status = 0;
warning('Placement successful!');
