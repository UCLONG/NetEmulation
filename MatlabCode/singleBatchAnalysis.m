% File: batchAnalysis.m
% Boris Dosen, UCL, March 2014
%
% Fuction:  Provides average latency from NEMU simulation results for
%           each node pair


function [formatedBatchLatency] = singleBatchAnalysis (datafile, PORTS)

input = textread(datafile, '%s', 'delimiter', ',');
input = strrep(input, '{', '');
input = strrep(input, '}', '');
input = strrep(input, '''', '');
input = str2double(input);


size = numel(input);
global rows;
rows = size/(PORTS^2);
batchLatency = zeros(rows, 1);

input = reshape(input, PORTS^2, rows);
input = input.';

for i = 1:(rows-1)
    input((rows-(i-1)),:) = input((rows-(i-1)),:) - input((rows-i),:);
end

for i = 1:rows;
    batchLatency(i) = mean(input(i, :));
end

formatedBatchLatency(1:250) = batchLatency(1:250);

avgLatency = sum(input(:))/size;


end