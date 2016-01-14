use <thing_libutils/metric-screw.scad>
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;
include <thing_libutils/timing-belts.scad>;

include <MCAD/stepper.scad>
include <MCAD/motors.scad>

include <misc.scad>
include <extruder-direct.scad>
include <x-axis-end.scad>
include <x-carriage.scad>
include <y-axis-motor-mount.scad>
include <y-axis-carriage-bearing-mount.scad>
include <y-axis-carriage-belt-clamp.scad>
include <y-axis-idler.scad>
include <z-axis-motor-mount.scad>
include <z-axis-upper-gantry-connector.scad>
include <psu.scad>
include <rod-clamps.scad>

use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/skin.scad>

axis_pos_x = -213/2*mm;
axis_pos_y = 0*mm;
axis_range_z=[85,380];
axis_pos_z = 80;//axis_range_z[1]*mm/2;


module x_axis()
{
    // x axis
    translate([0,0,axis_pos_z])
    {
        if(!preview_mode)
        {
            zrod_offset = zmotor_mount_rod_offset_x;
            translate([-main_width/2-zrod_offset+xaxis_end_motor_offset[0], xaxis_zaxis_distance_y, 0])
                belt_path(main_width+2*(zrod_offset)+xaxis_end_motor_offset[0], 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);
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
                attach([[35, -0, -0], [1,0,0]], extruder_conn_xcarriage)
                {
                    extruder();
                }
            }
        }

        // x smooth rods
        for(z=[-1,1])
            translate([xaxis_rod_offset_x,xaxis_zaxis_distance_y,z*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

        for(x=[-1,1])
        {
            translate([x*(main_width/2), 0, 0])
            {
                translate([0, xaxis_zaxis_distance_y, 0])
                translate([x*zmotor_mount_rod_offset_x, 0, 0])
                xaxis_end(with_motor=x==-1, show_nut=true, show_motor=true, show_nut=true);
            }
        }
    }
}

module y_axis()
{
    // y axis
    attach([[yaxis_belt_path_offset_x,main_depth/2,yaxis_motor_offset_z], [0,-1,0]], yaxis_motor_mount_conn)
    {
        yaxis_motor_mount(show_motor=true);
    }

    extrusion_idler_conn = [[yaxis_belt_path_offset_x, -main_depth/2-extrusion_size, -extrusion_size+yaxis_idler_offset_z], [0,-1,0]];
    attach(extrusion_idler_conn, yaxis_idler_conn)
    {
        yaxis_idler();
        attach(yaxis_idler_conn_pulleyblock, yaxis_idler_pulleyblock_conn)
        {
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

    translate([0,-axis_pos_y,yaxis_bearing[0]/2])
    attach(yaxis_carriage_bearing_mount_conn_bearing, yaxis_belt_mount_conn)
    {
        yaxis_belt_holder();
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
                attach([[0,j*(yaxis_bearing_distance_y/2)-axis_pos_y,0],[0,0,-1]], yaxis_carriage_bearing_mount_conn_bearing)
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
                    fncylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);
                }
                translate([x*(yaxis_carriage_size[0]/2-16*mm), y*(yaxis_carriage_size[1]/2-16*mm), 0])
                {
                    fncylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);
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
    for(i=[-1,1])
    {
        translate([i*(main_width/2),0,main_height])
        {
            mirror([i==-1?1:0,0,0])
            {
                zaxis_upper_gantry_zrod_connector();

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
            translate([i*(zmotor_mount_rod_offset_x),0,0])
            {
                // z rods
                translate([0,0,zaxis_motor_offset_z-50])
                    fncylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=[0,0,1]);

                for(j=[-1,1])
                    translate([0,0,axis_pos_z-j*xaxis_rod_distance/2])
                        bearing(zaxis_bearing);

            }
        }
    }

}

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

    x_axis();
    y_axis();
    z_axis();

    if(!preview_mode)
    {
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

        translate([0,-main_depth/2,-main_lower_dist_z-extrusion_size])
            translate([-100,100,0])
            rotate([0,0,270])
            import("stl/RAMPS1_4.STL");
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
