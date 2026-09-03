// v2 clearance probe: intersect both v2 docks with the whole machine
// (v1 docks hidden via $tooldock_hide) plus the x-ends' vitamins at
// Z-min. Must export EMPTY.
// slide: bucket+carrier slide-out offset for the removal-path probe.
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
use <../x-end.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

slide = 0;

module docks2_world()
{
    tz(tooldock_axis_min_z)
    for(x=[-1,1])
    translate([x*(main_width/2), 0, 0])
    translate([0, xaxis_zaxis_distance_y, 0])
    translate([x*zmotor_mount_rod_offset_x, 0, 0])
    mirror([max(0,x),0,0])
    {
        $show_vit = false;
        tooldock2_chassis();
        ty(-slide)
        {
            tooldock2_bucket();
            tooldock2_carrier();
            tooldock2_padcarrier();
        }
    }
}

// xaxis_end() draws its vitamins (z bearing, nut, rods, motor) with
// the % modifier, which CGAL ignores -- so they are added here solid,
// placed exactly as main() places the x-ends. The first test print
// collided with the z bearing's flange because of that gap.
module xend_vitamins_world()
{
    tz(tooldock_axis_min_z)
    for(x=[-1,1])
    translate([x*(main_width/2), 0, 0])
    translate([0, xaxis_zaxis_distance_y, 0])
    translate([x*zmotor_mount_rod_offset_x, 0, 0])
    mirror([max(0,x),0,0])
    xaxis_end(part="vit", with_motor=true, beltpath_index=max(0,x),
              show_motor=true, show_nut=true, show_bearings=true,
              show_rods=true);
}

intersection()
{
    union()
    {
        union()
        {
            $tooldock_hide = true;
            $show_vit = false;
            main();
        }
        xend_vitamins_world();
    }
    docks2_world();
}
