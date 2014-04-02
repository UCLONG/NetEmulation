figure;
hold on;

hEnsemble = plot(Packets, Ensemble, '-');
hSingleRun = plot(Packets, SingleRun, ':');

xlim([0 6000]);
ylim([0 12]);

box on;

set(gca, 'XTick', [2000 4000 6000]);
set(gca, 'XMinorTick', 'on');

hylabel = ylabel('Avg. packet latency (cycles)');
hxlabel = xlabel('Total packet arrivals'); 

hLegend = legend([hEnsemble, hSingleRun], 'Ensemble','Single Run');

set(findall(gcf,'type','axes'),'fontSize',8,'fontName','Times New Roman');
set(findall(gcf,'type','text'),'fontSize',8,'fontName','Times New Roman');
set([hxlabel hylabel], 'FontWeight', 'bold');

set(gcf,'color','w');