% demo_investment.m
clearvars; clc;

Y = 100000;   % target real value (today's RM)
K = 500;      % real monthly contribution
r = 0.06;     % effective annual return
q = 0.03;     % annual inflation

res = investmentTimeCalculatorRealK(Y, K, r, q);

if res.feasible
    fprintf('Target reached in %d months (%.2f years).\n', res.months, res.years);
    fprintf('Real future value:        RM %.2f\n', res.realFutureValue);
    fprintf('Nominal future value:     RM %.2f\n', res.nominalFutureValue);
    fprintf('Total nominal contributions: RM %.2f\n', res.totalContributions);
    fprintf('Nominal gain:             RM %.2f\n', res.totalGain);
    fprintf('Real monthly rate:        %.6f%%\n', res.realMonthlyRate * 100);
    fprintf('Real annual return:       %.4f%%\n', res.realAnnualReturn * 100);
else
    fprintf('%s\n', res.message);
end