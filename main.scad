use <thing_libutils/metric-screw.scad>
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/transforms.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/linear-extrusion.scad>;
include <thing_libutils/timing-belts.scad>;

include <MCAD/stepper.scad>
include <MCAD/motors.scad>

/*include <extruder-direct.scad>*/
include <x-axis-end.scad>
include <x-carriage.scad>
include <y-axis-motor-mount.scad>
include <y-axis-carriage-bearing-mount.scad>
include <y-axis-carriage-belt-clamp.scad>
include <y-axis-idler.scad>
include <z-axis-motor-mount.scad>
include <gantry-upper-connector.scad>
include <gantry-lower-connector.scad>
include <psu.scad>
use <rod-clamps.scad>

use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/skin.scad>

axis_range_x=[0*mm,200*mm];
axis_pos_x = axis_range_x[0];
axis_range_y=[0*mm,200*mm];
axis_pos_y = axis_range_y[0];
axis_range_z=[98*mm,353*mm];
axis_pos_z = axis_range_z[0];

echo(str("Build area Z: " , axis_range_z[1]-axis_range_z[0] , " mm"));

module x_axis()
{
    // x axis
    translate([0,0,axis_pos_z])
    {
        if(!preview_mode)
        {
            zrod_offset = zmotor_mount_rod_offset_x;
            for(z=[-1,1])
            for(z=xaxis_beltpath_z_offsets)
            translate([-main_width/2-zrod_offset+xaxis_end_motor_offset[0], xaxis_zaxis_distance_y, z])
            belt_path(main_width+2*(zrod_offset)+xaxis_end_motor_offset[0], 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);
        }

        for(x=[-1,1])
        translate([axis_pos_x+x*148,0,0])
        {
            // x carriage
            attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],[0,0,0]])
            {
                x_carriage_withmounts(show_vitamins=true, beltpath_offset=x);

                x_carriage_extruder(show_vitamins=true, with_sensormount=x<=0);
            }
        }

        // x smooth rods
        color(color_rods)
        for(z=[-1,1])
            translate([xaxis_rod_offset_x,xaxis_zaxis_distance_y,z*(xaxis_rod_distance/2)])
                cylindera(h=xaxis_rod_l,d=xaxis_rod_d+.1, orient=[1,0,0]);

        for(x=[-1,1])
        {
            translate([x*(main_width/2), 0, 0])
            {
                translate([0, xaxis_zaxis_distance_y, 0])
                translate([x*zmotor_mount_rod_offset_x, 0, 0])
                mirror([max(0,x),0,0])
                xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);
            }
        }
    }
}

module y_axis()
{
    // y axis
    color(color_part)
    attach([[yaxis_belt_path_offset_x,main_depth/2,yaxis_motor_offset_z], [0,-1,0]], yaxis_motor_mount_conn)
    {
        yaxis_motor_mount(show_motor=true);
    }

    extrusion_idler_conn = [[yaxis_belt_path_offset_x, -main_depth/2-extrusion_size, -extrusion_size+yaxis_idler_offset_z], [0,-1,0]];
    attach(extrusion_idler_conn, yaxis_idler_conn)
    {
        color(color_part)
        yaxis_idler();

        attach(yaxis_idler_conn_pulleyblock, yaxis_idler_pulleyblock_conn)
        {
            color(color_part)
            yaxis_idler_pulleyblock(show_pulley=true);
        }
    }

    translate([yaxis_belt_path_offset_x,0,yaxis_belt_path_offset_z])
    {
        if(!preview_mode)
        {
            translate([0,main_depth/2-yaxis_motor_offset_x,0])
            {
                /*cubea([10,main_depth-yaxis_motor_offset_x,10], align=[0,-1,0]);*/
                belt_path(main_depth-yaxis_motor_offset_x-yaxis_idler_pulley_offset_y, 6, yaxis_pulley_inner_d, align=[0,-1,0], orient=[0,1,0]);
            }
        }
    }

    color(color_part)
    translate([0,-axis_pos_y,yaxis_bearing[0]/2])
    attach(yaxis_carriage_bearing_mount_conn_bearing, yaxis_belt_mount_conn)
    {
        yaxis_belt_holder();
    }

    translate([0,0,yaxis_bearing[0]/2])
    {
        for(x=[-1,1])
        for(y=[-1,1])
        {
            attach([[x*(yaxis_rod_distance/2),y*(main_depth/2+extrusion_size/2),0],[0,0,1]],mount_rod_clamp_conn_rod)
            {
                mount_rod_clamp_full(rod_d=zaxis_rod_d, thick=4, width=extrusion_size, thread=zmotor_mount_clamp_thread, orient=[0,1,0]);
            }
        }

        // y smooth rods
        for(x=[-1,1])
        translate([x*(yaxis_rod_distance/2), 0, 0])
        {
            color(color_rods)
            cylindera(h=yaxis_rod_l,d=yaxis_rod_d, orient=[0,1,0]);

            for(y=[-1,1])
            {
                attach([[0,y*(yaxis_bearing_distance_y/2)-axis_pos_y,0],[0,0,-1]], yaxis_carriage_bearing_mount_conn_bearing)
                {
                    yaxis_carriage_bearing_mount(show_bearing=true, show_zips=true);
                }
            }
        }

        attach(yaxis_carriage_bearing_mount_conn_bearing, [[0,axis_pos_y,0],[0,0,1]])
        {
            /*translate([x*yaxis_carriage_size[0]/2, y*(yaxis_carriage_size[1]-16*mm)/2, 0])*/
            // y axis plate
            for(x=[-1,1])
            for(y=[-1,1])
            hull()
            {
                translate([x*yaxis_carriage_size[0]/2, y*(yaxis_carriage_size[1])/2, 0])
                {
                    cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);
                }
                translate([x*(yaxis_carriage_size[0]/2-16*mm), y*(yaxis_carriage_size[1]/2-16*mm), 0])
                {
                    cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);
                }
            }

            cubea([yaxis_carriage_size[0]-16*mm*2,yaxis_carriage_size[1]-16*mm*2, yaxis_carriage_size[2]], align=[0,0,1]);

            translate([0,0,10*mm])
                cubea(yaxis_carriage_size, align=[0,0,1]);
        }
    }

}

module z_axis()
{
    // z axis
    for(x=[-1,1])
    {
        translate([x*(main_width/2),0,main_height])
        {
            mirror([x==-1?1:0,0,0])
            {
                color(color_part)
                translate([zmotor_mount_rod_offset_x, 0, extrusion_size/2])
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
        }


        translate([x*(main_width/2), 0, 0])
        {
            translate([0,0,zaxis_motor_offset_z])
                mirror([x==-1?1:0,0,0])
                {
                    color(color_part)
                    zaxis_motor_mount(show_motor=true);

                    color(color_part)
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
            translate([x*(zmotor_mount_rod_offset_x),0,0])
            {
                // z rods
                color(color_rods)
                translate([0,0,zaxis_motor_offset_z-50])
                    cylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=[0,0,1]);

                for(z=[-1,1])
                    translate([0,0,axis_pos_z-z*xaxis_rod_distance/2])
                        bearing(zaxis_bearing);

            }
        }
    }

}

module main()
{
    translate([0,0,-main_lower_dist_z/2])
    gantry_lower();

    gantry_upper();

    x_axis();
    y_axis();
    z_axis();

    if(!preview_mode)
    {
        for(x=[-1,1])
        translate([x*(main_width/2-extrusion_size),main_depth/2,-main_lower_dist_z-extrusion_size])
        {
            translate([-x*psu_a_w/2, -psu_a_d/2, psu_a_h/2])
            {
                psu_a();

                mirror([x==-1?1:0,0,0])
                    translate([0, -psu_a_screw_dist_y/2, 0])
                    psu_a_extrusion_bracket_side();

                translate([0, psu_a_screw_dist_y/2, 0])
                    psu_a_extrusion_bracket_back();
            }
        }

        translate([0,-main_depth/2,-main_lower_dist_z-extrusion_size])
            translate([-100,100,0])
            rotate([0,0,270])
            import("stl/RAMPS1_4.STL");
    }
}


module gantry_upper()
{
    color(color_extrusion)
    for(y=[-1,1])
    translate([0,y*(main_upper_dist_y/2),0])
    {
        for(x=[-1,1])
        translate([x*(main_width/2), 0, 0])
        {
            if(preview_mode)
            {
                cubea(size=[extrusion_size, extrusion_size, main_height], align=[-x,0,1]);
            }
            else
            {
                linear_extrusion(h=main_height, align=[-x,0,1], orient=[0,0,1]);
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

    // upper gantry connectors
    for(x=[-1,1])
    {
        translate([x*(main_width/2),0,main_height])
        {
            mirror([x==-1?1:0,0,0])
            {
                color(color_gantry_connectors)
                    gantry_upper_connector();
            }

        }
    }
}

module gantry_lower()
{
    color(color_extrusion)
    for(z=[-1,1])
    {
        translate([0,0,z*-main_lower_dist_z/2])
        {
            for(y=[-1,1])
            translate([0, y*(main_depth/2), 0])
            {
                if(preview_mode)
                {
                    cubea([main_width, extrusion_size, extrusion_size], align=[0,y,-1]);
                }
                else
                {
                    linear_extrusion(h=main_width, align=[0,y,-1], orient=[1,0,0]);
                }
            }

            for(x=[-1,1])
            translate([x*(main_width/2), 0, 0])
            {
                if(preview_mode)
                {
                    cubea([extrusion_size, main_depth, extrusion_size], align=[-x,0,-1]);
                }
                else
                {
                    linear_extrusion(h=main_depth, align=[-x,0,-1], orient=[0,1,0]);
                }
            }
        }

    }

    // lower gantry connectors
    for(x=[-1,1])
    for(y=[-1,1])
    {
        translate([x*(main_width/2),y*(main_depth/2),-extrusion_size/2])
        {
            mirror([x==1?0:-1,0,0])
            mirror([0,y==1?1:0,0])
            {
                color(color_gantry_connectors)
                    gantry_lower_connector();
            }

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
        for(x=[-1,1])
            translate([x*w/2,0,0])
                cubea([wallthick,d,h], align=[-x, 0, 0]);

        // back plate
        translate([0,d/2,0])
            cubea([w,backthick,h], align=[0,-1, 0]);

        // top/bottom plate
        for(z=[-1,1])
        translate([0,0,z*h/2])
            cubea([w-wallthick*2,d,wallthick], align=[0,0, -z]);
    }
}

translate([0, 0, main_lower_dist_z+extrusion_size*2])
main();

/*psu();*/

/*%enclosure();*/
