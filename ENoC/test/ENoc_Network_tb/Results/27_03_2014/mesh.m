% 2D Latency

figure;
hold all;
box on;

xlim([0 70]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40 50 60 70]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLsimp2D   = plot(Osimp2D, Lsimp2D, '-+');
hLVOQ2D    = plot(OVOQ2D, LVOQ2D, '-.o');
hLiSLIP2D  = plot(OiSLIP2D, LiSLIP2D, '--*');

hLegend = legend([hLsimp2D, hLVOQ2D, hLiSLIP2D], '64-port, 8-ary 2-mesh, 4-packet queue', '64-port, 8-ary 2-mesh with VOQ, 4-packet queue', '64 port, 8-ary 2-mesh with iSLIP VOQ, 4-packet queue', 'Location', 'SouthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% 3D Latency

figure;
hold all;
box on;

xlim([0 70]);
ylim([0 20]);

set(gca, 'XTick', [10 20 30 40 50 60 70]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (percentage of capacity)');

hLsimp3D   = plot(Osimp3D, Lsimp3D, '-+');
hLVOQ3D    = plot(OVOQ3D, LVOQ3D, '-.o');
hLiSLIP3D  = plot(OiSLIP3D, LiSLIP3D, '--*');

hLegend = legend([hLsimp3D, hLVOQ3D, hLiSLIP3D], '64-port, 4-ary 3-mesh, 4-packet input', '64-port, 4-ary 3-mesh with VOQ, 4-packet input', '64-port, 4-ary 3-mesh with iSLIP VOQ, 4-packet input', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% 2D Throughput

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

hTsimp2D   = plot(Osimp2D, Tsimp2D, '-+');
hTVOQ2D    = plot(OVOQ2D, TVOQ2D, '-.o');
hTiSLIP2D  = plot(OiSLIP2D, TiSLIP2D, '--*');

hylabel = ylabel('Throughput (percentage of capacity)');
hxlabel = xlabel('Offered traffic (percentage of capacity)'); 

hLegend = legend([hTsimp2D, hTVOQ2D, hTiSLIP2D], '64-port, 8-ary 2-mesh, 4-packet queue', '64-port, 8-ary 2-mesh with VOQ, 4-packet queue', '64 port, 8-ary 2-mesh with iSLIP VOQ, 4-packet queue', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% 3D Throughput

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

hTsimp3D   = plot(Osimp3D, Tsimp3D, '-+');
hTVOQ3D    = plot(OVOQ3D, TVOQ3D, '-.o');
hTiSLIP3D  = plot(OiSLIP3D, TiSLIP3D, '--*');

hylabel = ylabel('Throughput (percentage of capacity)');
hxlabel = xlabel('Offered traffic (percentage of capacity)'); 

hLegend = legend([hTsimp3D, hTVOQ3D, hTiSLIP3D], '64-port, 4-ary 3-mesh, 4-packet queue', '64-port, 4-ary 3-mesh with VOQ, 4-packet queue', '64 port, 4-ary 3-mesh with iSLIP VOQ, 4-packet queue', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 2D Simple

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfsimp2D = bar(Lfsimp2D);

hLegend = legend([hLfsimp2D], '64-port, 8-ary 2-mesh, 4-packet queue', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 2D VOQ

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfVOQ2D = bar(LfVOQ2D);

hLegend = legend([hLfVOQ2D], '64-port, 8-ary 2-mesh with VOQ, 4-packet queue', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 2D iSLIP

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfSLIP2D = bar(LfiSLIP2D);

hLegend = legend([hLfSLIP2D], '64-port, 8-ary 2-mesh with iSLIP VOQ, 4-packet queue', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 3D Simple

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfsimp3D = bar(Lfsimp3D);

hLegend = legend([hLfsimp3D], '64-port, 4-ary 3-mesh, 4-packet queue', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

%% Histogram 3D VOQ

figure;
hold all;
box on;

xlim([0 100]);
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfVOQ3D = bar(LfVOQ3D);

hLegend = legend([hLfVOQ3D], '64-port, 4-ary 3-mesh with VOQ, 4-packet queue', 'Location', 'NorthEast');

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
ylim([0 0.1]);

hylabel = ylabel('Normalised Frequency');
hxlabel = xlabel('packet latency (cycles)'); 

hLfiSLIP3D = bar(LfiSLIP3D);

hLegend = legend([hLfiSLIP3D], '64-port, 4-ary 3-mesh with iSLIP VOQ, 4-packet queue', 'Location', 'NorthEast');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;