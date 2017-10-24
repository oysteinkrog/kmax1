include <thing_libutils/system.scad>
include <thing_libutils/units.scad>

fan_5015S_screwpos = [[-20.15*mm,20.3*mm],[22*mm, -19.5*mm]];
fan_5015S_X = 51.2;
fan_5015S_Y = 51.2;
fan_5015S_Z = 15;
fan_5015S_output_X = 19;
fan_5015S_output_Y = 11;
fan_5015S_output_screw_Y = -6.5;
fan_5015S_output_screw_X = 9.5;

fan_5015S_conn_flowoutput = [[fan_5015S_output_X/2,-fan_5015S_output_Y,fan_5015S_Z/2],-Y];
