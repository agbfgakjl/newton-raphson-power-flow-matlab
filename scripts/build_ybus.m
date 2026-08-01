function [Ybus, branchModel] = build_ybus(caseData)
%BUILD_YBUS Construct the complex bus-admittance matrix.

buses = caseData.buses;
branches = caseData.branches;
nb = height(buses);
nl = height(branches);
Ybus = complex(zeros(nb, nb));

branchModel = struct();
branchModel.FromIndex = zeros(nl,1);
branchModel.ToIndex = zeros(nl,1);
branchModel.Yff_real = zeros(nl,1);
branchModel.Yff_imag = zeros(nl,1);
branchModel.Yft_real = zeros(nl,1);
branchModel.Yft_imag = zeros(nl,1);
branchModel.Ytf_real = zeros(nl,1);
branchModel.Ytf_imag = zeros(nl,1);
branchModel.Ytt_real = zeros(nl,1);
branchModel.Ytt_imag = zeros(nl,1);
branchModel.Status = zeros(nl,1);

for k = 1:nl
    if branches.Status(k) == 0
        continue;
    end

    [~, f] = ismember(branches.FromBus(k), buses.BusID);
    [~, t] = ismember(branches.ToBus(k), buses.BusID);

    seriesAdmittance = 1 / complex(branches.R_pu(k), branches.X_pu(k));
    lineCharging = 1i * branches.B_total_pu(k) / 2;

    tapMagnitude = branches.TapRatio(k);
    if tapMagnitude == 0
        tapMagnitude = 1;
    end
    tap = tapMagnitude * exp(1i * deg2rad(branches.PhaseShift_deg(k)));

    Yff = (seriesAdmittance + lineCharging) / abs(tap)^2;
    Yft = -seriesAdmittance / conj(tap);
    Ytf = -seriesAdmittance / tap;
    Ytt = seriesAdmittance + lineCharging;

    Ybus(f,f) = Ybus(f,f) + Yff;
    Ybus(f,t) = Ybus(f,t) + Yft;
    Ybus(t,f) = Ybus(t,f) + Ytf;
    Ybus(t,t) = Ybus(t,t) + Ytt;

    branchModel.FromIndex(k) = f;
    branchModel.ToIndex(k) = t;
    branchModel.Yff_real(k) = real(Yff);
    branchModel.Yff_imag(k) = imag(Yff);
    branchModel.Yft_real(k) = real(Yft);
    branchModel.Yft_imag(k) = imag(Yft);
    branchModel.Ytf_real(k) = real(Ytf);
    branchModel.Ytf_imag(k) = imag(Ytf);
    branchModel.Ytt_real(k) = real(Ytt);
    branchModel.Ytt_imag(k) = imag(Ytt);
    branchModel.Status(k) = 1;
end

busShunt = complex(buses.Gs_MW, buses.Bs_Mvar) / caseData.baseMVA;
Ybus = Ybus + diag(busShunt);
end
