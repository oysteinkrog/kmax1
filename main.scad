include <thing_libutils/metric-thread.scad>;
include <thing_libutils/metric-hexnut.scad>;
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;
include <thing_libutils/timing-belts.scad>;

include <MCAD/stepper.scad>
include <MCAD/motors.scad>

include <config.scad>
include <misc.scad>
include <extruder-direct.scad>
include <x-carriage.scad>
include <y-axis.scad>
include <z-axis.scad>
include <psu.scad>
include <rod-clamps.scad>

use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/skin.scad>

axis_pos_x = 0*mm;
axis_range_z=[85,380];
axis_pos_z = axis_range_z[1]*mm/2;

module main()
{
    color(extrusion_color)
    gantry_lower();

    color(extrusion_color)
    translate([0,0,-main_lower_dist_z])
    gantry_lower();

    color(extrusion_color)
    for(i=[-1,1])
    translate([0,i*(main_upper_dist_y/2),0])
    gantry_upper();

    // x axis
    translate([0,0,axis_pos_z])
    {
        if(!preview_mode)
        {
            translate([0, xaxis_zaxis_distance_y, 0])
                belt_path(500, 6, xaxis_pulley_d, orient=[1,0,0]);
        }

        translate([axis_pos_x,0,0])
        {
            // x carriage
            attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],[0,0,0]])
            {
                x_carriage(show_bearings=true);
            }

            if(!preview_mode)
            {
                attach([[12, -30, -30], [1,0,0]], extruder_conn_xcarriage)
                {
                    extruder();
                }
            }
        }

        // x smooth rods
        for(i=[-1,1])
            translate([0,xaxis_zaxis_distance_y,i*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);
    }

    // y axis
    attach([[0,main_depth/2,yaxis_motor_offset_z], [0,-1,0]], yaxis_motor_mount_conn)
    {
        yaxis_motor_mount(show_motor=true);
    }

    translate([0,0,yaxis_belt_path_offset_z])
    {
        if(!preview_mode)
        {
            belt_path(main_depth-yaxis_motor_offset_x*2, 6, yaxis_pulley_d, orient=[0,1,0]);
        }
    }

    hull()
    {
        translate([0,0,yaxis_bearing[0]/2])
        {
            attach(ycarriage_bearing_mount_conn_bearing, [[0,0,0],[0,0,1]])
            {
                cubea([10,20,10], align=[0,0,-1]);
            }
            translate([0,0,yaxis_belt_path_offset_z])
            {
                cubea([10,20,10], align=[0,0,-1]);
            }
        }

    }


    translate([0,0,yaxis_bearing[0]/2])
    {
        for(i=[-1,1])
        for(j=[-1,1])
        {
            attach([[i*(yaxis_rod_distance/2),j*(main_depth/2+extrusion_size/2),0],[0,0,1]],mount_rod_clamp_conn_rod)
            {
                mount_rod_clamp_full(rod_d=zaxis_rod_d, thick=4, width=extrusion_size, thread=zmotor_mount_clamp_thread, orient=[0,1,0]);
            }
        }

        for(i=[-1,1])
        translate([i*(yaxis_rod_distance/2), 0, 0])
        {
            fncylindera(h=yaxis_rod_l,d=yaxis_rod_d, orient=[0,1,0]);

            for(j=[-1,1])
            {
                attach([[0,j*(yaxis_rod_distance/2),0],[0,0,-1]], ycarriage_bearing_mount_conn_bearing)
                {
                    ycarriage_bearing_mount(show_bearing=true, show_zips=true);
                }
            }
        }

        attach(ycarriage_bearing_mount_conn_bearing, [[0,0,0],[0,0,1]])
        {
            // y axis plate
            cubea(ycarriage_size, align=[0,0,1]);

            translate([0,0,10*mm])
                cubea(ycarriage_size, align=[0,0,1]);
        }
    }

    // z axis
    for(i=[-1,1])
    {
        translate([i*(main_width/2),0,main_height])
        {
            mirror([i==-1?1:0,0,0])
            {
                upper_gantry_zrod_connector();

                translate([zmotor_mount_rod_offset_x, 0, extrusion_size/2])
                    mount_rod_clamp_half(
                            rod_d=zaxis_rod_d,
                            screw_dist=zmotor_mount_clamp_dist,
                            thick=5,
                            base_thick=5,
                            width=zmotor_mount_thickness_h,
                            thread=zmotor_mount_clamp_thread);
            }
        }


        translate([i*(main_width/2), 0, 0])
        {
            translate([0,0,zaxis_motor_offset_z])
                mirror([i==-1?1:0,0,0])
                {
                    zaxis_motor_mount(show_motor=true);

                    translate([zmotor_mount_rod_offset_x, 0, zmotor_mount_thickness_h/2])
                    {
                        mount_rod_clamp_half(
                                rod_d=zaxis_rod_d,
                                screw_dist=zmotor_mount_clamp_dist,
                                thick=5,
                                base_thick=5,
                                width=zmotor_mount_thickness_h,
                                thread=zmotor_mount_clamp_thread);
                    }
                }

            // z smooth rods
            translate([i*(lookup(NemaSideSize,zaxis_motor)/2), 0, 0])
            translate([i*(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,0])
            {
                // z rods
                translate([0,0,zaxis_motor_offset_z-50])
                    fncylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=[0,0,1]);

                for(j=[-1,1])
                    translate([0,0,axis_pos_z-j*xaxis_rod_distance/2])
                        bearing(zaxis_bearing);

            }

            translate([i*zmotor_mount_rod_offset_x, 0, axis_pos_z])
                #fncylindera(h=100, d=zaxis_nut[1], align=[0,0,0]);

            translate([i*zaxis_leadscrew_offset_x, 0, axis_pos_z-xaxis_rod_distance/2-10])
            {
                difference()
                {
                    #fncylindera(h=10, d=zaxis_nut[1], align=[0,0,0]);
                    union()
                    {
                        fncylindera(h=10+1, d=zaxis_nut[0], center= false);
                        translate([0, 13.5, -1]) fncylindera(h=5, r=1.6);
                        translate([0, -13.5, -1]) fncylindera(h=5, r=1.6);
                    }
                }
            }
        }
    }

    for(x=[-1,1])
    translate([x*(main_width/2-extrusion_size),main_depth/2,-main_lower_dist_z-extrusion_size])
    {
        translate([-x*psu_w/2, -psu_d/2, psu_h/2])
        {
            psu();

            mirror([x==-1?1:0,0,0])
            translate([0, -psu_screw_dist_y/2, 0])
                psu_extrusion_bracket_side();

            translate([0, psu_screw_dist_y/2, 0])
                psu_extrusion_bracket_back();
        }
    }
}

module upper_gantry_zrod_connector()
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
                cubea([extrusion_size*1.5,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1]);

        }

        // cut out z rod mounting clamp nut traps and screw holes
        translate([0,0,extrusion_size/2])
        translate([upper_width_extra/2, 0, 0])
        for(i=[-1,1])
        {
            translate([-1, i*zmotor_mount_clamp_dist/2, 0])
            {
                fncylindera(fn=6, d=zmotor_mount_clamp_nut_dia, h=zmotor_mount_clamp_nut_thick, orient=[1,0,0], align=[1,0,0]);

                fncylindera(d=zmotor_mount_clamp_thread_dia, h=100, orient=[1,0,0], align=[1,0,0]);
            }
        }


        // cutout for z rod
        translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
        translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,extrusion_size])
        fncylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=[0,0,0], orient=[0,0,1]);
    }
}


module gantry_upper()
{
    for(i=[-1,1])
    translate([i*(main_width/2), 0, 0])
    {
        if(preview_mode)
        {
            cubea(size=[extrusion_size, extrusion_size, main_height], align=[-i,0,1]);
        }
        else
        {
            linear_extrusion(h=main_height, align=[-i,0,1], orient=[0,0,1]);
        }
    }

    translate([0, 0, main_height])
    {
        if(preview_mode)
        {
            cubea(size=[main_upper_width, extrusion_size, extrusion_size], align=[0,0,1]);
        }
        else
        {
            linear_extrusion(h=main_upper_width, align=[0,0,1], orient=[1,0,0]);
        }
    }
}

module gantry_lower()
{
    for(i=[-1,1])
    translate([0,  i*(main_depth/2), 0]) 
    {
        if(preview_mode)
        {
            cubea([main_width, extrusion_size, extrusion_size], align=[0,i,-1]);
        }
        else
        {
            linear_extrusion(h=main_width, align=[0,i,-1], orient=[1,0,0]);
        }
    }

    for(i=[-1,1])
    translate([i*(main_width/2), 0, 0])
    {
        if(preview_mode)
        {
            cubea([extrusion_size, main_depth, extrusion_size], align=[-i,0,-1]);
        }
        else
        {
            linear_extrusion(h=main_depth, align=[-i,0,-1], orient=[0,1,0]);
        }
    }
}

module enclosure()
{
    w=60*cm;
    h=60*cm;
    d=60*cm;
    wallthick=2*cm;
    backthick=0.5*cm;

    translate([0, 0, h/2])
    {
        // left/right walls
        for(i=[-1,1])
            translate([i*w/2,0,0])
                cubea([wallthick,d,h], align=[-i, 0, 0]);

        // back plate
        translate([0,d/2,0])
            cubea([w,backthick,h], align=[0,-1, 0]);

        // top/bottom plate
        for(i=[-1,1])
        translate([0,0,i*h/2])
            cubea([w-wallthick*2,d,wallthick], align=[0,0, -i]);
    }
}

translate([0, 0, main_lower_dist_z+extrusion_size*2])
main();

/*psu();*/

/*%enclosure();*/


