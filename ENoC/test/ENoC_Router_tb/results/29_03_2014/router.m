%% No Load Balancing - Latency

figure;
hold all;
box on;

xlim([0 40]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLsimp   = plot(Osimp, Lsimp, '-+');
hLVOQ    = plot(OVOQ, LVOQ, '-.o');
hLiSLIP  = plot(OiSLIP, LiSLIP, '--*');

hLegend = legend([hLsimp, hLVOQ, hLiSLIP], '5-port, 4-packet queue, simple input queued switch', '5-port, 4-packet queue, input queued switch with VOQ', '5-port, 4-packet queue, input queued switch with iSLIP VOQ', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Load Balancing - Latency

figure;
hold all;
box on;

xlim([0 40]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLLB   = plot(OLB, LLB, '-+');
hLVOQLB    = plot(OVOQLB, LVOQLB, '-.o');
hLiSLIPLB  = plot(OiSLIPLB, LiSLIPLB, '--*');

hLegend = legend([hLLB, hLVOQLB, hLiSLIPLB], '5-port, 4-packet queue, Load balanced, simple input queued switch', '5-port, 4-packet queue, load balanced, input queued switch with VOQ', '5-port, 4-packet queue, load balanced, input queued switch with iSLIP VOQ', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% No Load Balancing - Throughput

figure;
hold all;

box on;
axis square;

xlim([0 100]);
ylim([0 100]);

set(gca, 'XTick', [0 20 40 60 80 100]);
set(gca, 'YTick', [0 20 40 60 80 100]);
set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on');

hTsimp   = plot(Osimp, Tsimp, '-+');
hTVOQ    = plot(OVOQ, TVOQ, '-.o');
hTiSLIP  = plot(OiSLIP, TiSLIP, '--*');

hylabel = ylabel('Throughput (percentage of capacity)');
hxlabel = xlabel('Offered traffic (percentage of capacity)'); 

hLegend = legend([hTsimp, hTVOQ, hTiSLIP], '5-port, 4-packet queue, simple input queued switch', '5-port, 4-packet queue, input queued switch with VOQ', '5-port, 4-packet queue, input queued switch with iSLIP VOQ', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Load Balancing - Throughput

figure;
hold all;

box on;
axis square;

xlim([0 100]);
ylim([0 100]);

set(gca, 'XTick', [0 20 40 60 80 100]);
set(gca, 'YTick', [0 20 40 60 80 100]);
set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on');

hTLB   = plot(OLB, TLB, '-+');
hTVOQLB    = plot(OVOQLB, TVOQLB, '-.o');
hTiSLIPLB  = plot(OiSLIPLB, TiSLIPLB, '--*');

hylabel = ylabel('Throughput (percentage of capacity)');
hxlabel = xlabel('Offered traffic (percentage of capacity)'); 

hLegend = legend([hTLB, hTVOQLB, hTiSLIPLB], '5-port, 4-packet queue, Load balanced, simple input queued switch', '5-port, 4-packet queue, load balanced, input queued switch with VOQ', '5-port, 4-packet queue, load balanced, input queued switch with iSLIP VOQ', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram No Load Balancing Simple

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfsimp = bar(Lfsimp);

hLegend = legend([hLfsimp], '5-port, 4-packet queue, simple input queued switch', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram VOQ

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfVOQ = bar(LfVOQ);

hLegend = legend([hLfVOQ], '5-port, 4-packet input queue with VOQ', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram iSLIP

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfSLIP = bar(LfiSLIP);

hLegend = legend([hLfSLIP], '5-port, 4-packet input queue with iSLIP VOQ', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram Load Balancing

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfLB = bar(LfLB);

hLegend = legend([hLfLB], '5-port, 4-packet input queue with load balancing', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram Load Balancing, VOQ

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfVOQLB = bar(LfVOQLB);

hLegend = legend([hLfVOQLB], '5-port, VOQ, 4-packet input queue with load balancing', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 3D iSLIP

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.35]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfiSLIPLB = bar(LfiSLIPLB);

hLegend = legend([hLfiSLIPLB], '5-port, iSLIP VOQ, 4-packet input queue with load balancing', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;