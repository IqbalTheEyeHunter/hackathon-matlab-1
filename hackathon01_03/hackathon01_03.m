clearvars; clc;

Y = 100000;
K = 500;
r = 0.06;
q = 0.03;

res = investmentTimeCalculatorBinarySearch(Y, K, r, q);

if res.feasible
    fprintf('Target reached in %d months (%.2f years).\n', res.months, res.years);
    fprintf('Binary search iterations:    %d\n', res.iterations);
    fprintf('Real future value:           RM %.2f\n', res.realFutureValue);
    fprintf('Nominal future value:        RM %.2f\n', res.nominalFutureValue);
    fprintf('Total nominal contributions: RM %.2f\n', res.totalContributions);
    fprintf('Nominal gain:                RM %.2f\n', res.totalGain);
else
    fprintf('%s\n', res.message);
end