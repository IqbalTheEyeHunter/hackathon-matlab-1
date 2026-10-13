function sa = sensitivityAnalysis(Y, K, r, q, rRange, qRange)
%SENSITIVITYANALYSIS Compute months over a grid of (r, q) values.

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
    rRange (1,:) double = 0.02:0.01:0.12
    qRange (1,:) double = 0.00:0.01:0.06
end

nR = numel(rRange);
nQ = numel(qRange);
monthsGrid = NaN(nR, nQ);

for a = 1:nR
    for b = 1:nQ
        res = investmentTimeCalculator(Y, K, rRange(a), qRange(b));
        if res.feasible
            monthsGrid(a, b) = res.months;
        end
    end
end

baseRes = investmentTimeCalculator(Y, K, r, q);

sa = struct( ...
    'rRange', rRange, ...
    'qRange', qRange, ...
    'monthsGrid', monthsGrid, ...
    'baseR', r, ...
    'baseQ', q, ...
    'baseMonths', baseRes.months, ...
    'baseFeasible', baseRes.feasible );
end