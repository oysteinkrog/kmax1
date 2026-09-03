// Mount inspection view: chassis + bucket cut by a thin y-slab
// through the front dovetail (y=-55), optionally exploded.
// explode: 0 seated, 1 bucket shifted +x/+z to show the profiles.
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

explode = 0;

intersection()
{
    union()
    {
        $show_vit = false;
        color([0.85, 0.65, 0.35]) tooldock2_chassis();
        translate(explode > 0 ? [4, 0, 2] : [0, 0, 0])
        color([0.45, 0.6, 0.8]) tooldock2_bucket();
    }
    translate([60, -57, -110])
    cube([40, 4, 60]);
}
