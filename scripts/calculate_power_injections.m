function [P, Q, V] = calculate_power_injections(Ybus, Vm, Va)
%CALCULATE_POWER_INJECTIONS Calculate complex bus injections in per unit.

V = Vm .* exp(1i * Va);
S = V .* conj(Ybus * V);
P = real(S);
Q = imag(S);
end
