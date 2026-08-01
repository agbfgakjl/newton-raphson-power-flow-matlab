function validate_input_data(caseData)
%VALIDATE_INPUT_DATA Perform compact, readable input checks.

buses = caseData.buses;
branches = caseData.branches;

requiredBusColumns = ["BusID","BusType","Pd_MW","Qd_Mvar","Pg_MW", ...
    "Qg_Mvar","VmInitial_pu","VaInitial_deg","Gs_MW","Bs_Mvar"];
requiredBranchColumns = ["FromBus","ToBus","R_pu","X_pu","B_total_pu", ...
    "TapRatio","PhaseShift_deg","Status"];

missingBus = setdiff(requiredBusColumns, string(buses.Properties.VariableNames));
missingBranch = setdiff(requiredBranchColumns, string(branches.Properties.VariableNames));
if ~isempty(missingBus)
    error('Buses sheet is missing columns: %s', strjoin(missingBus, ', '));
end
if ~isempty(missingBranch)
    error('Branches sheet is missing columns: %s', strjoin(missingBranch, ', '));
end

busIDs = buses.BusID;
if numel(unique(busIDs)) ~= height(buses)
    error('Every BusID must be unique.');
end

busTypes = upper(strtrim(string(buses.BusType)));
validTypes = ismember(busTypes, ["SLACK","PV","PQ"]);
if ~all(validTypes)
    badRows = find(~validTypes);
    error('Invalid BusType in row(s): %s. Use Slack, PV or PQ.', ...
        strjoin(string(badRows), ', '));
end
if sum(busTypes == "SLACK") ~= 1
    error('Exactly one Slack bus is required.');
end

[foundFrom, ~] = ismember(branches.FromBus, busIDs);
[foundTo, ~] = ismember(branches.ToBus, busIDs);
if ~all(foundFrom & foundTo)
    error('Every branch endpoint must reference an existing BusID.');
end

active = branches.Status ~= 0;
invalidImpedance = active & branches.R_pu == 0 & branches.X_pu == 0;
if any(invalidImpedance)
    error('An in-service branch cannot have both R_pu and X_pu equal to zero.');
end

if caseData.baseMVA <= 0 || caseData.tolerance <= 0 || caseData.maxIterations < 1
    error('Settings values must be positive.');
end

fprintf('Input validation passed: %d buses, %d branches.\n', ...
    height(buses), height(branches));
end
