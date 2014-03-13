% File: batchAnalysis.m
% Boris Dosen, UCL, March 2014
%
% Fuction: Plots latency vs offered traffic by analysing data from NEMU
%          simulation

function [] = latencyPlot(numberOfRuns, PORTS)

totalLatency = zeros(1, numberOfRuns);
pktRX = zeros(1, numberOfRuns);
pktTX = zeros(1, numberOfRuns);

for i = 1:numberOfRuns;
    nameOfTotalLatencyFile = strcat('totalLatency', num2str(i), '.txt');
    nameOfPktRXFile = strcat('pktRX', num2str(i), '.txt');
    nameOfPktTXFile = strcat('pktTX', num2str(i), '.txt');
    totalLatency(i) = sum(analyseData(nameOfTotalLatencyFile, PORTS));
    pktRX(i) = sum(analyseData(nameOfPktRXFile, PORTS));
    pktTX(i) = sum(analyseData(nameOfPktTXFile, PORTS));
end

avgLatency = totalLatency./pktRX;

x = [12:4:100];
figure
plot(x, totalLatency)
title('Latency')
xlabel('Offered Traffic')
ylabel('Average Latency');

end