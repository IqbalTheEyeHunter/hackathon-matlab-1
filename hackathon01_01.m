% just to be on the safe side
clear all

% Inputs:
%   Y - target amount in today's RM (real value), Y > 0
%   K - fixed monthly contribution, K > 0
%   r - effective annual return (decimal)
%   q - annual inflation rate (decimal)
res = investmentTimeCalculator(100000, 500, 0.06, 0.03);

function fv = realFV(n, K, i)
if i == 0
    fv = K * n;
else
    fv = K * ((1 + i)^n - 1) / i;
end
end

function fv = nominalFV(n, K, j)
if j == 0
    fv = K * n;
else
    fv = K * ((1 + j)^n - 1) / j;
end
end

function result = investmentTimeCalculator(Y, K, r, q)
%INVESTMENTTIMECALCULATOR Estimate time to reach a target real value.
%
% Inputs:
%   Y - target amount in today's RM (real value), Y > 0
%   K - fixed monthly contribution, K > 0
%   r - effective annual return (decimal)
%   q - annual inflation rate (decimal)
%
% Output:
%   result - struct with feasibility, months, years, balances, and gain

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
end

rReal = (1 + r) / (1 + q) - 1;
i = (1 + rReal)^(1/12) - 1;   % real monthly rate
j = (1 + r)^(1/12) - 1;       % nominal monthly rate

tol = 1e-12;
if abs(i) < tol
    i = 0;
end
if abs(j) < tol
    j = 0;
end

result = struct( ...
    'feasible', true, ...
    'months', NaN, ...
    'years', NaN, ...
    'realFutureValue', NaN, ...
    'nominalFutureValue', NaN, ...
    'totalContributions', NaN, ...
    'totalGain', NaN, ...
    'realMonthlyRate', i, ...
    'nominalMonthlyRate', j, ...
    'realAnnualReturn', rReal, ...
    'message', "" );

if i < 0 && Y >= K / (-i)
    result.feasible = false;
    result.message = "Target cannot be reached under the given assumptions.";
    return
end

if i == 0
    n = ceil(Y / K);
else
    nGuess = ceil(log1p(Y * i / K) / log1p(i));
    n = max(0, nGuess);

    while realFV(n, K, i) < Y
        n = n + 1;
    end
    while n > 0 && realFV(n - 1, K, i) >= Y
        n = n - 1;
    end
end

result.months = n;
result.years = n / 12;
result.realFutureValue = realFV(n, K, i);
result.nominalFutureValue = nominalFV(n, K, j);
result.totalContributions = K * n;
result.totalGain = result.nominalFutureValue - result.totalContributions;
end