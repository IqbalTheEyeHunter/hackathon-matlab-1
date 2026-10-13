function fig = plotSensitivity(sa)
%PLOTSENSITIVITY Heatmap of months over (r, q) grid.

fig = figure('Color', 'w', 'Position', [100 100 800 550]);
imagesc(sa.qRange, sa.rRange, sa.monthsGrid);
set(gca, 'YDir', 'normal');
colorbar; colormap(parula);
xlabel('Annual inflation q');
ylabel('Annual return r');
title(sprintf('Months to reach target (base case: %d months)', sa.baseMonths));

hold on;
plot(sa.baseQ, sa.baseR, 'rx', 'MarkerSize', 14, 'LineWidth', 2.5);
hold off;

xticks(sa.qRange);
xticklabels(arrayfun(@(x) sprintf('%.0f%%', x*100), sa.qRange, ...
    'UniformOutput', false));
yticks(sa.rRange);
yticklabels(arrayfun(@(x) sprintf('%.0f%%', x*100), sa.rRange, ...
    'UniformOutput', false));
end