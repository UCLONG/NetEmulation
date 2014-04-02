% File: batchAnalysis.m
% Boris Dosen, UCL, March 2014
%
% Fuction: Performs latency batch analysis from NEMU simulation results



function [] = batchAnalysis(numberOfBatches, PORTS)

latency = zeros(numberOfBatches, 250);
avgLatency = zeros(1, 250);
tempstring1 = 'latency';
tempstring3 = '.txt';

for i = 1:numberOfBatches;
    tempstring2 = num2str(i);
    nameOfFile = strcat(tempstring1, tempstring2, tempstring3);
    disp(sprintf('Calculating latency of batch number %d', i));
    latency(i, :) = singleBatchAnalysis(nameOfFile, PORTS);
    avgLatency = avgLatency + latency(i,:);
end

disp('Almost done');

avgLatency = avgLatency/numberOfBatches;



x = [1:250];

figure
plot(x, latency(1,:), x, avgLatency)
title('Batch Analysis')
xlabel('Batch')
ylabel('Average Latency');

end