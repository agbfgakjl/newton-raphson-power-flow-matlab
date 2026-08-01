# Newton-Raphson Power Flow Analysis in MATLAB

A compact, reproducible MATLAB project that reads bus and branch data from Excel and solves the AC power-flow equations using a from-scratch Newton-Raphson implementation.

## Features

- Excel-based bus, generator/load and branch input
- Slack, PV and PQ bus handling
- Transformer off-nominal tap ratios
- Newton-Raphson convergence history
- Bus voltage magnitude and angle results
- Calculated active/reactive generation and injections
- Bidirectional branch flows and line losses
- Voltage-limit alarms
- Excel/CSV export, dashboard plot and HTML report
- IEEE 14-bus example data

## Requirements

- MATLAB R2021a or later recommended
- No MATPOWER or Simulink installation required

## Quick Start

1. Open the repository root in MATLAB.
2. Run:

```matlab
START_HERE
```

The following files will be generated:

```text
results/power_flow_results.xlsx
results/bus_results.csv
results/branch_results.csv
results/convergence_history.csv
results/power_flow_dashboard.png
reports/power_flow_report.html
```

## Input Workbook

Edit `data/ieee14_power_flow_data.xlsx`:

- `Settings`: base MVA, tolerance, iteration limit and voltage-warning limits
- `Buses`: bus type, load, generation, initial voltage and shunt data
- `Branches`: line impedance, charging susceptance, transformer tap and status

Bus types must be `Slack`, `PV` or `PQ`.

## Expected IEEE 14-Bus Result

With the supplied workbook, the project should converge in approximately five Newton-Raphson iterations from the provided flat-start angles. The expected total active-power loss is approximately 13.39 MW. Small numerical differences can occur across MATLAB releases and spreadsheet import settings.

## Method Scope

The project performs a balanced, positive-sequence, steady-state AC power-flow calculation. It does not include optimal power flow, fault analysis, dynamic simulation, generator reactive-limit switching or unbalanced networks.

## Repository Structure

```text
newton-raphson-power-flow-matlab/
├── START_HERE.m
├── run_power_flow.m
├── data/
│   └── ieee14_power_flow_data.xlsx
├── scripts/
├── results/
├── reports/
└── docs/
```

## Data Attribution

The IEEE 14-bus values in the example workbook are derived from the public test case distributed as `case14.m` by the MATPOWER project, which states that the case was converted from the IEEE Common Data Format archive. See `docs/DATA_SOURCE.md`.
