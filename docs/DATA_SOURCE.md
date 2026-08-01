# IEEE 14-Bus Data Source

The example workbook uses values derived from MATPOWER's official `case14.m` file:

- https://github.com/MATPOWER/matpower/blob/master/data/case14.m
- https://matpower.org/docs/ref/matpower5.0/case14.html

MATPOWER describes the file as power-flow data for the IEEE 14-bus test case and notes that it was converted from IEEE Common Data Format data originating from the University of Washington archive.

The Newton-Raphson solver in this repository is an independent implementation and does not call MATPOWER.
