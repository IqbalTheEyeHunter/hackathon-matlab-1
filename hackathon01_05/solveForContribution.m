function result = solveForContribution(Y, T_years, r, q)
%SOLVEFORCONTRIBUTION Solve for real monthly contribution K.
%   Y       - target amount in today's RM (real value), Y > 0
%   T_years - time horizon in years, T_years > 0
%   r       - effective annual return (decimal), r > -1
%   q       - annual inflation rate (decimal), q > -1

arguments
    Y (1,1) double {mustBePositive}
    T_years (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
end
if r <= -1, error('r must be greater than -1.'); end
if q <= -1, error('q must be greater than -1.'); end

n = round(T_years * 12);
if n < 1, error('T_years must correspond to at least one month.'); end

rReal = (1 + r) / (1 + q) - 1;
i = expm1( log1p(rReal) / 12 );
if abs(i) < 1e-12, i = 0; end

result = struct( ...
    'problem', 'contribution', ...
    'feasible', true, ...
    'K', NaN, ...
    'months', n, ...
    'years', n / 12, ...
    'realMonthlyRate', i, ...
    'realAnnualReturn', rReal, ...
    'inputs', struct('Y', Y, 'T_years', T_years, 'r', r, 'q', q), ...
    'message', "" );

if i == 0
    K = Y / n;
else
    denom = expm1(n * log1p(i));
    if denom <= 0
        result.feasible = false;
        result.message = "Infeasible: negative required K.";
        return;
    end
    K = Y * i / denom;
end

if K <= 0
    result.feasible = false;
    result.message = "Infeasible: K <= 0.";
    return;
end

% Total real contributions
result.K = K;
result.totalRealContributions = K * n;
result.message = "Contribution solved.";
end