// Assembly-walkthrough views of the v2 dock, for explanation renders.
//   view=1  whole machine with the v2 dock in place (v1 docks hidden)
//   view=2  closeup of the left dock on the machine
//   view=3  dock alone, bucket half-docked (slide along y into the groove)
//   view=4  dock alone, exploded: carrier lifted off the towers
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

view = 1;
slide = 0;

// left-dock world placement (matches td2_isect_machine.scad, x=-1 leg)
module dock2_place()
{
    tz(tooldock_axis_min_z)
    translate([-(main_width/2), 0, 0])
    translate([0, xaxis_zaxis_distance_y, 0])
    translate([-zmotor_mount_rod_offset_x, 0, 0])
    children();
}

module dock2_scene(slide=0, lift=0)
{
    $show_vit = true;
    tooldock2_chassis();
    ty(-slide)
    {
        tooldock2_bucket();
        tz(lift)
        {
            tooldock2_carrier();
            tooldock2_padcarrier();
        }
    }
}

if(view==1 || view==2)
{
    union()
    {
        $tooldock_hide = true;
        $show_vit = true;
        main();
    }
    dock2_place() dock2_scene(slide=slide);
}
else if(view==3)
    dock2_scene(slide=45);
else if(view==4)
    dock2_scene(lift=22);
