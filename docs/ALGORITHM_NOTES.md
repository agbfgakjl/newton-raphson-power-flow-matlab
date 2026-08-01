# Algorithm Notes

The solver uses the polar-form AC power-flow equations:

- Active-power mismatch equations for every non-slack bus
- Reactive-power mismatch equations for PQ buses
- Voltage-angle corrections for all non-slack buses
- Voltage-magnitude corrections for PQ buses

The Jacobian is assembled as four blocks:

```text
J = [dP/dTheta   dP/dV
     dQ/dTheta   dQ/dV]
```

At every iteration, the code:

1. calculates bus active/reactive injections from `S = V .* conj(Ybus * V)`;
2. forms the active/reactive mismatch vector;
3. constructs the Newton-Raphson Jacobian;
4. solves for voltage-angle and PQ-voltage corrections;
5. stops when the largest absolute mismatch is below the Excel tolerance.

The branch-flow calculation uses the same pi-equivalent and transformer-tap model used to assemble the bus-admittance matrix.
