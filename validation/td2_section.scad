// visual section through the wiper mechanism, at the bar centerline
// (y = bar_y): tower column, seat, boss, shim stack, magnet pockets,
// bar, slot, blade all live on this plane
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

$show_vit = true;
half = 1;   // 1: keep y > bar_y (view from the front); 0: thin slab

intersection()
{
    union()
    {
        tooldock2_bucket();
        tooldock2_carrier();
    }
    if(half)
        translate([60, tooldock_bar_y, -120]) cube([90, 60, 80]);
    else
        translate([60, tooldock_bar_y - 0.5, -120]) cube([90, 1, 80]);
}
