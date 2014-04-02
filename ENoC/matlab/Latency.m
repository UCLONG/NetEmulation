figure;
hold all;

x = linspace(0,1,20);

hL1 = plot(x, LC000);
hL2 = plot(x,LC010);
hL3 = plot(x, LC011);
hL4 = plot(x, LC100);
hL5 = plot(x, LC111);

box on;

xlim([0 1]);
ylim([0 75]);

set(gca, 'XTick', [0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 


hLegend = legend([hL1, hL2, hL3, hL4, hL5], '8-ary 2-cube', '8-ary 2-cube with VOQ', '8-ary 2-cube with iSLIP VOQ', '8-ary 2-cube with iSLIP VOQ and load balancing', '8-ary 2-cube with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0,1,20);

hL12 = plot(x, LC3D000);
hL22 = plot(x, LC3D010);
hL32 = plot(x, LC3D011);
hL42 = plot(x, LC3D100);
hL52 = plot(x, LC3D111);

box on;

xlim([0 1]);
ylim([0 75]);

set(gca, 'XTick', [0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 


hLegend = legend([hL12, hL22, hL32, hL42, hL52], '4-ary 3-cube', '4-ary 3-cube with VOQ', '4-ary 3-cube with iSLIP VOQ', '4-ary 3-cube with iSLIP VOQ and load balancing', '4-ary 3-cube with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0,1,20);

hL13 = plot(x, LM000);
hL23 = plot(x, LM010);
hL33 = plot(x, LM011);
hL43 = plot(x, LM100);
hL53 = plot(x, LM111);

box on;

xlim([0 1]);
ylim([0 75]);

set(gca, 'XTick', [0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 


hLegend = legend([hL13, hL23, hL33, hL43, hL53], '8-ary 2-mesh', '8-ary 2-mesh with VOQ', '8-ary 2-mesh with iSLIP VOQ', '8-ary 2-mesh with iSLIP VOQ and load balancing', '8-ary 2-mesh with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;

figure;
hold all;

x = linspace(0,1,20);

hL14 = plot(x, LM3D000);
hL24 = plot(x, LM3D010);
hL34 = plot(x, LM3D011);
hL44 = plot(x, LM3D100);
hL54 = plot(x, LM3D111);

box on;

xlim([0 1]);
ylim([0 75]);

set(gca, 'XTick', [0.2 0.4 0.6 0.8 1.0]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Offered traffic (fraction of capacity)'); 


hLegend = legend([hL14, hL24, hL34, hL44, hL54], '4-ary 3-mesh', '4-ary 3-mesh with VOQ', '4-ary 3-mesh with iSLIP VOQ', '4-ary 3-mesh with iSLIP VOQ and load balancing', '4-ary 3-mesh with load balancing', 'Location', 'NorthWest');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman')
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman')
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');

hold off;