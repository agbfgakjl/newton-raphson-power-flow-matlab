function results = newton_raphson_power_flow(caseData, Ybus)
%NEWTON_RAPHSON_POWER_FLOW Solve the AC power-flow equations in polar form.

buses = caseData.buses;
nb = height(buses);
busTypes = upper(strtrim(string(buses.BusType)));

slack = find(busTypes == "SLACK");
pv = find(busTypes == "PV");
pq = find(busTypes == "PQ");
nonSlack = find(busTypes ~= "SLACK");

Vm = buses.VmInitial_pu;
Va = deg2rad(buses.VaInitial_deg);

Pspecified = (buses.Pg_MW - buses.Pd_MW) / caseData.baseMVA;
Qspecified = (buses.Qg_Mvar - buses.Qd_Mvar) / caseData.baseMVA;

G = real(Ybus);
B = imag(Ybus);
convergence = zeros(caseData.maxIterations, 2);
converged = false;

for iteration = 1:caseData.maxIterations
    [P, Q] = calculate_power_injections(Ybus, Vm, Va);

    mismatch = [Pspecified(nonSlack) - P(nonSlack); ...
                Qspecified(pq) - Q(pq)];
    maxMismatch = max(abs(mismatch));
    convergence(iteration,:) = [iteration, maxMismatch];

    if maxMismatch < caseData.tolerance
        converged = true;
        break;
    end

    nAngle = numel(nonSlack);
    nVoltage = numel(pq);
    H = zeros(nAngle, nAngle);
    N = zeros(nAngle, nVoltage);
    M = zeros(nVoltage, nAngle);
    L = zeros(nVoltage, nVoltage);

    for row = 1:nAngle
        i = nonSlack(row);
        for col = 1:nAngle
            j = nonSlack(col);
            if i == j
                H(row,col) = -Q(i) - B(i,i) * Vm(i)^2;
            else
                theta = Va(i) - Va(j);
                H(row,col) = Vm(i) * Vm(j) * ...
                    (G(i,j) * sin(theta) - B(i,j) * cos(theta));
            end
        end

        for col = 1:nVoltage
            j = pq(col);
            if i == j
                N(row,col) = P(i) / Vm(i) + G(i,i) * Vm(i);
            else
                theta = Va(i) - Va(j);
                N(row,col) = Vm(i) * ...
                    (G(i,j) * cos(theta) + B(i,j) * sin(theta));
            end
        end
    end

    for row = 1:nVoltage
        i = pq(row);
        for col = 1:nAngle
            j = nonSlack(col);
            if i == j
                M(row,col) = P(i) - G(i,i) * Vm(i)^2;
            else
                theta = Va(i) - Va(j);
                M(row,col) = -Vm(i) * Vm(j) * ...
                    (G(i,j) * cos(theta) + B(i,j) * sin(theta));
            end
        end

        for col = 1:nVoltage
            j = pq(col);
            if i == j
                L(row,col) = Q(i) / Vm(i) - B(i,i) * Vm(i);
            else
                theta = Va(i) - Va(j);
                L(row,col) = Vm(i) * ...
                    (G(i,j) * sin(theta) - B(i,j) * cos(theta));
            end
        end
    end

    Jacobian = [H N; M L];
    if rcond(Jacobian) < 1e-14
        error('Jacobian is numerically singular at iteration %d.', iteration);
    end

    correction = Jacobian \ mismatch;
    Va(nonSlack) = Va(nonSlack) + correction(1:nAngle);
    Vm(pq) = Vm(pq) + correction(nAngle+1:end);

    if any(Vm <= 0)
        error('A non-positive voltage magnitude occurred at iteration %d.', iteration);
    end
end

if ~converged
    error('Power flow did not converge within %d iterations. Final mismatch: %.3e p.u.', ...
        caseData.maxIterations, maxMismatch);
end

[P, Q, V] = calculate_power_injections(Ybus, Vm, Va);
convergence = convergence(1:iteration,:);

PgCalculated = P * caseData.baseMVA + buses.Pd_MW;
QgCalculated = Q * caseData.baseMVA + buses.Qd_Mvar;
voltageStatus = repmat("OK", nb, 1);
voltageStatus(Vm < caseData.warningVmin) = "LOW";
voltageStatus(Vm > caseData.warningVmax) = "HIGH";

busTable = table(buses.BusID, busTypes, Vm, rad2deg(Va), ...
    P * caseData.baseMVA, Q * caseData.baseMVA, ...
    PgCalculated, QgCalculated, buses.Pd_MW, buses.Qd_Mvar, voltageStatus, ...
    'VariableNames', {'BusID','BusType','Voltage_pu','Angle_deg', ...
    'PInjection_MW','QInjection_Mvar','PgCalculated_MW', ...
    'QgCalculated_Mvar','Pd_MW','Qd_Mvar','VoltageStatus'});

results = struct();
results.converged = converged;
results.iterations = iteration;
results.final_mismatch_pu = maxMismatch;
results.Vm = Vm;
results.Va_rad = Va;
results.V = V;
results.P_pu = P;
results.Q_pu = Q;
results.slack_index = slack;
results.pv_indices = pv;
results.pq_indices = pq;
results.convergence = array2table(convergence, ...
    'VariableNames', {'Iteration','MaxMismatch_pu'});
results.bus_table = busTable;
end
