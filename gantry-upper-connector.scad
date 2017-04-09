include <config.scad>
include <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>

module gantry_upper_connector()
{
    // how much bigger/smaller is the upper gantry (on each side)
    upper_gantry_width_diff  = (main_upper_width-main_width)/2;
    difference()
    {
        material(Mat_Plastic)
        union()
        {
            hull()
            {
                // attach to z rod
                translate(zaxis_rod_offset)
                translate([zmotor_mount_rod_offset_x,0,0])
                {
                    rcubea([gantry_connector_thickness, zmotor_mount_clamp_width, extrusion_size+gantry_connector_thickness], align=[-1,0,1]);
                }

                // connect upper gantry
                translate([upper_gantry_width_diff, 0, 0])
                    translate([0,0,extrusion_size/2])
                    rcubea([gantry_connector_thickness,main_upper_dist_y+extrusion_size,extrusion_size], align=X, extrasize=[0,0,gantry_connector_thickness], extrasize_align=Z);
            }

            translate([upper_gantry_width_diff, 0, 0])
                translate([0,0,extrusion_size])
                rcubea([extrusion_size*2,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1], extrasize=[gantry_connector_thickness,0,0], extrasize_align=X);

        }

        // cut out z rod mounting clamp nut traps and screw holes
        translate(zaxis_rod_offset)
        translate([zmotor_mount_rod_offset_x, 0, extrusion_size/2])
        for(i=[-1,1])
        {
            translate([-.1, i*zmotor_mount_clamp_dist/2, 0])
            {
                screw_cut(
                        nut=zmotor_mount_clamp_nut,
                        h=zmotor_mount_rod_offset_x-(extrusion_size*2),
                        orient=[-1,0,0],
                        align=[-1,0,0]
                        );
            }
        }

        translate([upper_gantry_width_diff/2, 0, extrusion_size+gantry_connector_thickness])
        for(x=[-1,1])
        for(y=[-1,1])
        {
            translate([x*extrusion_thread_dia*2, y*main_upper_dist_y/2, 0])
            {
                screw_cut(extrusion_nut, h=gantry_connector_thickness+.1, nut_offset=true, orient=[0,0,-1], align=[0,0,-1]);
            }
        }

        // cutout for z rod
        translate(zaxis_rod_offset)
        translate([zmotor_mount_rod_offset_x,0,extrusion_size])
        cylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=N, orient=Z);
    }
}

module part_gantry_upper_connector()
{
    rotate([0,180,0])
    gantry_upper_connector();
}

/*rotate([0,180,0])*/
/*gantry_upper_connector();*/
