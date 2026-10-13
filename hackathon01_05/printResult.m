function printResult(result)
%PRINTRESULT Pretty-print an investment-calculator result struct.

fprintf('\n=== Investment Calculator Result ===\n');
fprintf('Problem type:  %s\n', result.problem);

if isfield(result, 'inputs')
    in = result.inputs;
    fields = fieldnames(in);
    fprintf('Inputs:\n');
    for k = 1:numel(fields)
        fprintf('  %-12s = %g\n', fields{k}, in.(fields{k}));
    end
end

if ~result.feasible
    fprintf('Feasibility:   INFEASIBLE\n');
    fprintf('Message:       %s\n\n', result.message);
    return;
end

fprintf('Feasibility:   OK\n');
fprintf('Message:       %s\n', result.message);

switch result.problem
    case 'time'
        fprintf('Months:        %d\n', result.months);
        fprintf('Years:         %.4f\n', result.years);
        fprintf('Real FV:       RM %.2f\n', result.realFutureValue);
        fprintf('Nominal FV:    RM %.2f\n', result.nominalFutureValue);
        fprintf('Total nominal contributions: RM %.2f\n', result.totalContributions);
        fprintf('Nominal gain:  RM %.2f\n', result.totalGain);
        fprintf('Real monthly rate:   %.6f%%\n', result.realMonthlyRate * 100);
        fprintf('Real annual return:  %.4f%%\n', result.realAnnualReturn * 100);
    case 'contribution'
        fprintf('Required real monthly K:  RM %.2f\n', result.K);
        fprintf('Total real contributions: RM %.2f\n', result.totalRealContributions);
        fprintf('Months:                   %d\n', result.months);
        fprintf('Real monthly rate:        %.6f%%\n', result.realMonthlyRate * 100);
    case 'return'
        fprintf('Required annual return r: %.4f%%\n', result.r * 100);
        fprintf('Required real annual r:   %.4f%%\n', result.realAnnualReturn * 100);
        fprintf('Required real monthly i:  %.6f%%\n', result.realMonthlyRate * 100);
    case 'inflation'
        fprintf('Required annual inflation q: %.4f%%\n', result.q * 100);
        fprintf('Implied real annual return:  %.4f%%\n', result.realAnnualReturn * 100);
        fprintf('Implied real monthly rate:   %.6f%%\n', result.realMonthlyRate * 100);
end
fprintf('\n');
end