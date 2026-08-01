function paths = export_results(projectRoot, caseData, results)
%EXPORT_RESULTS Save tables, plots and a compact HTML report.

resultsDir = fullfile(projectRoot, 'results');
reportsDir = fullfile(projectRoot, 'reports');
if ~isfolder(resultsDir), mkdir(resultsDir); end
if ~isfolder(reportsDir), mkdir(reportsDir); end

busTable = results.bus_table;
branchTable = results.branch;
convergence = results.convergence;

alertMask = busTable.VoltageStatus ~= "OK";
alerts = busTable(alertMask, {'BusID','Voltage_pu','VoltageStatus'});
if isempty(alerts)
    alerts = table(NaN, NaN, "No voltage violations", ...
        'VariableNames', {'BusID','Voltage_pu','VoltageStatus'});
end

summary = table(results.converged, results.iterations, results.final_mismatch_pu, ...
    sum(caseData.buses.Pd_MW), sum(caseData.buses.Qd_Mvar), ...
    sum(busTable.PgCalculated_MW), sum(busTable.QgCalculated_Mvar), ...
    sum(branchTable.PLoss_MW), sum(branchTable.QLoss_Mvar), ...
    min(busTable.Voltage_pu), max(busTable.Voltage_pu), sum(alertMask), ...
    'VariableNames', {'Converged','Iterations','FinalMismatch_pu', ...
    'TotalLoad_MW','TotalLoad_Mvar','TotalGeneration_MW', ...
    'TotalGeneration_Mvar','TotalActiveLoss_MW','TotalReactiveLoss_Mvar', ...
    'MinimumVoltage_pu','MaximumVoltage_pu','VoltageAlertCount'});

resultWorkbook = fullfile(resultsDir, 'power_flow_results.xlsx');
if isfile(resultWorkbook), delete(resultWorkbook); end
writetable(summary, resultWorkbook, 'Sheet', 'Summary');
writetable(busTable, resultWorkbook, 'Sheet', 'BusResults');
writetable(branchTable, resultWorkbook, 'Sheet', 'BranchResults');
writetable(convergence, resultWorkbook, 'Sheet', 'Convergence');
writetable(alerts, resultWorkbook, 'Sheet', 'VoltageAlerts');

writetable(busTable, fullfile(resultsDir, 'bus_results.csv'));
writetable(branchTable, fullfile(resultsDir, 'branch_results.csv'));
writetable(convergence, fullfile(resultsDir, 'convergence_history.csv'));

fig = figure('Name', 'Newton-Raphson Power Flow Results', ...
    'Color', 'white', 'Position', [100 100 1150 760]);
tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot(busTable.BusID, busTable.Voltage_pu, '-o', 'LineWidth', 1.4);
hold on;
yline(caseData.warningVmin, '--', 'Lower limit');
yline(caseData.warningVmax, '--', 'Upper limit');
grid on;
xlabel('Bus number'); ylabel('Voltage magnitude (p.u.)');
title('Bus Voltage Profile');

nexttile;
stem(busTable.BusID, busTable.Angle_deg, 'filled');
grid on;
xlabel('Bus number'); ylabel('Voltage angle (deg)');
title('Bus Voltage Angles');

nexttile;
semilogy(convergence.Iteration, convergence.MaxMismatch_pu, '-o', 'LineWidth', 1.4);
grid on;
xlabel('Iteration'); ylabel('Maximum mismatch (p.u.)');
title('Newton-Raphson Convergence');

nexttile;
bar(branchTable.BranchID, branchTable.PLoss_MW);
grid on;
xlabel('Branch ID'); ylabel('Active-power loss (MW)');
title('Branch Active-Power Losses');

sgtitle('IEEE 14-Bus Newton-Raphson Power Flow');
dashboardPng = fullfile(resultsDir, 'power_flow_dashboard.png');
exportgraphics(fig, dashboardPng, 'Resolution', 180);

htmlReport = fullfile(reportsDir, 'power_flow_report.html');
write_html_report(htmlReport, summary, busTable, branchTable, alerts);

paths = struct();
paths.result_workbook = resultWorkbook;
paths.dashboard_png = dashboardPng;
paths.html_report = htmlReport;
end

function write_html_report(filePath, summary, busTable, branchTable, alerts)
fid = fopen(filePath, 'w', 'n', 'UTF-8');
if fid < 0
    error('Unable to create HTML report: %s', filePath);
end
cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, ['<!doctype html><html><head><meta charset="utf-8">' ...
    '<title>Newton-Raphson Power Flow Report</title>' ...
    '<style>body{font-family:Arial,sans-serif;max-width:1100px;margin:32px auto;' ...
    'line-height:1.5;color:#1f2937}table{border-collapse:collapse;width:100%%;' ...
    'margin:16px 0}th,td{border:1px solid #d1d5db;padding:7px;text-align:right}' ...
    'th{background:#e5eef5}td:first-child,th:first-child{text-align:center}' ...
    '.ok{color:#166534}.warn{color:#b91c1c;font-weight:bold}' ...
    'img{max-width:100%%;border:1px solid #d1d5db}</style></head><body>']);
fprintf(fid, '<h1>Newton-Raphson Power Flow Report</h1>');
fprintf(fid, '<p>Independent MATLAB implementation using Excel input data.</p>');
fprintf(fid, '<h2>Summary</h2><ul>');
fprintf(fid, '<li>Converged: %s</li>', char(string(summary.Converged)));
fprintf(fid, '<li>Iterations: %d</li>', summary.Iterations);
fprintf(fid, '<li>Final mismatch: %.3e p.u.</li>', summary.FinalMismatch_pu);
fprintf(fid, '<li>Total active-power loss: %.4f MW</li>', summary.TotalActiveLoss_MW);
fprintf(fid, '<li>Voltage alerts: %d</li>', summary.VoltageAlertCount);
fprintf(fid, '</ul><img src="../results/power_flow_dashboard.png" alt="Power-flow dashboard">');

fprintf(fid, '<h2>Bus Results</h2><table><tr><th>Bus</th><th>Type</th><th>V (p.u.)</th><th>Angle (deg)</th><th>Pg (MW)</th><th>Qg (Mvar)</th><th>Status</th></tr>');
for k = 1:height(busTable)
    statusClass = 'ok';
    if busTable.VoltageStatus(k) ~= "OK", statusClass = 'warn'; end
    fprintf(fid, '<tr><td>%d</td><td>%s</td><td>%.5f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td class="%s">%s</td></tr>', ...
        busTable.BusID(k), char(busTable.BusType(k)), busTable.Voltage_pu(k), ...
        busTable.Angle_deg(k), busTable.PgCalculated_MW(k), ...
        busTable.QgCalculated_Mvar(k), statusClass, char(busTable.VoltageStatus(k)));
end
fprintf(fid, '</table>');

fprintf(fid, '<h2>Voltage Alerts</h2><table><tr><th>Bus</th><th>Voltage (p.u.)</th><th>Status</th></tr>');
for k = 1:height(alerts)
    fprintf(fid, '<tr><td>%.0f</td><td>%.5f</td><td>%s</td></tr>', ...
        alerts.BusID(k), alerts.Voltage_pu(k), char(alerts.VoltageStatus(k)));
end
fprintf(fid, '</table>');

[~, order] = sort(branchTable.PLoss_MW, 'descend');
topCount = min(8, height(branchTable));
fprintf(fid, '<h2>Largest Branch Losses</h2><table><tr><th>Branch</th><th>From</th><th>To</th><th>P loss (MW)</th><th>Q loss (Mvar)</th></tr>');
for n = 1:topCount
    k = order(n);
    fprintf(fid, '<tr><td>%d</td><td>%d</td><td>%d</td><td>%.5f</td><td>%.5f</td></tr>', ...
        branchTable.BranchID(k), branchTable.FromBus(k), branchTable.ToBus(k), ...
        branchTable.PLoss_MW(k), branchTable.QLoss_Mvar(k));
end
fprintf(fid, '</table></body></html>');
end
