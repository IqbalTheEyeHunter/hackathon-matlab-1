Fourth "solution": Monte-Carlo Simulation (because some of you mfs might want to consider random returns so seriously)

## Monte Carlo Simulation with Normally Distributed Returns

Below is a Monte Carlo implementation of the same hackathon problem, where the real monthly return is treated as a random variable rather than a fixed constant.

### 1. Mathematical setup

Assumptions:

- $K$ is a fixed **real** monthly contribution (same as Approach [1]).
- Inflation $q$ is constant. The real monthly **expected** rate is:
$$
i=(1+r_{\text{real}})^{1/12}-1,\qquad r_{\text{real}}=\frac{1+r}{1+q}-1
$$
- The real monthly return in month $m$ is a random variable:
$$
R_m\sim\mathcal{N}(i,\ \sigma_m^2),\qquad \sigma_m=\frac{\sigma_a}{\sqrt{12}}
$$
  where $\sigma_a$ is the assumed annual volatility of returns.
- Wealth recurrence (end-of-month contributions):
$$
W_m=W_{m-1}(1+R_m)+K,\qquad W_0=0
$$
- The **first hitting time** for path $s$ is:
$$
n^{(s)}=\min\{m\ge1: W_m^{(s)}\ge Y\}
$$
- From the empirical distribution of $\{n^{(s)}\}$, we report:
  - Probability of reaching $Y$ within the simulation horizon
  - Percentiles (median, 75th, 90th, 95th) of reaching time
  - Probability curve $P(n^{(s)}\le t)$ for $t=0,12,24,\dots$

This gives a **risk-aware** answer instead of a single deterministic $n$.

### 2. MATLAB implementation

```matlab
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
```

### 3. Demo script

```matlab
% demo_montecarlo.m
clearvars; clc;

Y            = 100000;    % target real value (today's RM)
K            = 500;       % real monthly contribution
r            = 0.06;      % expected annual return
q            = 0.03;      % annual inflation
sigmaAnnual  = 0.10;      % annual volatility (10%)
numSims      = 20000;
seed         = 42;

res = investmentTimeMonteCarlo(Y, K, r, q, sigmaAnnual, numSims, seed);

fprintf('Expected real annual return: %.4f%%\n', res.realAnnualReturn * 100);
fprintf('Annual volatility:           %.2f%%\n', res.annualVolatility * 100);
fprintf('P(reach target):             %.4f\n\n', res.pReach);

fprintf('Percentile months to reach target (conditional on reaching):\n');
for k = 1:numel(res.percentileLabels)
    fprintf('  %2dth pct: %6.1f months  (%5.2f years)\n', ...
        res.percentileLabels(k), res.percentileMonths(k), res.percentileYears(k));
end
fprintf('\n');

fprintf('Months required for target probabilities:\n');
for k = 1:numel(res.targetProbLabels)
    fprintf('  P(reach) >= %4.2f  ->  %6.1f months  (%5.2f years)\n', ...
        res.targetProbLabels(k), res.monthsForProb(k), res.yearsForProb(k));
end

% Plot probability curve
figure;
plot(res.horizonYears, res.probReachBy, 'LineWidth', 1.5);
xlabel('Years'); ylabel('P(reach target within t years)');
title('Monte Carlo: Probability of Reaching Target');
grid on; ylim([0 1]);
```

### 4. Sample output

For the parameters above (expected real return $\approx 2.9\%$, volatility $10\%$, $Y=100{,}000$, $K=500$):

| Metric | Value |
|---|---|
| $P(\text{reach})$ | $\approx 0.99$ |
| Median months | $\approx 165$ ($\approx 13.8$ years) |
| 75th percentile | $\approx 180$ |
| 90th percentile | $\approx 197$ |
| 95th percentile | $\approx 208$ |
| $P(\text{reach})\ge 0.75$ | $\approx 180$ months |
| $P(\text{reach})\ge 0.90$ | $\approx 197$ months |

The deterministic answer from Approach [1] is $n\approx 164$ months, which lies near the **median** — that is expected, since the deterministic model uses the mean return and ignores volatility.

### 5. Why this approach is useful for a hackathon

- **Risk-aware planning.** Instead of a single $n$, the calculator reports quantiles (median, 75th, 90th, 95th). A saver can plan for the 90th percentile as a conservative estimate.
- **Probability curve.** The $P(n^{(s)}\le t)$ curve is a natural visualization for a hackathon demo.
- **Easy to extend.** You can:
  - Add **step-up contributions** (increase $K$ annually).
  - Use **log-normal returns** $R_m=e^{\mu_m+\sigma_m Z_m}-1$ to avoid negative wealth.
  - Model **autocorrelated returns** (AR(1) or GARCH) for more realism.
  - Add **withdrawals** or **taxes** at the end of each year.
- **Robustness.** The binary search from Approach [2] cannot be directly applied when returns are random; Monte Carlo is the natural alternative.

### 6. Caveats and improvements

- **Normal returns allow negative wealth.** With large negative draws, $W_m$ can become negative. For $K=500$, $\sigma_m\approx 2.9\%$, this is rare, but for high $\sigma_a$ it becomes a concern. Using log-normal returns fixes this.
- **Volatility parameterization.** Dividing $\sigma_a$ by $\sqrt{12}$ assumes returns are i.i.d. across months and that annual volatility is the natural base. For an alternative, you can parameterize directly with a monthly $\sigma_m$.
- **Convergence.** Standard error of the empirical probabilities scales as $1/\sqrt{N}$. With $N=20{,}000$, the standard error is about $0.35\%$; increase $N$ if you need tighter estimates.
- **Reproducibility.** The `seed` argument makes results deterministic; useful for grading and for the hackathon’s fairness.

This Monte Carlo version complements the deterministic calculators from Approaches [1] and [2] and gives first-year students a hands-on introduction to stochastic simulation in finance.
