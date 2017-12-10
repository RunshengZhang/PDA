% h_tree packing
% Runsheng
% 11/15/2017

% This function will take h_tree and based on asf_placement and contour, try to pack the whole h tree

function [h_placement] = h_packing( h_tree, asf_placement, asf_contour_top, asf_contour_bottom, block )

    tic;
    
    % 1. Global Initialization

    numberOfBlock = size(block,1);
    NP = size(fieldnames(asf_contour_top),1);
    h_placement = struct();
    
    % Start the iteration of NP
    
    for n = 1:NP
        
        NPname{n} = sprintf('NP%d', n);


        % Local Initilzation
        h_tree_curNP = h_tree.(NPname{n});           % &&&&&&&&&&&&&&&&  might be changed! &&&&&&&&&&&&&&&&&
        asf_placement_curNP = asf_placement.(NPname{n});
        asf_contour_top_curNP = asf_contour_top.(NPname{n});
        asf_contour_bottom_curNP = asf_contour_bottom.(NPname{n});

        asf_placement_curNP_sft = [];           % shifted asf_placement, getting assignment when figuring out where the hierachy node locate
        asf_contour_bottom_curNP_sft = [];      % Shifted contour, getting assignment when we figuring out where the hierachy node locate
        asf_contour_top_curNP_sft = [];         
        
        contour_h_curNP = [];
        placement_h_curNP = [];
        
        NumberOfNodeInHTree = size(h_tree_curNP,1);

        % Start going through the h_tree

        for i = 1:NumberOfNodeInHTree
            
            % Three condition: Root or left child or right child

            h_tree_entry = h_tree_curNP(i,:);
            node_index = h_tree_entry(1);

            % First : it's a root
            if h_tree_entry(2)==0 && h_tree_entry(3) == 0

                % Two possibilities here: if it's a hierachy node or just a simple one
                
                if node_index > numberOfBlock      % it's hierachy node!
                    
                    placement_h_curNP = asf_placement_curNP;    % copy the placement of ASF
                    contour_h_curNP = asf_contour_top_curNP;    % copy the up contour of ASF
                    % Assigning the shifted coord for asf node
                    asf_placement_curNP_sft = asf_placement_curNP;
                    asf_contour_bottom_curNP_sft = asf_contour_bottom_curNP;
                    asf_contour_top_curNP_sft = asf_contour_top_curNP;
                    

                else

                    if h_tree_entry(4) == 0
                        block_entry = str2double(block(node_index,2:3));
                    else
                        block_entry = [str2double(block(node_index,3)),str2double(block(node_index,2))];
                    end

                    placement_h_curNP(node_index,:) = [0,0,block_entry];

                    contour_h_curNP = [0,block_entry];
   
                end 
                



                % Second: left child
            elseif h_tree_entry(2)~=0 && h_tree_entry(3) == 0

                parent_index = h_tree_entry(2);

                % Three Possibilities: regular node right to regular/hierachy node, hierachy node right to regular node, contour right to contour
                                
                if node_index <= numberOfBlock && node_index > 0     % Regular node to regular/hierachy node            
                    
                    block_entry = str2double(block(node_index,2:3));
                    if h_tree_entry(4) == 1
                        block_entry([1 2]) = block_entry([2 1]);
                    end
                    node_width = block_entry(1);
                    node_height = block_entry(2);
                    

                    if parent_index > numberOfBlock         % regular node right to hierachy node 
                        % since hierachy node's coord info is different style, using contour to capture the right most convex point is the same
                        node_x = asf_contour_top_curNP_sft(size(asf_contour_top_curNP_sft,1),2);
                    else
                        node_x = placement_h_curNP(parent_index,1) + placement_h_curNP(parent_index,3);
                    end

                    % contour_related is the matrix which is a subset containing all contour which has overlap with the current node
                    contour_related_index = intersect( find(contour_h_curNP(:,1) < node_x + node_width) , find(contour_h_curNP(:,2) > node_x)  );
                    
                    % find the max y_coord among the overlapped contours
                    if size(contour_related_index,1) > 0
                        contour_related = contour_h_curNP(min(contour_related_index):max(contour_related_index),:);
                        y_max = max(contour_related(:,3));
                    else
                        y_max = 0;
                    end
                        
                    % add it in the placement
                    placement_h_curNP(node_index,:) = [node_x, y_max, node_width, node_height];


                        % save a copy of contour to backup
                        % contour_h_curNP_bkp = contour_h_curNP;

                    % the following divide the problem in two situations:
                    % 1. the new block has no relationship with any existing contour
                    if size(contour_related_index,1) == 0
                        contour_h_curNP = [contour_h_curNP ; node_x, node_width + node_x,  y_max + node_height ];
                        
                        % 2. the new block has overlap with existing contour, so the contour_related_index is not empty
                    else
                        
                        % if the starting point of first contour seg is not same as the node_x
                        if contour_related(1,1) < node_x
                            contour_h_curNP = [contour_h_curNP ; contour_related(1,1), node_x, contour_related(1,3)  ];                                                     
                        end

                        % if the ending point of new block is not as far as the last contour seg right boundary
                        if contour_related(size(contour_related,1),2) > node_x + node_width
                            contour_h_curNP = [contour_h_curNP; node_x + node_width , contour_related(size(contour_related,1),2) , contour_related(size(contour_related,1),3)];
                        end

                        contour_h_curNP  = [contour_h_curNP; node_x , node_x + node_width, y_max + node_height ];

                        contour_h_curNP(min(contour_related_index):max(contour_related_index),:) = [];


                    end

                    contour_h_curNP = sortrows(contour_h_curNP,1);







                    







                
                




                elseif node_index > numberOfBlock                   % Out-of-boundary node, which is the hierachy node

                    node_x = placement_h_curNP(parent_index,1) + placement_h_curNP(parent_index,3);
                    node_width = max(asf_contour_top_curNP(:,2));
                    node_height = max(asf_contour_top_curNP(:,3));


                    % shift the bottom contour to correct placement
                    asf_contour_bottom_curNP_sft = asf_contour_bottom_curNP;
                    % asf_contour_bottom_curNP_sft(:,1) = asf_contour_bottom_curNP_sft(:,1) + node_x * ones(size(asf_contour_bottom_curNP_sft,1),1);
                    % asf_contour_bottom_curNP_sft(:,2) = asf_contour_bottom_curNP_sft(:,2) + node_x * ones(size(asf_contour_bottom_curNP_sft,1),1);
                    asf_contour_bottom_curNP_sft(:,1) = asf_contour_bottom_curNP_sft(:,1) + node_x;
                    asf_contour_bottom_curNP_sft(:,2) = asf_contour_bottom_curNP_sft(:,2) + node_x;


                    % shift the top contour to correct placement
                    asf_contour_top_curNP_sft = asf_contour_top_curNP;
                    % asf_contour_top_curNP_sft(:,1) = asf_contour_top_curNP_sft(:,1) + node_x * ones(size(asf_contour_top_curNP_sft,1),1);
                    % asf_contour_top_curNP_sft(:,2) = asf_contour_top_curNP_sft(:,2) + node_x * ones(size(asf_contour_top_curNP_sft,1),1);
                    asf_contour_top_curNP_sft(:,1) = asf_contour_top_curNP_sft(:,1) + node_x;
                    asf_contour_top_curNP_sft(:,2) = asf_contour_top_curNP_sft(:,2) + node_x;


                    y_feasible_coord = 0;
                    
                    % &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& A question here, can the hierarchy node be placed at some loc where y_min is smaller than 0?

                    for j = 1:size(asf_contour_bottom_curNP_sft,1)
                        
                        %contour_related_index = intersect( find(contour_h_curNP(:,1) < node_x + node_width) , find(contour_h_curNP(:,2) > node_x)  );
                        bottom_entry = asf_contour_bottom_curNP_sft(j,:);
                        cur_bottom_enry_overlap_index = intersect( find(  contour_h_curNP(:,2) > bottom_entry(1)  ) , find( contour_h_curNP(:,1) < bottom_entry(2) )  );
                        
                        
                        if size(cur_bottom_enry_overlap_index,1) == 0
                            y_feasible_coord = max(y_feasible_coord,0);
                        else
                            cur_bottom_enry_overlap = contour_h_curNP(min(cur_bottom_enry_overlap_index):max(cur_bottom_enry_overlap_index),:);
                            y_feasible_coord_try = max(cur_bottom_enry_overlap(:,3)) - bottom_entry(3);
                            if y_feasible_coord_try > 0 && y_feasible_coord_try > y_feasible_coord
                                y_feasible_coord = y_feasible_coord_try;
                            end

                        end

                    end

                    % finally dude, we find the feasible coord for the hierarchy node
                    asf_contour_top_curNP_sft(:,3) = asf_contour_top_curNP_sft(:,3) + y_feasible_coord;
                    asf_contour_bottom_curNP_sft(:,3) = asf_contour_bottom_curNP_sft(:,3) + y_feasible_coord;


                    % The plcement of the hierachy node in HB* tree!

                    for j = 1:size(asf_placement_curNP,1)
                        
                        if asf_placement_curNP(j,3) ~= 0    % Notice that if the width is not 0, this means, the node is in hierachy node
                            
                            placement_h_curNP(j,:) = [ node_x + asf_placement_curNP(j,1) , y_feasible_coord + asf_placement_curNP(j,2) , asf_placement_curNP(j,3:4) ];
                            
                        end
                        
                    end


                    % The contour construction of the HB* tree

                    % find all h contour segment which has overlap with ASF's top contour
                    overlappedWithTopOfASF_h_contour_index = intersect( find(  contour_h_curNP(:,1) < asf_contour_top_curNP_sft( size(asf_contour_top_curNP_sft,1),2)  ) , find(contour_h_curNP(:,2) > asf_contour_top_curNP_sft(1,1))  );

                    if size(overlappedWithTopOfASF_h_contour_index,1) == 0       % Nothing overlap with this hierachy node, so just place the contour directly
                        contour_h_curNP = [contour_h_curNP ; asf_contour_top_curNP_sft];
                    else        % some contour has overlapped with hierachy node, so we need to deal with them, they are overlappedWithTopOfASF_h_contour_index
 

                        if contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),1) < asf_contour_top_curNP_sft(1,1)

                        contour_h_curNP = [contour_h_curNP; contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),1) , asf_contour_top_curNP_sft(1,1) , contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),3)];


                        end

                        if contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),2) >  asf_contour_top_curNP_sft( size(asf_contour_top_curNP_sft,1),2 )
                            contour_h_curNP = [contour_h_curNP ; asf_contour_top_curNP_sft(size(asf_contour_top_curNP_sft,1),2) , contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),2) , contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),3) ];

                        end
                        
                        contour_h_curNP = [contour_h_curNP; asf_contour_top_curNP_sft];

                        % finally, clear those overlappped lines in h_contour, since we will take care of them later
                        contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index):max(overlappedWithTopOfASF_h_contour_index),: ) = [];

                    end

                    contour_h_curNP = sortrows(contour_h_curNP,1);


                elseif node_index < 0 && h_tree_entry(2) < 0                                                % contour node right to contour node
                    continue    % if it's a contour and contour relationship, then, just skip it
                else                                                % Error control
                    disp('Some other condition happens in your left child!');
                    break
                end 
                     
                % Third: right child
            elseif h_tree_entry(2)==0 && h_tree_entry(3) ~= 0 
                 
                 parent_index = h_tree_entry(3);

                 % Possibilities: regular node is on top of regular node;  hierachy node is on the top of regular node ; regular node is on top of some contour node ; contour on top of hierachy node
                 
                if node_index <= numberOfBlock && node_index > 0 && h_tree_entry(3) > 0          % Regular node on top of regular node
                    
                    block_entry = str2double(block(node_index,2:3));

                    if h_tree_entry(4) == 1
                        block_entry([1 2]) = block_entry([2 1]);
                    end
                    node_width = block_entry(1);
                    node_height = block_entry(2);
                    
                    node_x = placement_h_curNP(parent_index , 1);

                    % contour_related is the array which is a subset containing all contour which has overlap with the current node
                    contour_related_index = intersect( find(contour_h_curNP(:,1) < node_x + node_width) , find(contour_h_curNP(:,2) > node_x)  );
                    
                    % contour_related_index could never be empty. At least there is his parent.
                    contour_related = contour_h_curNP(min(contour_related_index):max(contour_related_index),:);
                    y_max = max(contour_related(:,3));
                       
                    % add it in the placement
                    placement_h_curNP(node_index,:) = [node_x, y_max, node_width, node_height];

                    if node_x > contour_related(1,1)
                        contour_h_curNP = [contour_h_curNP ; contour_related(1,1) , node_x , contour_related(1,1)];
                    end

                    if node_x + node_width < contour_related(size(contour_related,1),2)
                        contour_h_curNP = [contour_h_curNP; node_x + node_width , contour_related(size(contour_related,1),2), contour_related(size(contour_related,1),3) ];
                    end

                    contour_h_curNP = [contour_h_curNP; node_x, node_x + node_width ,  y_max + node_height];

                    contour_h_curNP( min(contour_related_index):max(contour_related_index), : ) = [];

                    contour_h_curNP = sortrows(contour_h_curNP,1);




                    






                elseif node_index > numberOfBlock                                               % Hierachy node on top of regular node
                    
                    % Determine the starting x coordinate
                    node_x = placement_h_curNP(parent_index,1);

                    % shift the contour
                    asf_contour_bottom_curNP_sft = asf_contour_bottom_curNP;
                    asf_contour_bottom_curNP_sft(:,1) = node_x + asf_contour_bottom_curNP_sft(:,1);
                    asf_contour_bottom_curNP_sft(:,2) = node_x + asf_contour_bottom_curNP_sft(:,2);

                    asf_contour_top_curNP_sft = asf_contour_top_curNP;
                    asf_contour_top_curNP_sft(:,1) = node_x + asf_contour_top_curNP_sft(:,1);
                    asf_contour_top_curNP_sft(:,2) = node_x + asf_contour_top_curNP_sft(:,2);

                    y_feasible_coord = 0;

                    for j = 1 : size(asf_contour_bottom_curNP_sft)

                        bottom_entry = asf_contour_bottom_curNP_sft(j,:);
                        cur_bottom_enry_overlap_index = intersect(  find(contour_h_curNP(:,1) < bottom_entry(2)) , find(contour_h_curNP(:,2) > bottom_entry(1)) );

                        if size(cur_bottom_enry_overlap_index,1) == 0
                            y_feasible_coord = max(y_feasible_coord,0);
                        else
                            cur_bottom_enry_overlap = contour_h_curNP(min(cur_bottom_enry_overlap_index):max(cur_bottom_enry_overlap_index),:);
                            y_feasible_coord_try = max(cur_bottom_enry_overlap(:,3)) - bottom_entry(3);
                            if y_feasible_coord_try > 0 && y_feasible_coord_try > y_feasible_coord
                                y_feasible_coord = y_feasible_coord_try;
                            end

                        end
                    end

                    % Now we have the feasible y coordinate

                    asf_contour_bottom_curNP_sft(:,3) = y_feasible_coord +  asf_contour_bottom_curNP_sft(:,3);
                    asf_contour_top_curNP_sft(:,3) = y_feasible_coord + asf_contour_top_curNP_sft(:,3);

                    for j = 1 : size(asf_placement_curNP)

                        if asf_placement_curNP(j,3) ~= 0

                            placement_h_curNP(j,:) = [node_x + asf_placement_curNP(j,1), y_feasible_coord + asf_placement_curNP(j,2) , asf_placement_curNP(j,3:4)];
                        end

                    end

                    % After placing the asf node, we need to update the contour

                    % find all h contour segment which has overlap with ASF's top contour
                    overlappedWithTopOfASF_h_contour_index = intersect( find(  contour_h_curNP(:,1) < asf_contour_top_curNP_sft( size(asf_contour_top_curNP_sft,1),2)  ) , find(contour_h_curNP(:,2) > asf_contour_top_curNP_sft(1,1))  );

                    if size(overlappedWithTopOfASF_h_contour_index,1) == 0       % Nothing overlap with this hierachy node, so just place the contour directly
                        contour_h_curNP = [contour_h_curNP ; asf_contour_top_curNP_sft];
                    else        % some contour has overlapped with hierachy node, so we need to deal with them, they are overlappedWithTopOfASF_h_contour_index
 

                        if contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),1) < asf_contour_top_curNP_sft(1,1)

                        contour_h_curNP = [contour_h_curNP; contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),1) , asf_contour_top_curNP_sft(1,1) , contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index),3)];


                        end

                        if contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),2) >  asf_contour_top_curNP_sft( size(asf_contour_top_curNP_sft,1),2 )
                            contour_h_curNP = [contour_h_curNP ; asf_contour_top_curNP_sft(size(asf_contour_top_curNP_sft,1),2) , contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),2) , contour_h_curNP( max(overlappedWithTopOfASF_h_contour_index),3) ];

                        end
                        
                        contour_h_curNP = [contour_h_curNP; asf_contour_top_curNP_sft];

                        % finally, clear those overlappped lines in h_contour, since we will take care of them later
                        contour_h_curNP(min(overlappedWithTopOfASF_h_contour_index):max(overlappedWithTopOfASF_h_contour_index),: ) = [];

                    end

                    contour_h_curNP = sortrows(contour_h_curNP,1);






                elseif node_index <= numberOfBlock && node_index > 0 && h_tree_entry(3) < 0     % regular node on top of some hierachy contour    
                    
                    block_entry = str2double(block(node_index,2:3));
                    if h_tree_entry(4) == 1
                        block_entry([1 2]) = block_entry([2 1]);
                    end
                    node_width = block_entry(1);
                    node_height = block_entry(2);

                    contour_index = h_tree_entry(3);
                    node_x = asf_contour_top_curNP_sft(-contour_index, 1);

                    contour_related_index = intersect( find(contour_h_curNP(:,1) < node_x + node_width) , find(contour_h_curNP(:,2) > node_x)  );
                    % contour_related_index could never be empty. At least there is his parent.
                    contour_related = contour_h_curNP(min(contour_related_index):max(contour_related_index),:);
                    y_max = max(contour_related(:,3));

                    % Place the new block
                    placement_h_curNP(node_index,:) = [node_x, y_max, node_width,node_height];

                    % Update the contour
                    if node_x > contour_related(1,1)
                        contour_h_curNP = [contour_h_curNP ; contour_related(1,1) , node_x , contour_related(1,1)];
                    end

                    if node_x + node_width < contour_related(size(contour_related,1),2)
                        contour_h_curNP = [contour_h_curNP; node_x + node_width , contour_related(size(contour_related,1),2), contour_related(size(contour_related,1),3) ];
                    end

                    contour_h_curNP = [contour_h_curNP; node_x, node_x + node_width ,  y_max + node_height];

                    contour_h_curNP( min(contour_related_index):max(contour_related_index), : ) = [];

                    contour_h_curNP = sortrows(contour_h_curNP,1);


                elseif node_index < 0 && h_tree_entry(3) > numberOfBlock                        % contour node on top of hierachy node
                    continue
                else                                                                            % Error control
                    disp('Something is wrong with your right children');
                    break;
                end


            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot_Debug_hpacking&&&&&&&&&&&&&
            %plotpacking(placement_h_curNP)

        end

        h_placement.(NPname{n}) = placement_h_curNP;

    end

    time = toc;
    fprintf('CPU time for packing h tree: %d s \n', time);
