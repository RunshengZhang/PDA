% ASF_tree packing
% Runsheng
% 20/27/2017

function [ asf_placement, asf_contour_top, asf_contour_bottom ] = asf_packing(tree, block, S)

% Some parameter might be useful later on
[block_num , ~] = size(block);
self_sym_size = length(S.self);
[pair_sym_size,~] = size(S.pair);


% extract NP
NP = size(tree,3);


tree_node_num = size(tree,1);





for np_index = 1: NP


    % ********************************1. Initialization*********************************



    % The return result we want
    contour_asf_top_eachNP = [];
    placement_asf_eachNP = zeros(block_num,4);

    contour_asf_bottom_eachNP = [];
    % The root node where we start
    % root_node = tree(1,:);

    % a matrix recording the self-symmetry information
    self_array = S.self;
    pair_matrix = S.pair;








    for i = 1:tree_node_num
    
        current_node = tree(i,:)

        % **************************** &&&&&&&&  2. First round, build placement and contour &&&&&&&&&&&&&& ***********************

        % ********************************** 2.1 First Condition: root node **********************************

        if current_node(2)== 0 && current_node(3) == 0   % This is a root!
            
            node_index = current_node(1);   %index of this node which can be viewed as id
            
            if ismember(node_index, self_array)    % then current is a self-sym block
                placement_asf_eachNP(node_index,:) = [0,0,str2double(block(node_index,2))/2 ,str2double(block(node_index,3))];
                % we place the information of a block in the form as [x,y,width,height] at index at node_index
                contour_asf_top_eachNP = [contour_asf_top_eachNP ; 0 , str2double(block(node_index,2))/2 , str2double(block(node_index,3)) ];
                contour_asf_bottom_eachNP = [contour_asf_bottom_eachNP ; 0 , str2double(block(node_index,2))/2 , 0 ];
            else
                placement_asf_eachNP(node_index,:) = [0, 0, str2double(block(node_index,2)),str2double(block(node_index,3))];
                % we place the information of a block in the form as [x,y,width,height] at index at node_index
                contour_asf_top_eachNP = [contour_asf_top_eachNP ; 0 , str2double(block(node_index,2)) , str2double(block(node_index,3))];
                contour_asf_bottom_eachNP = [contour_asf_bottom_eachNP ; 0 , str2double(block(node_index,2)) , 0 ];
            
            end
            

        % ********************************** 2.2 Second Condition: left children ******************************
        
        elseif current_node(2) ~= 0 && current_node(3) == 0   % which means it has a right parent, meaning it's someone's left child
            
            % keep in mind that, the left child will be placed on right
            
            node_index = current_node(1);
            parent = current_node(2);
            % parent_entry = zeros(1,4);
            parent_entry = placement_asf_eachNP(parent,:); % all information about the parent
            
            parent_x = parent_entry(1);
            parent_width = parent_entry(3);
            
            node_x = parent_x + parent_width;
            node_width = str2double(block(node_index,2));
            node_height = str2double(block(node_index,3));
            
            % Now determine the y place to put the cell
            [contour_entry, ~] = size(contour_asf_top_eachNP);
            
            y_max= 0;
            contour_asf_top_eachNP_temp_new = [];
            contour_asf_top_eachNP_manipulate = [];
            
            for i = 1 : contour_entry
                
                % contour_asf_top_eachNP
                
                if contour_asf_top_eachNP(i,2) <= node_x    % means, contour line is to left of the node
                    contour_asf_top_eachNP_temp_new = [contour_asf_top_eachNP_temp_new ; contour_asf_top_eachNP(i,:)];    % drag the contour line out and put it in temp
                    
                elseif contour_asf_top_eachNP(i,1) >= node_x + node_width    % contour line is to right of the node
                    contour_asf_top_eachNP_temp_new = [contour_asf_top_eachNP_temp_new; contour_asf_top_eachNP(i,:)];
                else
                    contour_asf_top_eachNP_manipulate = [contour_asf_top_eachNP_manipulate ; contour_asf_top_eachNP(i,:)];
                    y_max = max(y_max, contour_asf_top_eachNP(i,3));    % At the end of the for loop, the y_max record the highest contour
                end
            end
            
            % All correlated contour segment should be extracted in contour_asf_top_eachNP_manipulate

            [len,~] = size(contour_asf_top_eachNP_manipulate);
            contour_asf_top_eachNP_post_manipulate = [];
            % what is contour_asf_top_eachNP_post_manipulate: if the current block has some x-overlap with some contour lines, contour_asf_top_eachNP_post_manipulate will not be empty
            % This matrix will save all "new" contour segment after contour calculation
            % So the case is, if the new block is placed on the right of all existing blocks, then there will be no overlapped contour

            if len ~= 0
                j = 1;
                
                if node_x ~= contour_asf_top_eachNP_manipulate(j,1)    % node_x starts after the left-most contour in contour_asf_top_eachNP_manipulate
                    contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate ; contour_asf_top_eachNP_manipulate(j,1),node_x,contour_asf_top_eachNP_manipulate(j,3) ];
                end

                while (node_x + node_width > contour_asf_top_eachNP_manipulate(j,2)) && (j < size(contour_asf_top_eachNP_manipulate,1) )    % jump to the last contour segment which has overlap with the right-end of current block
                    j = j + 1;
                end

                if node_x + node_width < contour_asf_top_eachNP_manipulate(j,2)
                    contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate; node_x + node_width , contour_asf_top_eachNP_manipulate(j,2), contour_asf_top_eachNP_manipulate(j,3)];
                end

                % if node_x + node_width >= contour_asf_top_eachNP_manipulate(j,2)
                %     contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate; node_x,node_x + node_width,]

                % end

                contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate ; node_x,node_x + node_width, y_max + node_height];

                if node_x + node_width > contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2)

                    contour_asf_bottom_eachNP = [contour_asf_bottom_eachNP; contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2) , node_x + node_width,  y_max];

                                        
                end
            
            else     % the new block just put on right to the whole existing blocks and y is 0

                contour_asf_top_eachNP_post_manipulate = [node_x ,node_x + node_width, node_height];

                if contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2) == 0      % right-most existing contour y is 0  
                    contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2) = node_x + node_width;
                else
                    contour_asf_bottom_eachNP = [contour_asf_bottom_eachNP; node_x, node_x + node_width , 0 ];
                end
                 

                            
            end

            contour_asf_top_eachNP_temp_new  = [contour_asf_top_eachNP_temp_new ; contour_asf_top_eachNP_post_manipulate];
            contour_asf_top_eachNP = sortrows(contour_asf_top_eachNP_temp_new,1) ;

            placement_asf_eachNP(node_index,:)  = [ node_x , y_max , node_width, node_height ];


    
        


        %   *********************************2.3 Third Condition: right children ******************************
        
        elseif current_node(2) == 0 && current_node(3) ~= 0        % this part take care of the right branch of the tree, which means, they need to be put on top of current parent.

            node_index = current_node(1);
            parent = current_node(3);
            % parent_entry = zeros(1,4);
            parent_entry = placement_asf_eachNP(parent,:); % all information about the parent
            
            parent_x = parent_entry(1);
            parent_y = parent_entry(2);
            parent_width = parent_entry(3);
            parent_height = parent_entry(4);

            node_x = parent_x;     % this node's x coordinate must be same as his parent
            node_width = str2double(block(node_index,2));
            if ismember(node_index,self_array)
                node_width = node_width / 2 ;
            end

            node_height = str2double(block(node_index,3));

            if node_width <= parent_width       % current node will not exceed the parent's width

                placement_asf_eachNP(node_index,:) = [node_x, parent_y + parent_height , node_width, node_height]; 

                parent_related_contour_index = find(contour_asf_top_eachNP(:,1) == node_x);

                if node_width == parent_width
                    contour_asf_top_eachNP(parent_related_contour_index,3) = contour_asf_top_eachNP(parent_related_contour_index,3) + node_height;   
                    % if node is same width as parent, just update the contour y coordinate, without any more changes


                else

                    contour_asf_top_eachNP(parent_related_contour_index,:) = [node_x , node_x + node_width , parent_y + parent_height + node_height];
                    contour_asf_top_eachNP = sortrows([contour_asf_top_eachNP; node_x + node_width, parent_x + parent_width, parent_y + parent_height ],1);
                    % placement_asf_eachNP(node_index,:) = [node_x, parent_y + parent_height, node_width, node_height];


                end

            else            % current node is wider than parent, which means, need to have more than one contour segment get involved

                [contour_entry, ~] = size(contour_asf_top_eachNP);


            
                y_max= 0;
                contour_asf_top_eachNP_temp_new = [];
                contour_asf_top_eachNP_manipulate = [];

                for i = 1 : contour_entry

                    if contour_asf_top_eachNP(i,2) <= node_x    % means, contour line is to left of the node
                        contour_asf_top_eachNP_temp_new = [contour_asf_top_eachNP_temp_new ; contour_asf_top_eachNP(i,:)];    % drag the contour line out and put it in temp
                    
                    elseif contour_asf_top_eachNP(i,1) >= node_x + node_width    % contour line is to right of the node
                        contour_asf_top_eachNP_temp_new = [contour_asf_top_eachNP_temp_new; contour_asf_top_eachNP(i,:)];
                    else
                        contour_asf_top_eachNP_manipulate = [contour_asf_top_eachNP_manipulate ; contour_asf_top_eachNP(i,:)];
                        y_max = max(y_max, contour_asf_top_eachNP(i,3));    % At the end of the for loop, the y_max record the highest contour
                    end

                end

                contour_asf_top_eachNP_post_manipulate = [];
                contour_asf_top_eachNP_manipulate;


                j = 1;

                
                if node_x ~= contour_asf_top_eachNP_manipulate(j,1)    % node_x starts after the left-most contour in contour_asf_top_eachNP_manipulate
                    contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate ; contour_asf_top_eachNP_manipulate(j,1),node_x,contour_asf_top_eachNP_manipulate(j,3) ];
                end

                while (node_x + node_width > contour_asf_top_eachNP_manipulate(j,2)) && (j < size(contour_asf_top_eachNP_manipulate,1) )     % jump to the last contour segment which has overlap with the right-end of current block
                    j = j + 1;
                end

                if node_x + node_width < contour_asf_top_eachNP_manipulate(j,2)         % if break condition is the former
                    contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate; node_x + node_width , contour_asf_top_eachNP_manipulate(j,2), contour_asf_top_eachNP_manipulate(j,3)];
                end

                contour_asf_top_eachNP_post_manipulate = [contour_asf_top_eachNP_post_manipulate ; node_x, node_x + node_width, y_max + node_height];

                contour_asf_top_eachNP_temp_new  = [contour_asf_top_eachNP_temp_new ; contour_asf_top_eachNP_post_manipulate];
                contour_asf_top_eachNP = sortrows(contour_asf_top_eachNP_temp_new,1);



                if node_x + node_width > contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2)
                    
                    contour_asf_bottom_eachNP = [contour_asf_bottom_eachNP; contour_asf_bottom_eachNP(size(contour_asf_bottom_eachNP,1),2) , node_x + node_width , y_max];

                end


                placement_asf_eachNP(node_index,:) = [node_x, y_max , node_width, node_height];







            end



        else

            disp('Please check your ASF_tree, a node cannot have more than one parent')
    
        end


         


        % disp('this round, we place node');
        node_index;
        % disp('placement')
        placement_asf_eachNP;
        % disp('contour looks like')
        sortrows(contour_asf_top_eachNP,1);
        sortrows(contour_asf_bottom_eachNP,1);
        
        
        
        
    end
    



    % ***************************&&&&&& 3.Flip the placemnt and contour &&&&&&&&&&*****************************

    % Now flip expand the placement coordinate and contour coordinate

    max_x_coord = max(contour_asf_top_eachNP(:,2));

    for i = 1 : pair_sym_size

        undecided_index = pair_matrix(i,1);
        mirrored_index = pair_matrix(i,2);

        placement_asf_eachNP(undecided_index,:) = [ -(placement_asf_eachNP(mirrored_index,1) + placement_asf_eachNP(mirrored_index,3)) + max_x_coord, placement_asf_eachNP(mirrored_index,2), placement_asf_eachNP(mirrored_index,3),placement_asf_eachNP(mirrored_index,4)];
        placement_asf_eachNP(mirrored_index,1) = max_x_coord + placement_asf_eachNP(mirrored_index,1);


    end

    if self_sym_size > 0

        for i = 1 : self_sym_size

            self_node_index = self_array(i);

            placement_asf_eachNP(self_node_index,:) = [-( placement_asf_eachNP(self_node_index,3) ) + max_x_coord , placement_asf_eachNP(self_node_index,2) , 2 * placement_asf_eachNP(self_node_index,3) , placement_asf_eachNP(self_node_index,4) ];

        end

    end

    contour_asf_top_eachNP_update = [];
    contour_asf_bottom_eachNP_update = [];


    for i = 1 : size(contour_asf_top_eachNP,1)

        contour_asf_top_eachNP_update = [contour_asf_top_eachNP_update; max_x_coord-contour_asf_top_eachNP(i,2),  max_x_coord-contour_asf_top_eachNP(i,1),  contour_asf_top_eachNP(i,3)];
        contour_asf_top_eachNP_update = [contour_asf_top_eachNP_update; max_x_coord + contour_asf_top_eachNP(i,1), max_x_coord + contour_asf_top_eachNP(i,2),  contour_asf_top_eachNP(i,3)];

    end

    for i = 1:size(contour_asf_bottom_eachNP,1)

        contour_asf_bottom_eachNP_update = [contour_asf_bottom_eachNP_update; max_x_coord - contour_asf_bottom_eachNP(i,2), max_x_coord - contour_asf_bottom_eachNP(i,1) , contour_asf_bottom_eachNP(i,3)];
        contour_asf_bottom_eachNP_update = [contour_asf_bottom_eachNP_update; max_x_coord + contour_asf_bottom_eachNP(i,1), max_x_coord + contour_asf_bottom_eachNP(i,2),  contour_asf_bottom_eachNP(i,3)];
    
    end

    


    contour_asf_top_eachNP = sortrows(contour_asf_top_eachNP_update,1);
    contour_asf_bottom_eachNP = sortrows(contour_asf_bottom_eachNP_update,1);
    placement_asf_eachNP;






    % ***************************&&&&&&&&&&&& 4. Merge same height contour segment &&&&&*********************

    % merge adjacent contour segment which has same height

    contour_asf_top_eachNP_update = [];

    i = 1;
    while(i <= size(contour_asf_top_eachNP,1))


        if i<size(contour_asf_top_eachNP,1) && contour_asf_top_eachNP(i,3) == contour_asf_top_eachNP(i+1,3)
            start_x = contour_asf_top_eachNP(i,1);
            % y_merge = contour_asf_top_eachNP(i,3)

            while(i<size(contour_asf_top_eachNP,1) && contour_asf_top_eachNP(i,3) == contour_asf_top_eachNP(i+1,3) )
                i = i + 1;
            end

            end_x = contour_asf_top_eachNP(i,2);

            contour_asf_top_eachNP_update = [contour_asf_top_eachNP_update; start_x , end_x , contour_asf_top_eachNP(i,3) ];
            
        else 
            contour_asf_top_eachNP_update = [contour_asf_top_eachNP_update ; contour_asf_top_eachNP(i,:)];
        end
        i = i + 1;
    end





    contour_asf_bottom_eachNP_update = [];

    i = 1;
    while(i <= size(contour_asf_bottom_eachNP,1))


        if i<size(contour_asf_bottom_eachNP,1) && contour_asf_bottom_eachNP(i,3) == contour_asf_bottom_eachNP(i+1,3)
            start_x = contour_asf_bottom_eachNP(i,1);

            while(i<size(contour_asf_bottom_eachNP,1) && contour_asf_bottom_eachNP(i,3) == contour_asf_bottom_eachNP(i+1,3) )
                i = i + 1;
            end

            end_x = contour_asf_bottom_eachNP(i,2);

            contour_asf_bottom_eachNP_update = [contour_asf_bottom_eachNP_update; start_x , end_x , contour_asf_bottom_eachNP(i,3) ];
            
        else 
            contour_asf_bottom_eachNP_update = [contour_asf_bottom_eachNP_update ; contour_asf_bottom_eachNP(i,:)];
        end
        i = i + 1;
    end


    contour_asf_top_eachNP = sortrows(contour_asf_top_eachNP_update,1);
    contour_asf_bottom_eachNP = sortrows(contour_asf_bottom_eachNP_update,1);
    placement_asf_eachNP;

    

    asf_contour_top(:,:,np_index) = contour_asf_top_eachNP;
    asf_contour_bottom(:,:,np_index) = contour_asf_bottom_eachNP;
    asf_placement(:,:,np_index) = placement_asf_eachNP;


end