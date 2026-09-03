// Faster subset probe: docks vs frame + z-axis + y-axis + bed plate
// (everything static near the docks; x_axis toolheads excluded).
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
use <../tool-dock.scad>
include <../tool-dock.h>

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

module machine_static()
{
    translate([0,0,-main_lower_dist_z/2])
    gantry_lower();

    translate(-zaxis_rod_offset)
    ty(gantry_upper_offset_y)
    gantry_upper();

    for(x=[-1,1])
    for(y=[-1,1])
    translate([x*(main_width/2-extrusion_size/2),y*(main_depth*.6/2),0])
    mirror([x==1?0:-1,0,0])
    mirror([0,y==1?1:0,0])
    y_plate_connector();

    y_axis();
    z_axis();

    tz(yaxis_rod_d/2)
    tz(-get(LinearBearingOuterDiameter,yaxis_bearing)/2)
    tz(y_plate_offset_z)
    cubea([main_width-extrusion_size*2, main_depth, 1*cm], align=-Z);
}

intersection()
{
    union()
    {
        $show_vit = true;
        machine_static();
    }
    docks_world();
}
