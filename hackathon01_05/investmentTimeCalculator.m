function result = investmentTimeCalculator(Y, K, r, q)
%INVESTMENTTIMECALCULATOR Solve for months to reach a real target.
%   Y - target amount in today's RM (real value), Y > 0
%   K - fixed real monthly contribution, K > 0
%   r - effective annual return (decimal), r > -1
%   q - annual inflation rate (decimal), q > -1

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
end

if r <= -1, error('r must be greater than -1.'); end
if q <= -1, error('q must be greater than -1.'); end

% Real annual return (Fisher), real and nominal monthly rates
rReal = (1 + r) / (1 + q) - 1;
i = expm1( log1p(rReal) / 12 );    % real monthly rate
j = expm1( log1p(r)    / 12 );    % nominal monthly rate

tol = 1e-12;
if abs(i) < tol, i = 0; end
if abs(j) < tol, j = 0; end

result = struct( ...
    'problem', 'time', ...
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
    'inputs', struct('Y', Y, 'K', K, 'r', r, 'q', q), ...
    'message', "" );

% Feasibility: when i<0, realFV converges to K/(-i)
if i < 0 && Y >= K / (-i)
    result.feasible = false;
    result.message = "Target cannot be reached (i<0 and Y >= K/(-i)).";
    return;
end

% Closed-form guess + discrete correction
if i == 0
    n = ceil(Y / K);
else
    n = ceil( log1p(Y * i / K) / log1p(i) );
    n = max(0, n);
end
while realFV(n, K, i) < Y
    n = n + 1;
end
while n > 0 && realFV(n - 1, K, i) >= Y
    n = n - 1;
end

% Real / nominal future value
realFV_n = realFV(n, K, i);
nominalFV_n = realFV_n * (1 + q)^(n / 12);

% Total nominal contributions (K is real, so each contribution grows with q)
if q == 0
    totalNominalContrib = K * n;
else
    a = (1 + q)^(1/12);
    totalNominalContrib = K * a * (a^n - 1) / (a - 1);
end

result.months = n;
result.years  = n / 12;
result.realFutureValue    = realFV_n;
result.nominalFutureValue = nominalFV_n;
result.totalContributions = totalNominalContrib;
result.totalGain = nominalFV_n - totalNominalContrib;
result.message = "Target reached.";
end

function fv = realFV(n, K, i)
if i == 0
    fv = K * n;
else
    fv = K * expm1(n * log1p(i)) / i;
end
end