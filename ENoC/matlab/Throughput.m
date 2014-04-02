figure;
hold all;

x = linspace(0.05,1,20);

hTP1 = plot(x, TPM3D000);
hTP2 = plot(x, TPM3D010);
hTP3 = plot(x, TPM3D011);
hTP4 = plot(x, TPM3D100);
hTP5 = plot(x, TPM3D111);

box on;

xlim([0 1]);
ylim([0 1]);

set(gca, 'XTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'YTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

axis square;

hylabel = ylabel('Throughput (fraction of capacity)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 

hLegend = legend([hTP1, hTP2, hTP3, hTP4, hTP5], '4-ary 3-mesh', '4-ary 3-mesh with VOQ', '4-ary 3-mesh with iSLIP VOQ', '4-ary 3-mesh with iSLIP VOQ and load balancing', '4-ary 3-mesh with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0.05,1,20);

hTP11 = plot(x, TPM000);
hTP21 = plot(x, TPM010);
hTP31 = plot(x, TPM011);
hTP41 = plot(x, TPM100);
hTP51 = plot(x, TPM111);

box on;

xlim([0 1]);
ylim([0 1]);

set(gca, 'XTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'YTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

axis square;

hylabel = ylabel('Throughput (fraction of capacity)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 

hLegend = legend([hTP11, hTP21, hTP31, hTP41, hTP51], '8-ary 2-mesh', '8-ary 2-mesh with VOQ', '8-ary 2-mesh with iSLIP VOQ', '8-ary 2-mesh with iSLIP VOQ and load balancing', '8-ary 2-mesh with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0.05,1,20);

hTP12 = plot(x, TPC000);
hTP22 = plot(x, TPC010);
hTP32 = plot(x, TPC011);
hTP42 = plot(x, TPC100);
hTP52 = plot(x, TPC111);

box on;

xlim([0 1]);
ylim([0 1]);

set(gca, 'XTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'YTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

axis square;

hylabel = ylabel('Throughput (fraction of capacity)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 

hLegend = legend([hTP12, hTP22, hTP32, hTP42, hTP52], '8-ary 2-cube', '8-ary 2-cube with VOQ', '8-ary 2-cube with iSLIP VOQ', '8-ary 2-cube with iSLIP VOQ and load balancing', '8-ary 2-cube with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0.05,1,20);

hTP13 = plot(x, TPC3D000);
hTP23 = plot(x, TPC3D010);
hTP33 = plot(x, TPC3D011);
hTP43 = plot(x, TPC3D100);
hTP53 = plot(x, TPC3D111);

box on;

xlim([0 1]);
ylim([0 1]);

set(gca, 'XTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'YTick', [0 0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

axis square;

hylabel = ylabel('Throughput (fraction of capacity)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 

hLegend = legend([hTP13, hTP23, hTP33, hTP43, hTP53], '4-ary 3-cube', '4-ary 3-cube with VOQ', '4-ary 3-cube with iSLIP VOQ', '4-ary 3-cube with iSLIP VOQ and load balancing', '4-ary 3-cube with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;