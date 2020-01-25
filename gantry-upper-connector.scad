include <config.scad>
include <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>
use <rod-clamps.scad>

module gantry_upper_connector(part)
{
    // how much bigger/smaller is the upper gantry (on each side)
    upper_gantry_width_diff  = (main_upper_width-main_width)/2;
    if(part==U)
    {
        difference()
        {
            gantry_upper_connector("pos");
            gantry_upper_connector("neg");
        }
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        union()
        {
            hull()
            {
                // attach to z rod
                t(zaxis_rod_offset)
                tx(-upper_gantry_width_diff)
                tx(zmotor_mount_rod_offset_x)
                rcubea([gantry_connector_thickness, zmotor_mount_clamp_width, extrusion_size], align=-X+Z);

                // connect upper gantry
                t(zaxis_rod_offset)
                tz(extrusion_size/2)
                rcubea([gantry_connector_thickness, zmotor_mount_clamp_width+30*mm, extrusion_size], align=X, extra_align=Z);
            }

            /*tz(extrusion_size)*/
            /*rcubea([extrusion_size*2,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1], extra_size=[gantry_connector_thickness,0,0], extra_align=X);*/

        }
    }
    else if(part=="neg")
    {
        // screws for attaching to extrusion
        t(zaxis_rod_offset)
        tz(extrusion_size/2)
        for(y=[-1,1])
        tx(-.1)
        tx(gantry_connector_thickness)
        ty(y*(zmotor_mount_clamp_dist/2 + 13*mm))
        screw_cut(
            nut=zmotor_mount_clamp_nut,
            h=12*mm,
            head="button",
            thread=extrusion_thread,
            orient=-X,
            thread=extrusion_thread,
            align=-X
            );

        // cutout for z rod
        t(zaxis_rod_offset)
        tx(extrusion_size)
        cylindera(d=zaxis_rod_d*rod_fit_tolerance, h=extrusion_size*3, align=-X, orient=Z);

        // cutout and nut trap for rod clamp
        t(zaxis_rod_offset)
        tz(extrusion_size/2)
        tx(extrusion_size)
        tx(zaxis_rod_d/2)
        mount_rod_clamp_half(
            part=part,
            rod_d=zaxis_rod_d,
            screw_dist=zmotor_mount_clamp_dist,
            screw_h=zmotor_mount_thickness_h+extrusion_size,
            thick=5,
            base_thick=5,
            width=zmotor_mount_thickness_h,
            thread=zmotor_mount_clamp_thread,
            align=-X,
            orient=Z);
    }
}

module part_gantry_upper_connector()
{
    gantry_upper_connector();
}

if(false)
{
    /*rotate([0,180,0])*/
    gantry_upper_connector();

        t(zaxis_rod_offset)
        tz(extrusion_size/2)
        tx(extrusion_size)
        tx(zaxis_rod_d/2)
        mount_rod_clamp_half(
            part=part,
            rod_d=zaxis_rod_d,
            screw_dist=zmotor_mount_clamp_dist,
            screw_h=zmotor_mount_thickness_h+extrusion_size,
            thick=5,
            base_thick=5,
            width=zmotor_mount_thickness_h,
            thread=zmotor_mount_clamp_thread, 
            align=-X,
            orient=Z);
    /*t(-zaxis_rod_offset)*/
    /*tz(-extrusion_size/2)*/
    /*tx(-gantry_connector_thickness)*/
    /*tx(-zaxis_rod_d)*/
    /*mount_rod_clamp_half(*/
        /*rod_d=zaxis_rod_d,*/
        /*screw_dist=zmotor_mount_clamp_dist,*/
        /*thick=5,*/
        /*base_thick=5,*/
        /*width=zmotor_mount_thickness_h,*/
        /*thread=zmotor_mount_clamp_thread,*/
        /*align=-X,*/
        /*orient=Z);*/
}
