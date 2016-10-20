include <MCAD/stepper.scad>
include <MCAD/motors.scad>

use <thing_libutils/shapes.scad>
use <thing_libutils/metric-screw.scad>

include <config.scad>
include <rod-clamps.scad>

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
                    rcubea([zmotor_mount_rod_offset_x-zmotor_mount_thickness, zmotor_w+zmotor_mount_thickness*2, zmotor_mount_thickness_h], align=[1,0,1]);
                    translate([zmotor_mount_rod_offset_x, 0, 0])
                    {
                        rcubea([gantry_connector_thickness+5, zmotor_w+zmotor_mount_thickness*2, zmotor_mount_thickness_h], align=[-1,0,1]);
                    }

                    // reinforcement plate between motor and extrusion
                    rcubea([zmotor_mount_thickness, zmotor_w+2, zmotor_h], align=[1,0,-1], extrasize=[0,0,2], extrasize_align=[0,0,1]);

                    // top extrusion mount plate
                    translate([0, 0,-extrusion_size-zaxis_motor_offset_z])
                        rcubea([zmotor_mount_thickness, zmotor_mount_width, extrusion_size], align=[1,0,1]);

                    // bottom extrusion mount plate
                    translate([0, 0, -main_lower_dist_z-extrusion_size-zaxis_motor_offset_z])
                        rcubea([zmotor_mount_thickness, zmotor_w+2, extrusion_size], align=[1,0,1]);

                    // side triangles
                    for(i=[-1,1])
                    {
                        translate([zmotor_mount_thickness, i*((zmotor_w/2)+zmotor_mount_thickness/2), 2])
                            triangle(
                                    zmotor_mount_rod_offset_x-zmotor_mount_thickness,
                                    main_lower_dist_z+extrusion_size+zaxis_motor_offset_z+2,
                                    depth=zmotor_mount_thickness,
                                    align=[1,0,-1],
                                    orient=[1,0,0]
                                    );

                        translate([0, i*((zmotor_w/2)+zmotor_mount_thickness/2), 2])
                            cubea([zmotor_mount_thickness, zmotor_mount_thickness, zmotor_mount_h+2], align=[1,0,-1]);
                    }

                }

                // cutout for motor cables
                translate([0,0,-30*mm])
                cubea([zmotor_mount_thickness*3, 20*mm, zmotor_h], align=[0,0,-1]);

                // screw holes top
                for(i=[-1,1])
                    translate([0, i*(zmotor_w/2+zmotor_mount_thread_dia*3), -extrusion_size])
                        cylindera(h=zmotor_mount_thickness*3,d=zmotor_mount_thread_dia, orient=[1,0,0]);

                // screw hole bottom
                for(i=[0])
                    translate([0, i*(zmotor_w/2+zmotor_mount_thread_dia*3), -extrusion_size-main_lower_dist_z])
                        cylindera(h=zmotor_mount_thickness*3,d=zmotor_mount_thread_dia,align=[0,0,0], orient=[1,0,0]);
            }

        }

        // cut out motor mount holes etc
        translate([zmotor_mount_screw_offset_x, 0, 0])
        translate([0,0,-1])
            linear_extrude(zmotor_mount_thickness_h+2)
            stepper_motor_mount(17, slide_distance=0, mochup=false);

        // cut out z rod
        translate([zmotor_mount_rod_offset_x, 0, 0])
            cylindera(d=zaxis_rod_d*rod_fit_tolerance, h=100, orient=[0,0,1]);

        // cut out z rod mounting clamp nut traps
        for(i=[-1,1])
        {
            translate([zmotor_mount_rod_offset_x-5, i*zmotor_mount_clamp_dist/2, zmotor_mount_thickness_h/2])
            {
                nut_trap_cut(nut=zmotor_mount_clamp_nut, h=10, head_embed=false, trap_h=10, screw_l_extra=2*mm, trap_axis=[0,0,1], orient=[1,0,0], align=[0,0,0]);
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

/*if(false)*/
/*zaxis_motor_mount();*/

print = false;
if(print)
{
    rotate([0,-90,0])
        zaxis_motor_mount();

    translate([-25,0,zmotor_mount_thickness_h/2])
        mount_rod_clamp_half(
                rod_d=zaxis_rod_d,
                screw_dist=zmotor_mount_clamp_dist,
                thick=5,
                base_thick=5,
                width=zmotor_mount_thickness_h,
                thread=zmotor_mount_clamp_thread);
}
