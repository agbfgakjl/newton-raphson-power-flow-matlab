function results = run_power_flow(inputFile)
%RUN_POWER_FLOW Run an Excel-driven Newton-Raphson AC power-flow study.
%
%   results = RUN_POWER_FLOW()
%   results = RUN_POWER_FLOW(inputFile)
%
% The solver is implemented from first principles and does not require
% MATPOWER or Simulink.

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'scripts'));

if nargin < 1 || strlength(string(inputFile)) == 0
    inputFile = fullfile(projectRoot, 'data', 'ieee14_power_flow_data.xlsx');
end

fprintf('\nLoading input workbook:\n  %s\n', inputFile);
caseData = load_case_from_excel(inputFile);
validate_input_data(caseData);

[Ybus, branchModel] = build_ybus(caseData);
results = newton_raphson_power_flow(caseData, Ybus);
results.branch = calculate_branch_flows(caseData, results, branchModel);

outputPaths = export_results(projectRoot, caseData, results);
results.output_paths = outputPaths;

fprintf('\nPower flow converged in %d iterations.\n', results.iterations);
fprintf('Maximum final mismatch: %.3e p.u.\n', results.final_mismatch_pu);
fprintf('Total active-power loss: %.4f MW\n', sum(results.branch.PLoss_MW));
fprintf('Total reactive-power loss: %.4f Mvar\n', sum(results.branch.QLoss_Mvar));

fprintf('\nBus results:\n');
disp(results.bus_table(:, {'BusID','BusType','Voltage_pu','Angle_deg', ...
    'PgCalculated_MW','QgCalculated_Mvar','VoltageStatus'}));

fprintf('Generated result workbook:\n  %s\n', outputPaths.result_workbook);
fprintf('Generated HTML report:\n  %s\n', outputPaths.html_report);
fprintf('Generated dashboard image:\n  %s\n\n', outputPaths.dashboard_png);
end
