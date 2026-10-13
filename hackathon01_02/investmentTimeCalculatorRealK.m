% investmentTimeCalculatorRealK.m
function result = investmentTimeCalculatorRealK(Y, K, r, q)
%INVESTMENTTIMECALCULATORREALK Estimate time to reach a target real value.
%
% Inputs:
%   Y - target amount in today's RM (real value), Y > 0
%   K - fixed real monthly contribution, K > 0
%   r - effective annual return (decimal), r > -1
%   q - annual inflation rate (decimal), q > -1
%
% Output:
%   result - struct with feasibility, months, years, balances, and gain
%
% Assumptions:
%   - Contributions are made at the end of each month.
%   - Returns compound monthly.
%   - K is a real (inflation-adjusted) contribution.

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
end

if r <= -1 || q <= -1
    error('r and q must be greater than -1.');
end

% Real annual return (Fisher equation)
rReal = (1 + r) / (1 + q) - 1;

% Real monthly rate (numerically stable)
i = expm1( log1p(rReal) / 12 );

% Nominal monthly rate (for reference)
j = expm1( log1p(r) / 12 );

tol = 1e-12;
if abs(i) < tol
    i = 0;
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

% Feasibility check for negative real rate
if i < 0 && Y >= K / (-i)
    result.feasible = false;
    result.message = "Target cannot be reached under the given assumptions.";
    return;
end

% Find smallest integer n such that realFV(n) >= Y
if i == 0
    n = ceil(Y / K);
else
    n = ceil( log1p(Y * i / K) / log1p(i) );
    n = max(0, n);
end

% Discrete correction for floating-point safety
while realFV(n, K, i) < Y
    n = n + 1;
end
while n > 0 && realFV(n - 1, K, i) >= Y
    n = n - 1;
end

% Real future value
realFV_n = realFV(n, K, i);

% Nominal future value: inflate the real value by cumulative inflation
nominalFV_n = realFV_n * (1 + q)^(n / 12);

% Total nominal contributions (K is real, so each contribution grows with inflation)
if q == 0
    totalNominalContrib = K * n;
else
    a = (1 + q)^(1/12);   % monthly inflation factor
    totalNominalContrib = K * a * (a^n - 1) / (a - 1);
end

totalGain = nominalFV_n - totalNominalContrib;

result.feasible = true;
result.months = n;
result.years = n / 12;
result.realFutureValue = realFV_n;
result.nominalFutureValue = nominalFV_n;
result.totalContributions = totalNominalContrib;
result.totalGain = totalGain;
result.message = "Target reached.";

end

function fv = realFV(n, K, i)
% Real future value of end-of-month contributions
if i == 0
    fv = K * n;
else
    fv = K * expm1(n * log1p(i)) / i;
end
end