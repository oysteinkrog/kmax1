include <config.scad>
include <thing_libutils/system.scad>
include <thing_libutils/attach.scad>
include <thing_libutils/bearing-linear-data.scad>
use <thing_libutils/bearing-linear.scad>

yaxis_carriage_bearing_mount_bottom_thick = 3;
yaxis_carriage_bearing_mount_conn_bottom = [N, Z];
yaxis_carriage_bearing_mount_conn_bearing = [[0,0,yaxis_carriage_bearing_mount_bottom_thick+get(LinearBearingOuterDiameter,yaxis_bearing)/2], Z];

module yaxis_carriage_bearing_mount(part)
{
    // x distance of holes
    screw_dx=28;
    // y distance of holes
    screw_dy=21;

    carriage_plate_thread=ThreadM4;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2;
    bearing_OD = get(LinearBearingOuterDiameter, yaxis_bearing);
    depth = max(bearing_OD, screw_dx+carriage_plate_thread_d*2);
    height = 5+yaxis_carriage_bearing_mount_bottom_thick;

    if(part==U)
    {
        difference()
        {
            yaxis_carriage_bearing_mount(part="pos");
            yaxis_carriage_bearing_mount(part="neg");
        }
    }
    else if(part=="pos")
    {
        rcubea ([width, depth, height], align=Z);
    }
    else if(part=="neg")
    {
        for(x=[-1,1])
        for(y=[-1,1])
        translate ([x*screw_dx/2, y*screw_dy/2, -1]) 
        cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);

        translate([0,0,bearing_OD/2+yaxis_carriage_bearing_mount_bottom_thick])
        linear_bearing_mount(
            bearing=yaxis_bearing,
            ziptie_type=ziptie_type,
            ziptie_bearing_distance=ziptie_bearing_distance,
            orient=Y,
            ziptie_dist=4
            );
    }
    else if(part=="vit")
    {
        translate([0,0,bearing_OD/2+yaxis_carriage_bearing_mount_bottom_thick])
        linear_bearing(yaxis_bearing, orient=Y);
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
