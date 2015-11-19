include <MCAD/stepper.scad>
include <MCAD/motors.scad>

use <thing_libutils/triangles.scad>
include <thing_libutils/attach.scad>
include <config.scad>

ycarriage_bearing_mount_bottom_thick = 3;
ycarriage_bearing_mount_conn_bottom = [[0,0,0], [0,0,1]];
ycarriage_bearing_mount_conn_bearing = [[0,0,ycarriage_bearing_mount_bottom_thick+yaxis_bearing[1]/2], [0,0,1]];

module ycarriage_bearing_mount(show_bearing=false, show_zips=false)
{
    // x distance of holes
    screw_dx=28;
    // y distance of holes
    screw_dy=21;

    carriage_plate_thread=ThreadM4;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2;
    depth = max(yaxis_bearing[1], screw_dx+carriage_plate_thread_d*2);
    /*height = yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick;*/
    height = 5+ycarriage_bearing_mount_bottom_thick;

    difference()
    {
        union()
        {
            cubea ([width, depth, height], align=[0,0,1]);
        }

        translate ([+screw_dx/2, +screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([+screw_dx/2, -screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, +screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, -screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);

        translate([0,0,yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick])
        bearing_mount_holes(yaxis_bearing, orient=[0,1,0], ziptie_dist=5, show_zips=show_zips);
    }

    %if(show_bearing)
    {
        translate([0,0,yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick])
        bearing(yaxis_bearing, orient=[0,1,0]);
    }
}

/*c1=[[0,0,0],[0,0,-1]];*/
/*attach(c1,ycarriage_bearing_mount_conn)*/
/*{*/
    /*ycarriage_bearing_mount();*/
    /*#connector(ycarriage_bearing_mount_conn);*/
/*}*/

yaxis_motor_mount_conn = [[0,0,+extrusion_size/2+yaxis_motor_offset_z],[1,0,0]];
yaxis_motor_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_motor_mount_conn_motor = [[+yaxis_motor_offset_x, 0,+extrusion_size/2+yaxis_motor_offset_z],[0,0,1]];

ymotor_w = lookup(NemaSideSize, yaxis_motor);
ymotor_h = lookup(NemaLengthLong, yaxis_motor);
ymotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
ymotor_mount_h = main_lower_dist_z+extrusion_size+yaxis_motor_offset_z;
ymotor_mount_width = ymotor_w+ymotor_mount_thickness*2 + ymotor_mount_thread_dia*8;

module yaxis_motor_mount(show_motor=false)
{
    difference()
    {
        // top plate
        union()
        {
            translate([0,0,yaxis_motor_offset_z])
            {
                // top plate
                translate([ymotor_mount_thickness,0,extrusion_size/2])
                {
                    difference()
                    {
                        cubea([ymotor_w+ymotor_mount_thickness, ymotor_w+ymotor_mount_thickness*2, ymotor_mount_thickness_h], align=[1,0,1]);

                        // cut out motor mount holes etc
                        translate([ymotor_w/2,0,-1])
                            linear_extrude(ymotor_mount_thickness_h+2)
                            stepper_motor_mount(17, slide_distance=0, mochup=false);
                    }
                }

                translate([0,0,extrusion_size/2])
                {
                    difference()
                    {
                        // reinforcement plate between motor and extrusion
                        cubea([ymotor_mount_thickness, ymotor_w+ymotor_mount_thickness*2, ymotor_h], align=[1,0,-1], extrasize=[0,0,ymotor_mount_thickness_h], extrasize_align=[0,0,1]);

                        // cutout for motor cables
                        translate([0,0,-20*mm])
                            cubea([ymotor_mount_thickness*3, 20*mm, ymotor_h], align=[0,0,-1]);
                    }
                }

                // side triangles
                for(i=[-1,1])
                {
                    translate([ymotor_mount_thickness, i*((ymotor_w/2)+ymotor_mount_thickness/2), extrusion_size/2])
                        rotate([90,90,0])
                        Right_Angled_Triangle(a=ymotor_w+ymotor_mount_thickness, b=main_lower_dist_z+extrusion_size+yaxis_motor_offset_z, height=ymotor_mount_thickness, centerXYZ=[0,0,1]);

                    translate([0, i*((ymotor_w/2)+ymotor_mount_thickness/2), extrusion_size/2])
                        cubea([ymotor_mount_thickness, ymotor_mount_thickness, ymotor_mount_h], align=[1,0,-1]);
                }
            }

            // top mount plate
            difference()
            {
                cubea([ymotor_mount_thickness, ymotor_mount_width, extrusion_size], align=[1,0,0]);

                for(i=[-1,1])
                    translate([0, i*(ymotor_w/2+ymotor_mount_thread_dia*3), 0])
                        fncylindera(h=ymotor_mount_thickness*3,d=ymotor_mount_thread_dia, orient=[1,0,0]);
            }

            // bottom mount plate
            translate([0,0,-main_lower_dist_z])
            {
                difference()
                {
                    cubea([ymotor_mount_thickness, ymotor_w, extrusion_size], align=[1,0,0]);

                    for(i=[0])
                        translate([0, i*(ymotor_w/2+ymotor_mount_thread_dia*3), 0])
                            fncylindera(h=ymotor_mount_thickness*3,d=ymotor_mount_thread_dia,align=[0,0,0], orient=[1,0,0]);
                }
            }

        }

    }


    if(show_motor)
    {
        attach(yaxis_motor_mount_conn_motor,[[0,0,0],[0,0,0]])
        {
            motor(yaxis_motor, NemaMedium, dualAxis=false, orientation=[0,180,0]);

            translate([0,0,5*mm])
            fncylindera(d=yaxis_pulley_d, h=yaxis_motor_pulley_h, orient=[0,0,1]);
        }
    }
}

