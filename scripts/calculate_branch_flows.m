function branchTable = calculate_branch_flows(caseData, results, branchModel)
%CALCULATE_BRANCH_FLOWS Calculate from-end, to-end and loss powers.

branches = caseData.branches;
V = results.V;
baseMVA = caseData.baseMVA;
nl = height(branches);

PFrom = zeros(nl,1);
QFrom = zeros(nl,1);
PTo = zeros(nl,1);
QTo = zeros(nl,1);
PLoss = zeros(nl,1);
QLoss = zeros(nl,1);

for k = 1:nl
    if branchModel.Status(k) == 0
        continue;
    end

    f = branchModel.FromIndex(k);
    t = branchModel.ToIndex(k);
    Yff = complex(branchModel.Yff_real(k), branchModel.Yff_imag(k));
    Yft = complex(branchModel.Yft_real(k), branchModel.Yft_imag(k));
    Ytf = complex(branchModel.Ytf_real(k), branchModel.Ytf_imag(k));
    Ytt = complex(branchModel.Ytt_real(k), branchModel.Ytt_imag(k));

    currentFrom = Yff * V(f) + Yft * V(t);
    currentTo = Ytf * V(f) + Ytt * V(t);
    powerFrom = V(f) * conj(currentFrom) * baseMVA;
    powerTo = V(t) * conj(currentTo) * baseMVA;
    loss = powerFrom + powerTo;

    PFrom(k) = real(powerFrom);
    QFrom(k) = imag(powerFrom);
    PTo(k) = real(powerTo);
    QTo(k) = imag(powerTo);
    PLoss(k) = real(loss);
    QLoss(k) = imag(loss);
end

branchIDs = reshape(1:nl, [], 1);
branchTable = table(branchIDs, branches.FromBus, branches.ToBus, ...
    PFrom, QFrom, PTo, QTo, PLoss, QLoss, ...
    'VariableNames', {'BranchID','FromBus','ToBus','PFrom_MW','QFrom_Mvar', ...
    'PTo_MW','QTo_Mvar','PLoss_MW','QLoss_Mvar'});
end
