%% No Load Balancing - Latency

figure;
hold all;
box on;

xlim([0 80]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40 50 60 70 80]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLsimp   = plot(Osimp, Lsimp, '-+');
hLVOQ    = plot(OVOQ, LVOQ, '-.o');
hLiSLIP  = plot(OiSLIP, LiSLIP, '--*');

hLegend = legend([hLsimp, hLVOQ, hLiSLIP], 'Input Queued Switch', 'Input Queued Switch with VOQ', 'Input Queued Switch with iSLIP VOQ', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Load Balancing - Latency

figure;
hold all;
box on;

xlim([0 80]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40 50 60 70 80]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLLB   = plot(OLB, LLB, '-+');
hLVOQLB    = plot(OVOQLB, LVOQLB, '-.o');
hLiSLIPLB  = plot(OiSLIPLB, LiSLIPLB, '--*');

hLegend = legend([hLLB, hLVOQLB, hLiSLIPLB], 'Load Balanced, Input Queued Switch', 'Load Balanced, Input Queued Switch with VOQ', 'Load Balanced, Input Queued Switch with iSLIP VOQ', 'Location', 'NorthWest');

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

hLegend = legend([hTsimp, hTVOQ, hTiSLIP], 'Input Queued Switch', 'Input Queued Switch with VOQ', 'Input Queued Switch with iSLIP VOQ', 'Location', 'NorthWest');

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

hLegend = legend([hTLB, hTVOQLB, hTiSLIPLB], 'Load Balanced, Input Queued Switch', 'Load Balanced, Input Queued Switch with VOQ', 'Load Balanced, Input Queued Switch with iSLIP VOQ', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;