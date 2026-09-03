use <../tool-dock.scad>
include <../tool-dock.h>
intersection()
{
    tooldock_chassis();
    translate([50, -45, -80]) cube([8, 10, 5]);
}
