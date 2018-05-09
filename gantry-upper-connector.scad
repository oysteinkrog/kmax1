include <config.scad>
include <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>

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
                tx(zmotor_mount_rod_offset_x)
                rcubea([gantry_connector_thickness, zmotor_mount_clamp_width, extrusion_size+gantry_connector_thickness], align=[-1,0,1]);

                // connect upper gantry
                tx(upper_gantry_width_diff)
                tz(extrusion_size/2)
                rcubea([gantry_connector_thickness,main_upper_dist_y+extrusion_size,extrusion_size], align=X, extra_size=[0,0,gantry_connector_thickness], extra_align=Z);
            }

            tx(upper_gantry_width_diff)
            tz(extrusion_size)
            rcubea([extrusion_size*2,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1], extra_size=[gantry_connector_thickness,0,0], extra_align=X);

        }
    }
    else if(part=="neg")
    {
        // cut out z rod mounting clamp nut traps and screw holes
        t(zaxis_rod_offset)
        tx(zmotor_mount_rod_offset_x)
        tz(extrusion_size/2)
        for(y=[-1,1])
        tx(-.1)
        ty(y*zmotor_mount_clamp_dist/2)
        screw_cut(
            nut=zmotor_mount_clamp_nut,
            h=zmotor_mount_rod_offset_x-(extrusion_size*2),
            orient=[-1,0,0],
            align=[-1,0,0]
            );

        tx(upper_gantry_width_diff/2)
        tz(extrusion_size+gantry_connector_thickness)
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*extrusion_thread_dia*2)
        ty(y*main_upper_dist_y/2)
        screw_cut(nut=extrusion_nut, h=12*mm, head="button", orient=-Z, align=-Z);

        // cutout for z rod
        t(zaxis_rod_offset)
        tx(zmotor_mount_rod_offset_x)
        tx(extrusion_size)
        cylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=N, orient=Z);
    }
}

module part_gantry_upper_connector()
{
    gantry_upper_connector();
}

if(false)
{
    rotate([0,180,0])
    gantry_upper_connector();
}
