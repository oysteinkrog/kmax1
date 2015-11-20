use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;


module belt_path(len=200, belt_width=6, pulley_d=10, align=[0,0,0], orient=[0,0,1])
{
    belt=tGT2_2;
    size_align(size=[pulley_d, belt_width, len], align=align, orient=orient)
    orient([1,0,0])
    orient([0,1,0])
    translate([-len/2, -pulley_d/2, 0])
    {
        belt_len(belt, belt_width, len);
        translate([len,pulley_d,0]) rotate([0,0,180]) belt_len(belt, belt_width, len);
        translate([0,pulley_d,0]) rotate([0,0,180]) belt_angle(belt, pulley_d/2, belt_width, 180);
        translate([len,0,0]) rotate([0,0,0]) belt_angle(belt, pulley_d/2 ,belt_width,180);
    }
}

