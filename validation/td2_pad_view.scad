// Pad view: v2 bucket with the pad carrier seated (cast shown), plus
// the pad carrier alone beside it. Camera from inboard/above shows the
// cup standing in the wall window.
// alone=1: carrier only. cast=0: hide the cast (see the cavity).
// sect=1: 2-thick y-slab through the park point (x-z section of the
// cup, the wall window and the bar).
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

alone = 0;
cast = 1;
sect = 0;
sy = tooldock_park.y;   // section slab centre (y)

module scene()
{
    if(alone)
    {
        $show_vit = cast ? true : false;
        tooldock2_padcarrier();
    }
    else
    {
        $show_vit = cast ? true : false;
        color([0.85, 0.65, 0.35]) tooldock2_bucket();
        color([0.45, 0.6, 0.8]) tooldock2_padcarrier();
    }
}

if(sect)
intersection()
{
    scene();
    translate([60, sy - 1, -110]) cube([50, 2, 60]);
}
else scene();
