% investmentTimeMonteCarlo.m
function result = investmentTimeMonteCarlo(Y, K, r, q, sigmaAnnual, numSims, seed)
%INVESTMENTTIMEMONTECARLO Monte Carlo estimate of time to reach a real target.
%
% Inputs:
%   Y            - target amount in today's RM (real value), Y > 0
%   K            - fixed real monthly contribution, K > 0
%   r            - expected effective annual return (decimal), r > -1
%   q            - annual inflation rate (decimal), q > -1
%   sigmaAnnual  - annual volatility of returns (decimal), sigmaAnnual >= 0
%   numSims      - number of Monte Carlo paths, numSims >= 100 (default 10000)
%   seed         - (optional) RNG seed (default 42)
%
% Output:
%   result - struct with percentiles, probability curve, and diagnostics
%
% Assumptions:
%   - Real monthly returns are i.i.d. N(i, sigmaM^2) with i = real monthly
%     expected return and sigmaM = sigmaAnnual / sqrt(12).
%   - Contributions are made at the end of each month and are real
%     (i.e., they preserve their purchasing power).
%   - The simulation uses simple returns rather than log returns; for a
%     hackathon this is adequate, but note that W_m can become negative if
%     a large negative return occurs. A log-normal alternative is safer
%     for high-volatility regimes.

arguments
    Y (1,1) double {mustBePositive}
    K (1,1) double {mustBePositive}
    r (1,1) double
    q (1,1) double
    sigmaAnnual (1,1) double {mustBeNonnegative}
    numSims (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(numSims, 100)} = 10000
    seed (1,1) double = 42
end

if r <= -1 || q <= -1
    error('r and q must be greater than -1.');
end

rng(seed);

% Expected real annual/monthly rates
rReal  = (1 + r) / (1 + q) - 1;
i      = expm1( log1p(rReal) / 12 );   % expected real monthly rate
sigmaM = sigmaAnnual / sqrt(12);        % monthly volatility

% --- Determine simulation horizon ---
if i > 1e-12
    nDet = log1p(Y * i / K) / log1p(i);   % deterministic estimate
    maxMonths = max(ceil(nDet * 5), 600);
else
    maxMonths = 1200;   % 100 years when drift is non-positive
end
maxMonths = min(maxMonths, 2400);   % cap at 200 years

% --- Simulate paths ---
wealth          = zeros(numSims, 1);
monthsToReach   = NaN(numSims, 1);   % NaN = not yet reached
R               = i + sigmaM * randn(numSims, maxMonths);   % pre-draw

for m = 1:maxMonths
    wealth = (wealth + K) .* (1 + R(:, m));
    newlyReached = isnan(monthsToReach) & (wealth >= Y);
    monthsToReach(newlyReached) = m;
    if all(~isnan(monthsToReach))
        break;   % everyone has reached; remaining months are irrelevant
    end
end

% --- Aggregate ---
reachedMask  = ~isnan(monthsToReach);
pReach       = mean(reachedMask);
validMonths  = monthsToReach(reachedMask);

result = struct();
result.feasible           = pReach > 0;
result.pReach             = pReach;
result.numSims            = numSims;
result.maxMonths          = maxMonths;
result.realMonthlyRate    = i;
result.realAnnualReturn   = rReal;
result.monthlyVolatility  = sigmaM;
result.annualVolatility   = sigmaAnnual;

if isempty(validMonths)
    result.message = "No simulation reached the target within maxMonths.";
    return;
end

% --- Percentiles of reaching time (conditional on reaching) ---
pcts                    = [10 25 50 75 90 95];
result.percentileLabels = pcts;
result.percentileMonths = arrayfun(@(p) localPercentile(validMonths, p), pcts);
result.percentileYears  = result.percentileMonths / 12;
result.meanMonths       = mean(validMonths);
result.medianMonths     = median(validMonths);
result.stdMonths        = std(validMonths);

% --- Probability of reaching within t months (unconditional) ---
horizonMonths        = 0:12:maxMonths;
probCurve            = arrayfun(@(t) mean(monthsToReach <= t), horizonMonths);
result.horizonYears  = horizonMonths / 12;
result.probReachBy   = probCurve;

% --- Months required for target probabilities ---
targetProbs                = [0.50 0.75 0.90 0.95];
result.targetProbLabels    = targetProbs;
result.monthsForProb       = NaN(size(targetProbs));
for k = 1:numel(targetProbs)
    idx = find(probCurve >= targetProbs(k), 1, 'first');
    if ~isempty(idx)
        result.monthsForProb(k) = horizonMonths(idx);
    end
end
result.yearsForProb = result.monthsForProb / 12;

result.message = "Monte Carlo simulation complete.";
end

% -------------------------------------------------------------------------
function v = localPercentile(x, p)
%LOCALPERCENTILE Linear-interpolated percentile without toolbox dependency.
x = sort(x(:));
n = numel(x);
if n == 0
    v = NaN; return;
end
idx = (p / 100) * (n - 1) + 1;
lo  = floor(idx);
hi  = ceil(idx);
v   = x(lo) + (idx - lo) * (x(hi) - x(lo));
end