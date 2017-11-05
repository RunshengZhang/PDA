% test the function of ASF_packing

testbench = { 'ami33', 'ami49', 'apte', 'hp', 'COMPARATOR_V2_VAR_K2' };
name = char(testbench(3));

[block, net, S] = read_input( name ); 

asf_tree = [2,0,0;
            4,2,0;
            6,0,4;
            8,0,2];
        
[ asf_placement, asf_contour] = ASFTreePacking(block, asf_tree,  S)