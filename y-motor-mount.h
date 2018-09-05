include <config.scad>
include <thing_libutils/pulley.scad>
include <thing_libutils/stepper.scad>

ymotor_w = lookup(NemaSideSize, yaxis_motor);
ymotor_h = lookup(NemaLengthLong, yaxis_motor);

yaxis_motor_mount_motor_offset =
    -X*ymotor_w/2
    +Z*extrusion_size/2
    +Z*yaxis_belt_path_offset.z
    +Y*(yaxis_pulley_h_full)
    ;

echo(yaxis_pulley_h_full, yaxis_pulley_h);


yaxis_motor_mount_conn = [[0,0,0],X];
yaxis_motor_mount_conn_motor = [yaxis_motor_mount_motor_offset,Y];

ymotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
ymotor_mount_h = main_lower_dist_z+extrusion_size+yaxis_motor_mount_motor_offset.z;
ymotor_mount_width = ymotor_w+ymotor_mount_thickness*2 + ymotor_mount_thread_dia*8;

yaxis_motor_pulley_h = 17.5*mm;
yaxis_motor_mount_bearing_clamp_offset_z = yaxis_motor_pulley_h;

