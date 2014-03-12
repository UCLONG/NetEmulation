% File: analyseData.m
% Boris Dosen, UCL, March 2014
%
% Fuction: Used to convert .txt files, created by System Verilog comman $fdisplay(filePktRX, "%p", o_pkt_count_rx)
%          into one dimension matrix of type double


function [input] = analyseData(datafile, PORTS)

input = textread(datafile, '%s', 'delimiter', ',');
input = strrep(input, '{', '');
input = strrep(input, '}', '');
input = strrep(input, '''', '');
input = str2double(input);


size = numel(input);
rows = size/(PORTS^2);

input = reshape(input, PORTS^2, rows);
input = input.';


end