include <config.scad>

include <thing_libutils/system.scad>
include <thing_libutils/units.scad>
include <thing_libutils/materials.scad>

use <thing_libutils/screws.scad>
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/transforms.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/linear-extrusion.scad>;
use <thing_libutils/timing-belts.scad>;

use <x-end.scad>
include <x-end.h>

use <x-carriage.scad>
include <x-carriage.h>

use <y-motor-mount.scad>
include <y-motor-mount.h>

use <y-carriage-bearing-mount.scad>
include <y-carriage-bearing-mount.h>

use <y-carriage-belt-clamp.scad>
include <y-carriage-belt-clamp.h>

use <y-idler.scad>
include <y-idler.h>

use <z-motor-mount.scad>
include <z-motor-mount.h>

use <gantry-upper-connector.scad>
use <gantry-lower-connector.scad>

use <rod-clamps.scad>
include <rod-clamps.h>

/*use <psu.scad>*/
/*include <psu.h>*/

/*use <lcd2004.scad>*/
/*use <power-panel-iec320.scad>*/

// x carriage
axis_range_x_ = main_width/2 + zmotor_mount_rod_offset_x - xaxis_end_width(true) - x_carriage_w/2 - .5*mm;
axis_range_x = [-1,1] *  axis_range_x_;
axis_printrange_x = [-1/2, 1/2] * printbed_size[0];
axis_x_parked = [false, true];

axis_range_y=[0*mm,200*mm];
axis_pos_y = axis_range_y[0];
axis_range_z=[90*mm,353*mm];
axis_pos_z = axis_range_z[0];

echo(str("Axis range X: " , axis_range_x[0], " ", axis_range_x[1]," mm"));
echo(str("Axis range Y: " , axis_range_y[0], " ", axis_range_y[1]," mm"));
echo(str("Axis range Z: " , axis_range_z[0], " ", axis_range_z[1]," mm"));

echo(str("Build area Z: " , axis_range_z[1]-axis_range_z[0] , " mm"));

home_offset_x0 = axis_range_x[0] - axis_printrange_x[0] + v_x(extruder_filapath_offset)[0];
echo(str("Home offset X0: " , home_offset_x0));
echo(str("Tool offset X: " , axis_range_x_+x_carriage_w/2));

module x_axis()
{
    // x axis
    translate([0,0,axis_pos_z])
    {
        zrod_offset = zmotor_mount_rod_offset_x;
        for(z=[-1,1])
        for(z=xaxis_beltpath_z_offsets)
        translate([-main_width/2-zrod_offset+xaxis_end_motor_offset[0], xaxis_zaxis_distance_y, z])
        rotate(90*X)
        belt_path(
            len=main_width+2*(zrod_offset)+xaxis_end_motor_offset[0],
            belt_width=xaxis_belt_width,
            belt=xaxis_belt,
            pulley_d=xaxis_pulley_inner_d,
            orient=X, align=X);

        for(x=[0:len(axis_range_x)-1])
        {
            /*#cubea(size=[x_carriage_w,10,100]);*/

            pos = axis_x_parked[x] ? axis_range_x[x] : -axis_printrange_x[x];

            translate([pos,0,0])
            mirror([x==0?0:1,0,0])
            attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],N])
            {
                x_carriage_withmounts(show_vitamins=true, beltpath_offset=x==0?-1:1);

                x_carriage_extruder(show_vitamins=true, with_sensormount=x==0);
            }
        }

        // x smooth rods
        for(z=[-1,1])
        translate([xaxis_rod_offset_x,xaxis_zaxis_distance_y,z*(xaxis_rod_distance/2)])
        material(Mat_Chrome)
        cylindera(h=xaxis_rod_l,d=xaxis_rod_d+.1, orient=X);

        for(x=[-1,1])
        translate([x*(main_width/2), 0, 0])
        translate([0, xaxis_zaxis_distance_y, 0])
        translate([x*zmotor_mount_rod_offset_x, 0, 0])
        mirror([max(0,x),0,0])
        {
            xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);

            xaxis_end_bucket();
        }
    }
}

module y_axis()
{
    // y axis
    attach([[yaxis_belt_path_offset_x,main_depth/2,yaxis_motor_offset_z], [0,-1,0]], yaxis_motor_mount_conn)
    yaxis_motor_mount(show_motor=true);

    extrusion_idler_conn = [[yaxis_belt_path_offset_x, -main_depth/2-extrusion_size, -extrusion_size+yaxis_idler_offset_z], [0,-1,0]];
    attach(extrusion_idler_conn, yaxis_idler_conn)
    {
        yaxis_idler();

        attach(yaxis_idler_conn_pulleyblock, yaxis_idler_pulleyblock_conn)
        yaxis_idler_pulleyblock(show_pulley=true);
    }

    translate([yaxis_belt_path_offset_x,0,yaxis_belt_path_offset_z])
    translate([0,main_depth/2-yaxis_motor_offset_x,0])
    rotate(90*Y)
    belt_path(
        len=main_depth-yaxis_motor_offset_x-yaxis_idler_pulley_offset_y,
        belt_width=yaxis_belt_width,
        pulley_d=yaxis_pulley_inner_d,
        belt=yaxis_belt,
        align=-Y, orient=Y);

    translate([0,-axis_pos_y,get(LinearBearingInnerDiameter, yaxis_bearing)/2])
    attach(yaxis_carriage_bearing_mount_conn_bearing, yaxis_belt_mount_conn)
    yaxis_belt_holder();

    translate([0,0,get(LinearBearingInnerDiameter, yaxis_bearing)/2])
    {
        // y smooth rod clamps to frame
        for(x=[-1,1])
        for(y=[-1,1])
        attach([[x*(yaxis_rod_distance/2),y*(main_depth/2+extrusion_size/2),0],Z],mount_rod_clamp_conn_rod)
        mount_rod_clamp_full(rod_d=zaxis_rod_d, thick=4, width=extrusion_size, thread=zmotor_mount_clamp_thread, orient=Y);

        for(x=[-1,1])
        translate([x*(yaxis_rod_distance/2), 0, 0])
        {
            // y smooth rods
            material(Mat_Chrome)
            cylindera(h=yaxis_rod_l,d=yaxis_rod_d, orient=Y);

            // y bearing mounts
            for(y=[-1,1])
            attach([[0,y*(yaxis_bearing_distance_y/2)-axis_pos_y,0],[0,0,-1]], yaxis_carriage_bearing_mount_conn_bearing)
            {
                yaxis_carriage_bearing_mount();
            }
        }

        attach(yaxis_carriage_bearing_mount_conn_bearing, [[0,axis_pos_y,0],Z])
        {
            yaxis_carriage_size_inner = [32*mm,32*mm,0];

            material(Mat_PrintCarriage)
            {
                // y axis plate "arms"
                for(x=[-1,1])
                for(y=[-1,1])
                hull()
                {
                    translate([x*yaxis_carriage_size[0]/2, y*yaxis_carriage_size[1]/2, 0])
                    cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);

                    translate([x*(yaxis_carriage_size[0]/2-yaxis_carriage_size_inner[0]/2), y*(yaxis_carriage_size[1]/2-yaxis_carriage_size_inner[1]/2*mm), 0])
                    cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);
                }

            }

            // y axis plate
            material(Mat_PrintBed)
            translate([0,0,10*mm])
            cubea(printbed_size, align=Z);
        }
    }

}

module z_axis()
{
    // z axis
    for(x=[-1,1])
    {
        translate([x*(main_width/2),0,main_height])
        mirror([x==-1?1:0,0,0])
        translate([zmotor_mount_rod_offset_x, 0, extrusion_size/2])
        mount_rod_clamp_half(
            rod_d=zaxis_rod_d,
            screw_dist=zmotor_mount_clamp_dist,
            thick=5,
            base_thick=5,
            width=zmotor_mount_thickness_h,
            thread=zmotor_mount_clamp_thread);

        tx(x*(main_width/2))
        {
            tz(zaxis_motor_offset_z)
            mirror([x==-1?1:0,0,0])
            {
                zaxis_motor_mount(show_motor=true);

                tx(zmotor_mount_rod_offset_x)
                tz(zmotor_mount_thickness_h/2)
                mount_rod_clamp_half(
                    rod_d=zaxis_rod_d,
                    screw_dist=zmotor_mount_clamp_dist,
                    thick=5,
                    base_thick=5,
                    width=zmotor_mount_thickness_h,
                    thread=zmotor_mount_clamp_thread);
            }

            // z smooth rods
            tx(x*(zmotor_mount_rod_offset_x))
            tz(zaxis_motor_offset_z-80*mm)
            material(Mat_Chrome)
            cylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=Z);
        }
    }

}

module gantry_upper()
{
    for(y=[-1,1])
    translate([0,y*(main_upper_dist_y/2),0])
    {
        for(x=[-1,1])
        translate([x*(main_width/2), 0, 0])
        linear_extrusion(h=main_height, align=[-x,0,1], orient=Z);

        translate([0, 0, main_height])
        linear_extrusion(h=main_upper_width, align=Z, orient=X);
    }

    // upper gantry connectors
    for(x=[-1,1])
    translate([x*(main_width/2),0,main_height])
    mirror([x==-1?1:0,0,0])
    gantry_upper_connector();

}

module gantry_lower()
{
    for(z=[-1,1])
    translate([0,0,z*-main_lower_dist_z/2])
    {
        for(y=[-1,1])
        translate([0, y*(main_depth/2), 0])
        linear_extrusion(h=main_width, align=[0,y,-1], orient=X);

        for(x=[-1,1])
        translate([x*(main_width/2), 0, 0])
        linear_extrusion(h=main_depth, align=-x*X-Z, orient=Y);
    }


    // lower gantry connectors
    for(x=[-1,1])
    for(y=[-1,1])
    translate([x*(main_width/2),y*(main_depth/2),-extrusion_size/2])
    mirror([x==1?0:-1,0,0])
    mirror([0,y==1?1:0,0])
    gantry_lower_connector();

}

module enclosure()
{
    // inner
    w=56*cm;
    h=56*cm;
    d=58*cm;
    wallthick=2*cm;
    backthick=0.5*cm;

    translate([0, 0, h/2+wallthick])
    {
        // left/right walls
        for(x=[-1,1])
        translate([x*w/2,0,0])
        cubea([wallthick,d,h], align=[x, 0, 0]);

        // back plate
        translate([0,d/2,0])
        cubea([w,backthick,h], align=[0,-1, 0]);

        // top/bottom plate
        for(z=[-1,1])
        translate([0,0,z*h/2])
        cubea([w+wallthick*2,d,wallthick], align=[0,0, z]);
    }
}

module main()
{
    translate([0,0,-main_lower_dist_z/2])
    gantry_lower();

    translate(-zaxis_rod_offset)
    gantry_upper();

    x_axis();
    y_axis();
    z_axis();

    translate([-75*mm,0,0])
    translate([0,main_depth/2,0])
    translate([0,extrusion_size,0])
    translate([0,0,-main_lower_dist_z/2-extrusion_size/2])
    power_panel_iec320(orient=[0,-1,0], align=Y);

    if(!$preview_mode)
    {
        translate([0,-main_depth/2,0])
        translate([0,-extrusion_size/2,0])
        translate([0,0,-main_lower_dist_z/2])
        mount_lcd2004(show_gantry=true);

        for(x=[-1,1])
        translate([x*(main_width/2-extrusion_size),main_depth/2,-main_lower_dist_z-extrusion_size])
        translate([-x*psu_a_w/2, -psu_a_d/2, psu_a_h/2])
        {
            psu_a();

            mirror([x==-1?1:0,0,0])
            translate([0, -psu_a_screw_dist_y/2, 0])
            psu_a_extrusion_bracket_side();

            translate([0, psu_a_screw_dist_y/2, 0])
            psu_a_extrusion_bracket_back();
        }

        translate([0,-main_depth/2,-main_lower_dist_z-extrusion_size])
        translate([-100,100,0])
        rotate([0,0,270])
        import("stl/RAMPS1_4.STL");
    }
}



feet_height = 8*mm;
translate([0, 0, main_lower_dist_z+extrusion_size*2+feet_height])
main();

/*psu();*/

/*%enclosure();*/
