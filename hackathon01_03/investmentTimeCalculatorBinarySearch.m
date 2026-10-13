% investmentTimeCalculatorBinarySearch.m
function result = investmentTimeCalculatorBinarySearch(Y, K, r, q)
%INVESTMENTTIMECALCULATORBINARYSEARCH Time to reach a target real value.
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
% Method:
%   Binary search on the smallest integer n such that realFV(n) >= Y.
%   RealFV is monotonic increasing in n (for i > -1), so binary search
%   is valid even when i < 0.

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
end

if r <= -1 || q <= -1
    error('r and q must be greater than -1.');
end

% Real and nominal annual/monthly rates
rReal = (1 + r) / (1 + q) - 1;
i = expm1( log1p(rReal) / 12 );   % real monthly rate
j = expm1( log1p(r)    / 12 );    % nominal monthly rate

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
    'iterations', NaN, ...
    'message', "" );

% Feasibility: if i < 0, realFV(n) -> K / (-i) as n -> inf
if i < 0 && Y >= K / (-i)
    result.feasible = false;
    result.message = "Target cannot be reached under the given assumptions.";
    return;
end

% --- Find smallest integer n with realFV(n) >= Y ---

if i == 0
    % Closed form for zero real rate
    n = ceil(Y / K);
    iterations = 0;
else
    % Step 1: double hi until realFV(hi) >= Y
    hi = 1;
    while realFV(hi, K, i) < Y
        hi = hi * 2;
        if hi > 1e9
            error('Upper-bound search exceeded limit; check inputs.');
        end
    end
    lo = floor(hi / 2);   % invariant: realFV(lo) < Y <= realFV(hi)

    % Step 2: binary search on integers in (lo, hi]
    iterations = 0;
    while hi - lo > 1
        mid = floor((lo + hi) / 2);
        if realFV(mid, K, i) >= Y
            hi = mid;
        else
            lo = mid;
        end
        iterations = iterations + 1;
    end
    n = hi;
end

% --- Post-processing (same nominal/real treatment as Approach [1]) ---

realFV_n = realFV(n, K, i);
nominalFV_n = realFV_n * (1 + q)^(n / 12);

if q == 0
    totalNominalContrib = K * n;
else
    a = (1 + q)^(1/12);
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
result.iterations = iterations;
result.message = "Target reached.";

end

function fv = realFV(n, K, i)
% Real future value of end-of-month contributions (K is real)
if i == 0
    fv = K * n;
else
    fv = K * expm1(n * log1p(i)) / i;
end
end