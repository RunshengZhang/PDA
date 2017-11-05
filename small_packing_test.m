% test the function of ASF_packing

testbench = { 'ami33', 'ami49', 'apte', 'hp', 'COMPARATOR_V2_VAR_K2' };
name = char(testbench(3));

[block, net, S] = read_input( name ); 

asf_tree = [9,0,0;
            4,9,0;
            6,0,4;
            8,0,9;
            2,0,8];
        
[ asf_placement, asf_contour] = ASFTreePacking(block, asf_tree,  S);