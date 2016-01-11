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
                translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
                translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,0])
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
            translate([-1, i*zmotor_mount_clamp_dist/2, 0])
            {
                fncylindera(fn=6, d=zmotor_mount_clamp_nut_dia*1.05, h=zmotor_mount_clamp_nut_thick*1.05, orient=[1,0,0], align=[1,0,0]);

                fncylindera(d=zmotor_mount_clamp_thread_dia, h=100, orient=[1,0,0], align=[1,0,0]);
            }
        }

        translate([0,0,extrusion_size/2])
        translate([upper_width_extra/4, 0, 0])
        for(x=[-1,1])
        for(y=[-1,1])
        {
            translate([x*extrusion_thread_dia*2, y*main_upper_dist_y/2, -1])
            {
                fncylindera(d=extrusion_thread_dia, h=100, orient=[0,0,1], align=[1,0,1]);
            }
        }

        // cutout for z rod
        translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
        translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,extrusion_size])
        fncylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=[0,0,0], orient=[0,0,1]);
    }
}

/*rotate([0,180,0])*/
/*zaxis_upper_gantry_zrod_connector();*/
