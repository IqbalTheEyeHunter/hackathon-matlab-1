function result = solveForInflation(Y, K, T_years, r)
%SOLVEFORINFLATION Solve for required annual inflation q.
%   Y       - target amount in today's RM (real value), Y > 0
%   K       - fixed real monthly contribution, K > 0
%   T_years - time horizon in years, T_years > 0
%   r       - effective annual return (decimal), r > -1

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    T_years (1,1) double {mustBePositive}
    r (1,1) double
end
if r <= -1, error('r must be greater than -1.'); end

n = round(T_years * 12);
if n < 1, error('T_years must correspond to at least one month.'); end

result = struct( ...
    'problem', 'inflation', ...
    'feasible', true, ...
    'q', NaN, ...
    'months', n, ...
    'years', n / 12, ...
    'realMonthlyRate', NaN, ...
    'realAnnualReturn', NaN, ...
    'inputs', struct('Y', Y, 'K', K, 'T_years', T_years, 'r', r), ...
    'message', "" );

targetRatio = Y / K;
if targetRatio <= 1 + 1e-10
    result.feasible = false;
    result.message = sprintf( ...
        "Infeasible: Y/K = %.4f <= 1.", targetRatio);
    return;
end

if abs(targetRatio - n) < 1e-10
    i = 0;
elseif targetRatio > n
    g = @(ii) gStable(ii, n);
    iLo = 1e-10;
    iHi = 1;
    while g(iHi) < targetRatio
        iHi = iHi * 2;
        if iHi > 1e6, error('Bracketing failed.'); end
    end
    i = fzero(@(ii) g(ii) - targetRatio, [iLo, iHi]);
else
    g = @(ii) gStable(ii, n);
    iLo = -1 + 1e-6;
    iHi = -1e-10;
    i = fzero(@(ii) g(ii) - targetRatio, [iLo, iHi]);
end

rReal = expm1(12 * log1p(i));
% 1 + rReal = (1+r)/(1+q)  ->  q = (1+r)/(1+rReal) - 1
q = (1 + r) / (1 + rReal) - 1;

if q <= -1
    result.feasible = false;
    result.message = "Infeasible: required q <= -1.";
    return;
end

result.q = q;
result.realMonthlyRate = i;
result.realAnnualReturn = rReal;
result.message = "Inflation solved.";
end

% -------------------------------------------------------------------------
function v = gStable(i, n)
%GSTABLE Stable evaluation of g(i) = ((1+i)^n - 1) / i with g(0) = n.
if abs(i) < 1e-12
    v = n;
else
    v = expm1(n * log1p(i)) / i;
end
end