%% No Load Balancing - Latency

figure;
hold all;
box on;

xlim([0 80]);
ylim([0 20]);

set(gca, 'XTick', [20 40 60 80]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLsimp   = plot(Osimp, Lsimp, '-+');
hLVOQ    = plot(OVOQ, LVOQ, '-.o');
hLiSLIP  = plot(OiSLIP, LiSLIP, '--*');

hLegend = legend([hLsimp, hLVOQ, hLiSLIP], 'Input Queued Switch', 'Input Queued Switch with VOQ', 'Input Queued Switch with iSLIP VOQ', 'Location', 'NorthWest');

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

%% Histogram Simple

figure;
hold all;
box on;

xlim([0 40]);
ylim([0 0.35]);

hylabel = ylabel('P(packet latency = k)');
hxlabel = xlabel('k');

hLfsimp = bar(Lfsimp);

hLegend = legend([hLfsimp], 'Input Queued Switch', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram VOQ

figure;
hold all;
box on;

xlim([0 40]);
ylim([0 0.35]);

hylabel = ylabel('P(packet latency = k)');
hxlabel = xlabel('k');

hLfVOQ = bar(LfVOQ);

hLegend = legend([hLfVOQ], 'Input Queued Switch with VOQ', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram iSLIP

figure;
hold all;
box on;

xlim([0 40]);
ylim([0 0.35]);

hylabel = ylabel('P(packet latency = k)');
hxlabel = xlabel('k'); 

hLfSLIP = bar(LfiSLIP);

hLegend = legend([hLfSLIP], 'Input Queued Switch with iSLIP VOQ', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;