include <thing_libutils/attach.scad>
include <config.scad>

yaxis_belt_mount_base_thick = 4;

yaxis_belt_mounthole_dist = 41;
yaxis_belt_mounthole_thread = ThreadM3;
yaxis_belt_mounthole_thread_dia = lookup(ThreadSize, yaxis_belt_mounthole_thread);

yaxis_belt_mount_width_belt = yaxis_pulley_inner_d/2;
yaxis_belt_mount_width_base = yaxis_belt_mounthole_thread_dia*3;
yaxis_belt_mount_height = 15;
yaxis_belt_mount_depth = 33;
yaxis_belt_mount_depth_base = yaxis_belt_mounthole_dist+yaxis_belt_mounthole_thread_dia*3;

yaxis_belt_mount_belt_gap = 5*mm;

yaxis_belt_mount_conn=[[0,0,yaxis_belt_mount_base_thick],Z];

