clearvars; clc;

Y = 100000; K = 500; r = 0.06; q = 0.03;

%% 1. Base case: solve for time
fprintf('########## 1. Solve for Time ##########\n');
resTime = investmentTimeCalculator(Y, K, r, q);
printResult(resTime);

%% 2. Solve for required contribution K
T = 15;
fprintf('########## 2. Solve for Contribution (T = %d yr) ##########\n', T);
resK = solveForContribution(Y, T, r, q);
printResult(resK);

% Cross-check
chk = investmentTimeCalculator(Y, resK.K, r, q);
fprintf('Cross-check months: %d (expected %d)\n', chk.months, resK.months);

%% 3. Solve for required return r
T = 15;
fprintf('########## 3. Solve for Return (T = %d yr) ##########\n', T);
resR = solveForReturn(Y, K, T, q);
printResult(resR);

chk = investmentTimeCalculator(Y, K, resR.r, q);
fprintf('Cross-check months: %d (expected %d)\n', chk.months, resR.months);

%% 4. Solve for required inflation q
T = 15;
fprintf('########## 4. Solve for Inflation (T = %d yr) ##########\n', T);
resQ = solveForInflation(Y, K, T, r);
printResult(resQ);

chk = investmentTimeCalculator(Y, K, r, resQ.q);
fprintf('Cross-check months: %d (expected %d)\n', chk.months, resQ.months);

%% 5. Sensitivity analysis over (r, q)
fprintf('########## 5. Sensitivity Analysis ##########\n');
rRange = 0.02:0.01:0.12;
qRange = 0.00:0.01:0.06;
sa = sensitivityAnalysis(Y, K, r, q, rRange, qRange);
fprintf('Grid size: %d x %d, base months: %d\n', ...
    size(sa.monthsGrid, 1), size(sa.monthsGrid, 2), sa.baseMonths);

%% 6. Plots
plotSensitivity(sa);
plotGrowth(Y, K, r, q);