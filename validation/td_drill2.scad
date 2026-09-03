// what vertical thing lives at world (-185.5, -10) between z -10 and 35?
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
include <../tool-dock.h>

intersection()
{
    union()
    {
        $show_vit = false;
        y_axis();

        tz(yaxis_rod_d/2)
        tz(-get(LinearBearingOuterDiameter,yaxis_bearing)/2)
        tz(y_plate_offset_z)
        cubea([main_width-extrusion_size*2, main_depth, 1*cm], align=-Z);
    }
    translate([-195, -30, -12]) cube([20, 45, 50]);
}
