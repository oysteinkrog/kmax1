include <MCAD/stepper.scad>
include <MCAD/motors.scad>

use <thing_libutils/triangles.scad>

include <config.scad>

// inner_d, outer_d, thread
zaxis_nut = [20*mm, 36.5*mm, 8*mm];

zaxis_nut_mount_outer = zaxis_nut[1]/2 + zaxis_bearing[1]/2 + 3;

// place z rod on edge of motor
/*zaxis_rod_screw_distance_x = max(zaxis_nut_mount_outer, zaxis_rod_d/2 + lookup(NemaSideSize,zaxis_motor)/2);*/
zaxis_rod_screw_distance_x = zaxis_nut_mount_outer;

xaxis_zaxis_distance_y = xaxis_rod_d/2 + zaxis_bearing[1]/2;

zmotor_w = lookup(NemaSideSize,zaxis_motor);
zmotor_h = lookup(NemaLengthLong,zaxis_motor);
zmotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
zmotor_mount_width = zmotor_w+zmotor_mount_thickness*2 + zmotor_mount_thread_dia*8;
zmotor_mount_h = main_lower_dist_z+extrusion_size+zaxis_motor_offset_z;
zmotor_mount_rod_offset_x = zmotor_w/2+zaxis_rod_screw_distance_x+zmotor_mount_motor_offset;

zmotor_mount_clamp_dist = zaxis_rod_d*2.5;
zmotor_mount_clamp_thread = ThreadM4;
zmotor_mount_clamp_nut = MHexNutM4;
zmotor_mount_clamp_thread_dia = lookup(ThreadSize, zmotor_mount_clamp_thread);
zmotor_mount_clamp_nut_dia = lookup(MHexNutWidthMin, zmotor_mount_clamp_nut);
zmotor_mount_clamp_nut_thick = lookup(MHexNutThickness, zmotor_mount_clamp_nut);

zmotor_mount_clamp_width = zmotor_mount_clamp_dist+zmotor_mount_clamp_thread_dia*3;

zaxis_leadscrew_offset_x = zmotor_w/2 + zmotor_mount_motor_offset;

zmotor_mount_conn_motor=[[-zmotor_mount_motor_offset, 0, 0],[0,1,0]];

module zaxis_motor_mount(show_motor=false)
{

    difference()
    {
        // top plate
        union()
        {

            difference()
            {
                union()
                {
                    // top plate
                    cubea([zmotor_mount_rod_offset_x-zmotor_mount_thickness, zmotor_w+zmotor_mount_thickness*2, zmotor_mount_thickness_h], align=[1,0,1]);
                    translate([zmotor_mount_rod_offset_x, 0, 0])
                    {
                        cubea([gantry_connector_thickness, zmotor_w+zmotor_mount_thickness*2, zmotor_mount_thickness_h], align=[-1,0,1]);
                    }

                    // reinforcement plate between motor and extrusion
                    cubea([zmotor_mount_thickness, zmotor_w, zmotor_h], align=[1,0,-1]);

                    // top extrusion mount plate
                    translate([0, 0,-extrusion_size-zaxis_motor_offset_z])
                        cubea([zmotor_mount_thickness, zmotor_mount_width, extrusion_size], align=[1,0,1]);

                    // bottom extrusion mount plate
                    translate([0, 0, -main_lower_dist_z-extrusion_size-zaxis_motor_offset_z])
                        cubea([zmotor_mount_thickness, zmotor_w, extrusion_size], align=[1,0,1]);

                    // side triangles
                    for(i=[-1,1])
                    {
                        translate([zmotor_mount_thickness, i*((zmotor_w/2)+zmotor_mount_thickness/2), 0])
                            rotate([90,90,0])
                            Right_Angled_Triangle(a=zmotor_mount_rod_offset_x-zmotor_mount_thickness, b=main_lower_dist_z+extrusion_size+zaxis_motor_offset_z, height=zmotor_mount_thickness, centerXYZ=[0,0,1]);

                        translate([0, i*((zmotor_w/2)+zmotor_mount_thickness/2), 0])
                            cubea([zmotor_mount_thickness, zmotor_mount_thickness, zmotor_mount_h], align=[1,0,-1]);
                    }

                }

                // cutout for motor cables
                translate([0,0,-30*mm])
                cubea([zmotor_mount_thickness*3, 20*mm, zmotor_h], align=[0,0,-1]);

                // screw holes top
                for(i=[-1,1])
                    translate([0, i*(zmotor_w/2+zmotor_mount_thread_dia*3), -extrusion_size])
                        fncylindera(h=zmotor_mount_thickness*3,d=zmotor_mount_thread_dia, orient=[1,0,0]);

                // screw hole bottom
                for(i=[0])
                    translate([0, i*(zmotor_w/2+zmotor_mount_thread_dia*3), -extrusion_size-main_lower_dist_z])
                        fncylindera(h=zmotor_mount_thickness*3,d=zmotor_mount_thread_dia,align=[0,0,0], orient=[1,0,0]);
            }

        }

        // cut out motor mount holes etc
        translate([zmotor_w/2+zmotor_mount_motor_offset,0,-1])
            linear_extrude(zmotor_mount_thickness_h+2)
            stepper_motor_mount(17, slide_distance=0, mochup=false);

        // cut out z rod
        translate([zmotor_mount_rod_offset_x, 0, 0])
            fncylindera(d=zaxis_rod_d*rod_fit_tolerance, h=100, orient=[0,0,1]);

        // cut out z rod mounting clamp nut traps
        for(i=[-1,1])
        {
            translate([zmotor_mount_rod_offset_x-7, i*zmotor_mount_clamp_dist/2, zmotor_mount_thickness_h/2])
            {
                cubea([zmotor_mount_clamp_nut_thick*1.1, zmotor_mount_clamp_nut_dia*1.01, zmotor_mount_clamp_nut_dia*1.01], extrasize=[0,0,zmotor_mount_thickness_h], extrasize_align=[0,0,1]);

                fncylindera(d=zmotor_mount_clamp_thread_dia, h=20, orient=[1,0,0], align=[1,0,0]);
            }
        }

        %if(show_motor)
        {
            attach([[lookup(NemaSideSize,zaxis_motor)/2,0,0],[0,0,0]],zmotor_mount_conn_motor)
            {
                // z motor/leadscrews
                motor(zaxis_motor, NemaMedium, dualAxis=false, orientation=[0,180,0]);
            }
        }
    }
}

