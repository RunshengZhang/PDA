% This function iiss used to plot the packing result 

function plotpacking( h_placement )

    for i = 1:size(h_placement,1)
        label{i} = sprintf('%d', i);
        rectangle('Position', h_placement(i,:),'Facecolor',[0,1,0]);
        if(h_placement(i,3)~=0)
            text(h_placement(i,1)+(h_placement(i,3)/2) , h_placement(i,2) + (h_placement(i,4)/2) , label{i} );
        end
    end
