// docks vs the z-axis (motor mounts, addon towers, clamps, rods, motors)
// with vitamins drawn as solids. Export must be empty. Set probe_scene=true
// (-D) to draw the union instead, for a visual close-up.
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
use <../tool-dock.scad>
include <../tool-dock.h>

probe_scene = false;

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
        tooldock_bucket();
        tooldock_carrier();
    }
}

module zmotor_world()
{
    $show_vit = true;
    z_axis();
}

if(probe_scene)
{
    zmotor_world();
    docks_world();
}
else
intersection()
{
    zmotor_world();
    docks_world();
}
