% Main - test only
% Yunyi

clear;
clc;

%%  0. Set Parameters
testbench = { 'ami33', 'ami49', 'apte', 'hp', 'COMPARATOR_V2_VAR_K2' };
name = char(testbench(1));

%%  1. Parse Inputs
[block, net, S] = read_input( name );