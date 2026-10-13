function result = solveForReturn(Y, K, T_years, q)
%SOLVEFORRETURN Solve for required annual return r.
%   Y       - target amount in today's RM (real value), Y > 0
%   K       - fixed real monthly contribution, K > 0
%   T_years - time horizon in years, T_years > 0
%   q       - annual inflation rate (decimal), q > -1

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    T_years (1,1) double {mustBePositive}
    q (1,1) double
end
if q <= -1, error('q must be greater than -1.'); end

n = round(T_years * 12);
if n < 1, error('T_years must correspond to at least one month.'); end

result = struct( ...
    'problem', 'return', ...
    'feasible', true, ...
    'r', NaN, ...
    'months', n, ...
    'years', n / 12, ...
    'realMonthlyRate', NaN, ...
    'realAnnualReturn', NaN, ...
    'inputs', struct('Y', Y, 'K', K, 'T_years', T_years, 'q', q), ...
    'message', "" );

targetRatio = Y / K;   % required g(i)

% g(i) -> 1 as i -> -1+, so ratios <= 1 are unreachable
if targetRatio <= 1 + 1e-10
    result.feasible = false;
    result.message = sprintf( ...
        "Infeasible: Y/K = %.4f <= 1 (target below total real contributions).", ...
        targetRatio);
    return;
end

% Trivial case: targetRatio == n  ->  i = 0 exactly
if abs(targetRatio - n) < 1e-10
    i = 0;
elseif targetRatio > n
    % i > 0 branch
    g = @(ii) gStable(ii, n);
    iLo = 1e-10;            % avoid the 0/0 singularity at ii = 0
    iHi = 1;
    while g(iHi) < targetRatio
        iHi = iHi * 2;
        if iHi > 1e6
            error('Bracketing failed for solveForReturn.');
        end
    end
    i = fzero(@(ii) g(ii) - targetRatio, [iLo, iHi]);
else
    % 1 < targetRatio < n  ->  i in (-1, 0)
    g = @(ii) gStable(ii, n);
    iLo = -1 + 1e-6;
    iHi = -1e-10;           % avoid ii = 0 from the negative side
    i = fzero(@(ii) g(ii) - targetRatio, [iLo, iHi]);
end

rReal = expm1(12 * log1p(i));       % (1+i)^12 - 1
r = (1 + q) * (1 + rReal) - 1;

if r <= -1
    result.feasible = false;
    result.message = "Infeasible: required r <= -1.";
    return;
end

result.r = r;
result.realMonthlyRate = i;
result.realAnnualReturn = rReal;
result.message = "Return solved.";
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