// what part of the parked toolhead / x-end hangs into the plate band?
// left side, world coords
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
include <../tool-dock.h>

intersection()
{
    union()
    {
        $tooldock_hide = true;
        $show_vit = false;
        x_axis();
    }
    translate([-225, -50, 30]) cube([20, 65, 30]);
}
