include <config.scad>
include <thing_libutils/system.scad>
include <thing_libutils/attach.scad>
include <thing_libutils/bearing-linear-data.scad>

yaxis_carriage_bearing_mount_bottom_thick = 3;
yaxis_carriage_bearing_mount_conn_bottom = [N, Z];
yaxis_carriage_bearing_mount_conn_bearing = [[0,0,yaxis_carriage_bearing_mount_bottom_thick+get(LinearBearingOuterDiameter,yaxis_bearing)/2], Z];

