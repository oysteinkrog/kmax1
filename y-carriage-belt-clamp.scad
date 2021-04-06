include <y-carriage-belt-clamp.h>
use <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>

module yaxis_belt_holder(part)
{
    if(part==U)
    {
        difference()
        {
            yaxis_belt_holder(part="pos");
            yaxis_belt_holder(part="neg");
        }
        %yaxis_belt_holder(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        // base (screws etc)
        rcubea([yaxis_belt_mount_width_base,yaxis_belt_mount_depth_base,yaxis_belt_mount_base_thick], align=Z);

        // for belt attachment
        rcubea([yaxis_belt_mount_width_belt,yaxis_belt_mount_depth,yaxis_belt_mount_height], align=-Z, extra_size=Z*yaxis_belt_mount_base_thick, extra_align=Z);

        /*intersection()*/
        /*{*/
            /*hull()*/
            /*{*/
                /*// base (screws etc)*/
                /*rcubea([yaxis_belt_mount_width_base,yaxis_belt_mount_depth_base,yaxis_belt_mount_base_thick], align=Z);*/

                /*// for belt attachment*/
                /*rcubea([yaxis_belt_mount_width_belt,yaxis_belt_mount_depth,yaxis_belt_mount_height], align=-Z);*/
            /*}*/

            /*// for belt attachment*/
            /*rcubea([yaxis_belt_mount_width_belt,1000,yaxis_belt_mount_height], align=-Z);*/
        /*}*/
    }
    else if(part=="neg")
    {
        // for belt attachment
        rcubea([yaxis_belt_mount_width_base*2,yaxis_belt_mount_belt_gap,yaxis_belt_mount_height+1], align=-Z);

        for(y=[-1,1])
        translate(Y*y*yaxis_belt_mounthole_dist/2)
        screw_cut(nut=yaxis_belt_mounthole_nut, orient=Z, align=Z);

        tx(1*mm)
        cylindera(d=8*mm, h=100, orient=Z);
    }
}

module part_y_carriage_belt_holder()
{
    conn = [N,-Z];
    attach(conn, yaxis_belt_mount_conn)
    {
        yaxis_belt_holder();
    }
}

yaxis_belt_holder();
