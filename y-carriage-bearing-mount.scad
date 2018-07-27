include <config.scad>
include <thing_libutils/system.scad>
include <thing_libutils/attach.scad>
include <thing_libutils/bearing-linear-data.scad>
include <thing_libutils/materials.scad>
include <thing_libutils/screws.scad>
use <thing_libutils/bearing-linear.scad>

yaxis_carriage_bearing_mount_bottom_thick = 3;
yaxis_carriage_bearing_mount_conn_bottom = [N, Z];
yaxis_carriage_bearing_mount_conn_bearing = [[0,0,yaxis_carriage_bearing_mount_bottom_thick+get(LinearBearingOuterDiameter,yaxis_bearing)/2], Z];

module yaxis_carriage_bearing_mount(part)
{
    // x distance of holes
    screw_dx=20;
    // y distance of holes
    screw_dy=0;

    carriage_plate_thread=ThreadM3;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2.5;
    bearing_OD = get(LinearBearingOuterDiameter, yaxis_bearing);
    bearing_L = get(LinearBearingLength, yaxis_bearing);
    depth = max(bearing_L+2*mm, screw_dx+carriage_plate_thread_d*2);
    height = 5+yaxis_carriage_bearing_mount_bottom_thick;

    if(part==U)
    {
        difference()
        {
            yaxis_carriage_bearing_mount(part="pos");
            yaxis_carriage_bearing_mount(part="neg");
        }
        %yaxis_carriage_bearing_mount(part="vit");
    }
    else if(part=="pos")
    {
        material(Mat_Plastic)
        rcubea([width, depth, height], align=Z);
    }
    else if(part=="neg")
    {
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*screw_dx/2)
        ty(y*screw_dy/2)
        tz(-3*mm) 
        screw_cut(thread=carriage_plate_thread, head="button", head_embed=true, h=10*mm, align=Z, orient=-Z);

        /*cylindera(d=carriage_plate_thread_d, h=height+2, align=Z);*/

    }
    else if(part=="vit")
    {
    }

    translate([0,0,bearing_OD/2+yaxis_carriage_bearing_mount_bottom_thick])
    linear_bearing_mount(
        part=part,
        bearing=yaxis_bearing,
        ziptie_type=ziptie_type,
        ziptie_bearing_distance=ziptie_bearing_distance,
        orient=Y,
        mount_dir_align=Z
        );
}

module part_y_carriage_bearing_mount()
{
    c1=[N,Z];
    attach(c1,yaxis_carriage_bearing_mount_conn_bottom)
    {
        yaxis_carriage_bearing_mount();
    }
}
