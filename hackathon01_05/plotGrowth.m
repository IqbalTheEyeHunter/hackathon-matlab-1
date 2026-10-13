function fig = plotGrowth(Y, K, r, q, nMax)
%PLOTGROWTH Plot real and nominal wealth growth vs time.

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
    nMax double {mustBeScalarOrEmpty} = []   % [] = auto-select
end

res = investmentTimeCalculator(Y, K, r, q);
if ~res.feasible
    error('Cannot plot growth: target infeasible.');
end

% Auto-select nMax if not supplied
if isempty(nMax)
    nMax = max(res.months * 2, 12);
else
    if ~(isfinite(nMax) && nMax > 0)
        error('nMax must be a positive finite scalar.');
    end
    nMax = round(nMax);
end

n = (0:nMax)';
i = res.realMonthlyRate;

if abs(i) < 1e-12
    Wreal = K * n;
else
    Wreal = K * expm1(n * log1p(i)) / i;
end
Wnom = Wreal .* (1 + q).^(n / 12);

fig = figure('Color', 'w', 'Position', [100 100 900 500]);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
plot(n / 12, Wreal, 'b-', 'LineWidth', 1.8); hold on;
yline(Y, 'r--', 'Target Y', 'LineWidth', 1.2);
xline(res.months / 12, 'k:', sprintf('n = %d mo', res.months), 'LineWidth', 1.2);
xlabel('Years'); ylabel('Real value (today''s RM)');
title('Real Wealth Growth'); grid on;

nexttile;
plot(n / 12, Wnom, 'g-', 'LineWidth', 1.8); hold on;
yline(Y * (1 + q)^(res.months / 12), 'r--', 'Nominal target', 'LineWidth', 1.2);
xline(res.months / 12, 'k:', 'LineWidth', 1.2);
xlabel('Years'); ylabel('Nominal value (RM)');
title('Nominal Wealth Growth'); grid on;

sgtitle(sprintf('Growth: Y = RM %g, K = RM %g/mo, r = %.2f%%, q = %.2f%%', ...
    Y, K, r * 100, q * 100));
end