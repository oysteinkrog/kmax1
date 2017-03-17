include <thing_libutils/thread-data.scad>;
include <config.scad>

psu_a_w=11.5*cm;
psu_a_d=21.5*cm;
psu_a_h=5*cm;
psu_a_screw_side_dist_z = 2.5*cm;
psu_a_screw_dist_y = 15*cm;
psu_a_screw_bottom_dist_x = 5*cm;

psu_a_screw_thread = ThreadM4;
psu_a_screw_thread_dia = lookup(ThreadSize, psu_a_screw_thread);

psu_b_w=98*mm;
psu_b_d=19.5*cm;
psu_b_h=42*mm;
psu_b_screw_offset_y = 37.5*mm-18*mm;
psu_b_screw_dist_y = 12*cm;
psu_b_screw_bottom_dist_x = 8*cm;

psu_b_screw_thread = ThreadM3;
psu_b_screw_thread_dia = lookup(ThreadSize, psu_b_screw_thread);

psu_mount_bottom_height = 4*mm;


