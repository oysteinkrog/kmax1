include <config.scad>

module zaxis_upper_gantry_zrod_connector()
{
    upper_width_extra = main_upper_width-main_width;
    difference()
    {
        union()
        {
            hull()
            {
                // attach to z rod
                translate([extrusion_size/2+zmotor_mount_rod_offset_x,0,0])
                {
                    cubea([gantry_connector_thickness, zmotor_mount_clamp_width, extrusion_size+gantry_connector_thickness], align=[-1,0,1]);
                }

                // connect upper gantry
                translate([upper_width_extra/2, 0, 0])
                    translate([0,0,extrusion_size/2])
                    cubea([gantry_connector_thickness,main_upper_dist_y+extrusion_size,extrusion_size], align=[1,0,0], extrasize=[0,0,gantry_connector_thickness], extrasize_align=[0,0,1]);
            }

            translate([upper_width_extra/2, 0, 0])
                translate([0,0,extrusion_size])
                cubea([extrusion_size*2,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1]);

        }

        // cut out z rod mounting clamp nut traps and screw holes
        translate([0,0,extrusion_size/2])
        translate([upper_width_extra/2, 0, 0])
        for(i=[-1,1])
        {
            translate([-.1, i*zmotor_mount_clamp_dist/2, 0])
            {
                screw_cut(zmotor_mount_clamp_nut, h=200, orient=[1,0,0], align=[1,0,0]);
            }
        }

        translate([0,0,extrusion_size+gantry_connector_thickness])
        /*#cubea(align=[0,0,1])*/

        translate([upper_width_extra/4, 0, 0])
        for(x=[-1,1])
        for(y=[-1,1])
        {
            translate([x*extrusion_thread_dia*2, y*main_upper_dist_y/2, 0])
            {
                screw_cut(extrusion_nut, h=gantry_connector_thickness+.1, nut_offset=true, orient=[0,0,-1], align=[0,0,-1]);
            }
        }

        // cutout for z rod
        translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
        translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,extrusion_size])
        cylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=[0,0,0], orient=[0,0,1]);
    }
}

/*rotate([0,180,0])*/
/*zaxis_upper_gantry_zrod_connector();*/
