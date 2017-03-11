include <thing_libutils/system.scad>
include <thing_libutils/attach.scad>
include <config.scad>
use <thing_libutils/bearing.scad>

yaxis_carriage_bearing_mount_bottom_thick = 3;
yaxis_carriage_bearing_mount_conn_bottom = [N, Z];
yaxis_carriage_bearing_mount_conn_bearing = [[0,0,yaxis_carriage_bearing_mount_bottom_thick+yaxis_bearing[1]/2], Z];

module yaxis_carriage_bearing_mount(show_bearing=false)
{
    // x distance of holes
    screw_dx=28;
    // y distance of holes
    screw_dy=21;

    carriage_plate_thread=ThreadM4;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2;
    depth = max(yaxis_bearing[1], screw_dx+carriage_plate_thread_d*2);
    /*height = yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick;*/
    height = 5+yaxis_carriage_bearing_mount_bottom_thick;

    difference()
    {
        union()
        {
            rcubea ([width, depth, height], align=Z);
        }

        translate ([+screw_dx/2, +screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);
        translate ([+screw_dx/2, -screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);
        translate ([-screw_dx/2, +screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);
        translate ([-screw_dx/2, -screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);

        translate([0,0,yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick])
        bearing_mount_holes(
            bearing_type=yaxis_bearing,
            ziptie_type=ziptie_type,
            ziptie_bearing_distance=ziptie_bearing_distance,
            orient=Y,
            ziptie_dist=4
            );
    }

    %if(show_bearing)
    {
        translate([0,0,yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick])
        bearing(yaxis_bearing, orient=Y);
    }
}

module part_y_carriage_bearing_mount()
{
    c1=[N,Z];
    attach(c1,yaxis_carriage_bearing_mount_conn_bottom)
    {
        yaxis_carriage_bearing_mount();
    }
}
