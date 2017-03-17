include <MCAD/stepper.scad>
include <MCAD/motors.scad>
include <config.scad>
include <thing_libutils/pulley.scad>

yaxis_motor_mount_conn = [[0,0,+extrusion_size/2+yaxis_motor_offset_z],X];
yaxis_motor_mount_conn_motor = [[+yaxis_motor_offset_x, 0,+extrusion_size/2+yaxis_motor_offset_z],Z];

ymotor_w = lookup(NemaSideSize, yaxis_motor);
ymotor_h = lookup(NemaLengthLong, yaxis_motor);
ymotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
ymotor_mount_h = main_lower_dist_z+extrusion_size+yaxis_motor_offset_z;
ymotor_mount_width = ymotor_w+ymotor_mount_thickness*2 + ymotor_mount_thread_dia*8;

yaxis_motor_pulley_h = 17.5*mm;
yaxis_motor_mount_bearing_clamp_offset_z = yaxis_motor_pulley_h;

