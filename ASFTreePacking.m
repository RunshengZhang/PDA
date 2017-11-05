% ASF_tree packing
% Runsheng
% 20/27/2017


function [ placement_ASF, contour_ASF ] = ASFTreePacking(block, tree, S)

% Some parameter might be useful later on
[block_num , col] = size(block);
% self_sym_size = size(str2double(S.self),1)
pair_sym_size = size(str2double(S.pair),1);


tree_node_num = size(tree,1);

% The return result we want
contour_ASF = [];
placement_ASF = zeros(block_num,4);

% The root node where we start
% root_node = tree(1,:);

% a matrix recording the self-symmetry information
self_matrix = str2double(S.self);
pair_matrix = str2double(S.pair);

for i = 1:tree_node_num
  
    current_node = tree(i,:)
    if current_node(2)== 0 && current_node(3) == 0   % This is a root!
        
        node_index = current_node(1);   %index of this node which can be viewed as id
        
        if ismember(node_index, self_matrix)    % then current is a self-sym block
            placement_ASF(node_index,:) = [0,0,str2double(block(node_index,2))/2 ,str2double(block(node_index,3))];
            % we place the information of a block in the form as [x,y,width,height] at index at node_index
            contour_ASF = [contour_ASF ; 0 , str2double(block(node_index,2))/2 , str2double(block(node_index,3)) ];
        else
            placement_ASF(node_index,:) = [0, 0, str2double(block(node_index,2)),str2double(block(node_index,3))];
            % we place the information of a block in the form as [x,y,width,height] at index at node_index
            contour_ASF = [contour_ASF ; 0 , str2double(block(node_index,2)) , str2double(block(node_index,3)) ];
        
        end
        

    elseif current_node(2) ~= 0 && current_node(3) == 0   % which means it has a right parent, meaning it's someone's left child
        
        %keep in mind that, the left child will be placed on right
        
        node_index = current_node(1);
        parent = current_node(2);
        % parent_entry = zeros(1,4);
        parent_entry = placement_ASF(parent,:); % all information about the parent
        
        parent_x = parent_entry(1);
        parent_width = parent_entry(3);
        
        node_x = parent_x + parent_width;
        node_width = str2double(block(node_index,2));
        node_height = str2double(block(node_index,3));
        
        % Now determine the y place to put the cell
        [contour_entry, contour_col] = size(contour_ASF);
        
        y_max= 0;
        contour_ASF_temp_new = [];
        contour_ASF_manipulate = [];
        
        for i = 1 : contour_entry
            
            % contour_ASF
            
            if contour_ASF(i,2) <= node_x    % means, contour line is to left of the node
                contour_ASF_temp_new = [contour_ASF_temp_new ; contour_ASF(i,:)];    % drag the contour line out and put it in temp
                
            elseif contour_ASF(i,1) >= node_x + node_width    % contour line is to right of the node
                contour_ASF_temp_new = [contour_ASF_temp_new; contour_ASF(i,:)];
            else
                contour_ASF_manipulate = [contour_ASF_manipulate ; contour_ASF(i,:)];
                y_max = max(y_max, contour_ASF(i,3));    % At the end of the for loop, the y_max record the highest contour
            end
        end
        
        % All correlated contour segment should be extracted in contour_ASF_manipulate

        [len,width] = size(contour_ASF_manipulate);
        contour_ASF_post_manipulate = [];
        % what is contour_ASF_post_manipulate: if the current block has some x-overlap with some contour lines, contour_ASF_post_manipulate will not be empty
        % This matrix will save all "new" contour segment after contour calculation
        % So the case is, if the new block is placed on the right of all existing blocks, then there will be no overlapped contour

        if len ~= 0
            j = 1;
            
            if node_x ~= contour_ASF_manipulate(j,1)    % node_x starts after the left-most contour in contour_ASF_manipulate
                contour_ASF_post_manipulate = [contour_ASF_post_manipulate ; contour_ASF_manipulate(j,1),node_x,contour_ASF_manipulate(j,3) ];
            end

            while (node_x + node_width > contour_ASF_manipulate(j,2)) && (j < size(contour_ASF_manipulate,1) )    % jump to the last contour segment which has overlap with the right-end of current block
                j = j + 1;
            end

            if node_x + node_width < contour_ASF_manipulate(j,2)
                contour_ASF_post_manipulate = [contour_ASF_post_manipulate; node_x + node_width , contour_ASF_manipulate(j,2), contour_ASF_manipulate(j,3)];
            end

            % if node_x + node_width >= contour_ASF_manipulate(j,2)
            %     contour_ASF_post_manipulate = [contour_ASF_post_manipulate; node_x,node_x + node_width,]

            % end

            contour_ASF_post_manipulate = [contour_ASF_post_manipulate ; node_x,node_x + node_width, y_max + node_height];
        
        else

            contour_ASF_post_manipulate = [node_x ,node_x + node_width, node_height];

                        
        end

        contour_ASF_temp_new  = [contour_ASF_temp_new ; contour_ASF_post_manipulate];
        contour_ASF = sortrows(contour_ASF_temp_new,1) ;

        placement_ASF(node_index,:)  = [ node_x , y_max , node_width, node_height ];


 
    elseif current_node(2) == 0 && current_node(3) ~= 0        % this part take care of the right branch of the tree, which means, they need to be put on top of current parent.

        node_index = current_node(1);
        parent = current_node(3);
        % parent_entry = zeros(1,4);
        parent_entry = placement_ASF(parent,:); % all information about the parent
        
        parent_x = parent_entry(1);
        parent_y = parent_entry(2);
        parent_width = parent_entry(3);
        parent_height = parent_entry(4);

        node_x = parent_x;     % this node's x coordinate must be same as his parent
        node_width = str2double(block(node_index,2));
        if ismember(node_index,self_matrix)
            node_width = node_width / 2 ;
        end

        node_height = str2double(block(node_index,3));

        if node_width <= parent_width       % current node will not exceed the parent's width

            placement_ASF(node_index,:) = [node_x, parent_y + parent_height , node_width, node_height]; 

            parent_related_contour_index = find(contour_ASF(:,1) == node_x);

            if node_width == parent_width
                contour_ASF(parent_related_contour_index,3) = contour_ASF(parent_related_contour_index,3) + node_height;   
                % if node is same width as parent, just update the contour y coordinate, without any more changes


            else

                contour_ASF(parent_related_contour_index,:) = [node_x , node_x + node_width , parent_y + parent_height + node_height];
                contour_ASF = sortrows([contour_ASF; node_x + node_width, parent_x + parent_width, parent_y + parent_height ],1);
                % placement_ASF(node_index,:) = [node_x, parent_y + parent_height, node_width, node_height];


            end

        else            % current node is wider than parent, which means, need to have more than one contour segment get involved

            [contour_entry, contour_col] = size(contour_ASF);


        
            y_max= 0;
            contour_ASF_temp_new = [];
            contour_ASF_manipulate = [];

            for i = 1 : contour_entry

                if contour_ASF(i,2) <= node_x    % means, contour line is to left of the node
                    contour_ASF_temp_new = [contour_ASF_temp_new ; contour_ASF(i,:)];    % drag the contour line out and put it in temp
                
                elseif contour_ASF(i,1) >= node_x + node_width    % contour line is to right of the node
                    contour_ASF_temp_new = [contour_ASF_temp_new; contour_ASF(i,:)];
                else
                    contour_ASF_manipulate = [contour_ASF_manipulate ; contour_ASF(i,:)];
                    y_max = max(y_max, contour_ASF(i,3));    % At the end of the for loop, the y_max record the highest contour
                end

            end

            contour_ASF_post_manipulate = [];
            contour_ASF_manipulate;


            j = 1;

            
            if node_x ~= contour_ASF_manipulate(j,1)    % node_x starts after the left-most contour in contour_ASF_manipulate
                contour_ASF_post_manipulate = [contour_ASF_post_manipulate ; contour_ASF_manipulate(j,1),node_x,contour_ASF_manipulate(j,3) ];
            end

            while (node_x + node_width > contour_ASF_manipulate(j,2)) && (j < size(contour_ASF_manipulate,1) )     % jump to the last contour segment which has overlap with the right-end of current block
                j = j + 1
            end

            if node_x + node_width < contour_ASF_manipulate(j,2)
                contour_ASF_post_manipulate = [contour_ASF_post_manipulate; node_x + node_width , contour_ASF_manipulate(j,2), contour_ASF_manipulate(j,3)];
            end

            contour_ASF_post_manipulate = [contour_ASF_post_manipulate ; node_x, node_x + node_width, y_max + node_height];

            contour_ASF_temp_new  = [contour_ASF_temp_new ; contour_ASF_post_manipulate];
            contour_ASF = sortrows(contour_ASF_temp_new,1);


            placement_ASF(node_index,:) = [node_x, y_max , node_width, node_height];







        end



    else

        disp('Please check your ASF_tree, a node cannot have more than one parent')
 
    end

    disp('this round, we place node')
    node_index
    disp('placement')
    placement_ASF
    % disp('contour looks like')
    % sortrows(contour_ASF,1)
    
    
    
    
end
    

% Now flip expand the placement coordinate and contour coordinate

max_x_coord = max(contour_ASF(:,2));

for i = 1 : pair_sym_size

    undecided_index = pair_matrix(i,1);
    mirrored_index = pair_matrix(i,2);

    placement_ASF(undecided_index,:) = [ -(placement_ASF(mirrored_index,1) + placement_ASF(mirrored_index,3)) + max_x_coord, placement_ASF(mirrored_index,2), placement_ASF(mirrored_index,3),placement_ASF(mirrored_index,4)];
    placement_ASF(mirrored_index,1) = max_x_coord + placement_ASF(mirrored_index,1);


end

contour_ASF_update = [];

for i = 1 : size(contour_ASF,1)

    contour_ASF_update = [contour_ASF_update; max_x_coord-contour_ASF(i,2),  max_x_coord-contour_ASF(i,1),  contour_ASF(i,3)];
    contour_ASF_update = [contour_ASF_update; max_x_coord + contour_ASF(i,1), max_x_coord + contour_ASF(i,2),  contour_ASF(i,3)];




end



placement_ASF
contour_ASF = sortrows(contour_ASF_update,1)
