% demo_montecarlo.m
clearvars; clc;

Y            = 100000;    % target real value (today's RM)
K            = 500;       % real monthly contribution
r            = 0.06;      % expected annual return
q            = 0.03;      % annual inflation
sigmaAnnual  = 0.10;      % annual volatility (10%)
numSims      = 20000;
seed         = 42;

res = investmentTimeMonteCarlo(Y, K, r, q, sigmaAnnual, numSims, seed);

fprintf('Expected real annual return: %.4f%%\n', res.realAnnualReturn * 100);
fprintf('Annual volatility:           %.2f%%\n', res.annualVolatility * 100);
fprintf('P(reach target):             %.4f\n\n', res.pReach);

fprintf('Percentile months to reach target (conditional on reaching):\n');
for k = 1:numel(res.percentileLabels)
    fprintf('  %2dth pct: %6.1f months  (%5.2f years)\n', ...
        res.percentileLabels(k), res.percentileMonths(k), res.percentileYears(k));
end
fprintf('\n');

fprintf('Months required for target probabilities:\n');
for k = 1:numel(res.targetProbLabels)
    fprintf('  P(reach) >= %4.2f  ->  %6.1f months  (%5.2f years)\n', ...
        res.targetProbLabels(k), res.monthsForProb(k), res.yearsForProb(k));
end

% Plot probability curve
figure;
plot(res.horizonYears, res.probReachBy, 'LineWidth', 1.5);
xlabel('Years'); ylabel('P(reach target within t years)');
title('Monte Carlo: Probability of Reaching Target');
grid on; ylim([0 1]);