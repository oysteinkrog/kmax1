// Empirical clearance probe: intersect both tool docks with the whole
// machine (docks hidden on the machine side via $tooldock_hide) at Z-min.
// The export must be EMPTY; any triangles in the STL are collisions.
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
use <../tool-dock.scad>
include <../tool-dock.h>

// bucket slide-out offset for the removal-path probe (0 = seated)
slide = 0;

module docks_world()
{
    tz(tooldock_axis_min_z)
    for(x=[-1,1])
    translate([x*(main_width/2), 0, 0])
    translate([0, xaxis_zaxis_distance_y, 0])
    translate([x*zmotor_mount_rod_offset_x, 0, 0])
    mirror([max(0,x),0,0])
    {
        $show_vit = false;
        tooldock_chassis();
        ty(-slide)
        {
            tooldock_bucket();
            tooldock_carrier();
        }
    }
}

intersection()
{
    union()
    {
        $tooldock_hide = true;
        $show_vit = false;
        main();
    }
    docks_world();
}
