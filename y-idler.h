include <config.scad>
include <thing_libutils/attach.scad>
include <thing_libutils/pulley.scad>
include <thing_libutils/thread-data.scad>
include <thing_libutils/nut-data.scad>

yaxis_idler_conn = [[-extrusion_size/2, 0, 0], [-1,0,0]];

yidler_w = 2*yaxis_idler_pulley_inner_d;
yaxis_idler_mount_thread_dia = lookup(ThreadSize, extrusion_thread);

yaxis_idler_mount_tightscrew_dia = lookup(ThreadSize, ThreadM4);
yaxis_idler_mount_tightscrew_hexnut = NutHexM4;
yaxis_idler_mount_tightscrew_hexnut_dia = lookup(NutWidthMax, yaxis_idler_mount_tightscrew_hexnut);
yaxis_idler_mount_tightscrew_hexnut_thick = lookup(NutThickness, yaxis_idler_mount_tightscrew_hexnut);

yaxis_idler_mount_adjustscrew_hexnut = NutHexM3;
yaxis_idler_mount_adjustscrew_hexnut_dia = lookup(NutWidthMax, yaxis_idler_mount_adjustscrew_hexnut);
yaxis_idler_mount_adjustscrew_hexnut_thick = lookup(NutThickness, yaxis_idler_mount_adjustscrew_hexnut);

yaxis_idler_mount_adjustscrew_offset = Z*yaxis_idler_mount_adjustscrew_hexnut_dia;

yidler_mount_width = yidler_w+yaxis_idler_mount_thickness*2 + yaxis_idler_mount_thread_dia*3;

yaxis_idler_tightscrew_dist = 10*mm;
yaxis_idler_pulley_nut = NutHexM5;
yaxis_idler_pulley_thread = ThreadM5;
yaxis_idler_pulley_thread_dia = lookup(ThreadSize, yaxis_idler_pulley_thread);
yaxis_idler_pulleyblock_supportsize = yaxis_idler_pulley_outer_d*1.2;
yaxis_idler_pulleyblock_wallthick = 5*mm;
yaxis_idler_pulleyblock_lenfrompulley = yaxis_idler_pulleyblock_supportsize/2 + yaxis_idler_pulley_tight_len;

// the pulley block mounting point (mounting point in pulley block frame)
yaxis_idler_pulleyblock_conn = [[-yaxis_idler_pulleyblock_lenfrompulley, 0, 0], X];

yaxis_idler_pulleyblock_conn_print = [[-yaxis_idler_pulleyblock_lenfrompulley, yaxis_idler_pulleyblock_supportsize/2, 0], Y];

// the idler pulley block mounting point (mounting point in idler frame)
yaxis_idler_conn_pulleyblock = [[extrusion_size/2+yaxis_idler_mount_thickness, 0, extrusion_size/2+yaxis_belt_path_offset_z], X];

