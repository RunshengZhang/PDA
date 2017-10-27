% Read Input Files
% Yunyi
% Oct 27 2017

function [block, net, S] = read_input( name )

tic;

%%  1. Read Block
block = strings();
fp = fopen(sprintf('./files/%s/%s.block', name, name), 'r');

i = 1;
while (feof(fp) == 0)
    line = fgetl(fp);
    temp = string(split(line))';
    block(i,1:3) = temp(1:3);
    i = i+1;
end
fclose(fp);
fprintf('Read in block information ... Successful\n');

%%  2. Read Net
net = struct();
fp = fopen(sprintf('./files/%s/%s.net', name, name), 'r');

i = 1;
while (feof(fp) == 0)
    line = fgetl(fp);
    temp = string(split(line))';
    if temp(end)==''
        temp(end) = [];
    end
    fieldname = sprintf('net%g', i);
    temp = temp(2:3:(length(temp)-2));              %   Obtain block list in a net
    for j = 1:length(temp)
        index = find(strcmp(temp(j), block(:,1)));  %   Find index in "block"
        net.(fieldname)(j) = index;                 %   Save the index
    end
    net.(fieldname) = unique(net.(fieldname));      %   Delete repeated index
    i = i+1;
end
fclose(fp);
fprintf('Read in netlist information ... Successful\n');

%%  3. Read Symmetry
S.pair = [];
S.self = [];
fp = fopen(sprintf('./files/%s/%s.sym', name, name), 'r');

i = 1;
while (feof(fp) == 0)
    line = fgetl(fp);
    temp = string(split(line))';
    if temp(end)==''
        temp(end) = [];
    end
    for j = 1:length(temp)
        index = find(strcmp(temp(j), block(:,1)));  %   Find index in "block"
        temp(j) = index;                            %   Save the index
    end
    switch length(temp)
        case 1
            S.self = [S.self, temp];
        case 2
            S.pair = [S.pair, temp];
    end
end
S.pair = reshape(S.pair, [2,length(S.pair)/2]);
S.pair = S.pair';
fclose(fp);
fprintf('Read in symmetry information ... Successful\n');

time = toc;
fprintf('CPU Time for reading inputs: %g s\n', time);
