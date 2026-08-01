function caseData = load_case_from_excel(filePath)
%LOAD_CASE_FROM_EXCEL Read settings, bus data and branch data from Excel.

if ~isfile(filePath)
    error('Input workbook not found: %s', filePath);
end

settings = readtable(filePath, 'Sheet', 'Settings');
buses = readtable(filePath, 'Sheet', 'Buses');
branches = readtable(filePath, 'Sheet', 'Branches');

caseData = struct();
caseData.file_path = string(filePath);
caseData.settings = settings;
caseData.buses = buses;
caseData.branches = branches;
caseData.baseMVA = settings.BaseMVA(1);
caseData.tolerance = settings.Tolerance_pu(1);
caseData.maxIterations = settings.MaxIterations(1);
caseData.warningVmin = settings.VoltageWarningMin_pu(1);
caseData.warningVmax = settings.VoltageWarningMax_pu(1);
end
