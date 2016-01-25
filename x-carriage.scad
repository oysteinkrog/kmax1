use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/transforms.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;
use <thing_libutils/bearing.scad>
use <thing_libutils/metric-screw.scad>

include <config.scad>


xaxis_carriage_bearing_distance = 8;
xaxis_carriage_padding = 2;
xaxis_carriage_mount_distance = 23;
xaxis_carriage_mount_offset_z = 0;
xaxis_carriage_teeth_height=xaxis_belt_width*1.5;
xaxis_carriage_mount_screws = ThreadM4;

xaxis_carriage_conn = [[0, -xaxis_bearing[1]/2 - xaxis_carriage_bearing_offset_y,0], [0,0,0]];

xaxis_carriage_beltfasten_w = 20;

hobbed_gear_d_outer = 12.65;
hobbed_gear_d_inner = 11.5;
hobbed_gear_h = 11;

extruder_gear_small_d_inner = 5.75*mm;
extruder_gear_big_d_inner = 29.35*mm;
extruder_gear_big_d_outer = 30.85*mm;
extruder_gear_big_h = [3.85*mm, 5*mm];

// 13t metal gear and 60t metal gear
extruder_gears_distance=extruder_gear_big_d_inner/2+extruder_gear_small_d_inner/2;

extruder_motor = dict_replace_multiple(Nema17,
        [
        [NemaLengthMedium, 11.75*mm],
        [NemaFrontAxleLength, 5*mm],
        ]);

// shaft from big gear to hobbed gear
extruder_shaft_d = 5*mm;

// dist between gear and motor
extruder_gear_motor_dist = .5*mm;
extruder_motor_angle = -80;
extruder_motor_offset_x = cos(extruder_motor_angle) * extruder_gears_distance;
extruder_motor_offset_z = sin(extruder_motor_angle) * extruder_gears_distance;
extruder_motor_holedist = lookup(NemaDistanceBetweenMountingHoles, extruder_motor);

extruder_gear_big_offset=[-extruder_motor_offset_x,0,extruder_motor_offset_z];

extruder_offset = [0,0,10*mm];
extruder_offset_a = -extruder_gear_big_offset+[
    0,
    xaxis_bearing[1] + xaxis_carriage_bearing_offset_y + 1*mm,
    0];
extruder_filapath_offset = [hobbed_gear_d_inner/2, -15*mm, 0];

guidler_bearing = bearing_MR105;
extruder_hotmount_clamp_thread = ThreadM3;

module x_carriage_base(show_bearings=false)
{
    bottom_width = xaxis_bearing[2] + 2*xaxis_carriage_padding;
    top_width = xaxis_bearing[2]*2 + xaxis_carriage_bearing_distance + 2*xaxis_carriage_padding;
    thickness = xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_y;

    hull()
    {
        // top bearings
        translate([0,0,xaxis_rod_distance/2])
            rcubea([top_width, thickness, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

        /*rcubea([top_width,thickness,xaxis_rod_distance/2], align=[0,1,0]);*/

        // bottom bearing
        translate([0,0,-xaxis_rod_distance/2])
            rcubea([bottom_width, thickness, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

    }
    translate([0,xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_y+xaxis_carriage_beltpath_offset+.1,0])
    {
        translate([0,-xaxis_beltpath_width/2,0])
        for(x=[-1,1])
        translate([x*(xaxis_carriage_beltfasten_w/2+5),-xaxis_beltpath_width/2,xaxis_pulley_inner_d/2])
        rcubea([xaxis_carriage_beltfasten_w,xaxis_beltpath_width,xaxis_beltpath_height/3], align=[0,0,-1]);
    }

    if(show_bearings)
    {
        for(x=[-1,1])
        translate([
                x*(xaxis_carriage_bearing_distance+xaxis_bearing[2])/2,
                xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_y,
                xaxis_rod_distance/2
        ])
        bearing(xaxis_bearing, orient=[1,0,0]);

        translate([
                0,
                xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_y,
                -xaxis_rod_distance/2
        ])
        bearing(xaxis_bearing, orient=[1,0,0]);

        /*translate([0,xaxis_carriage_beltpath_offset,0])*/
        /*for(i=[-1,1])*/
        /*translate([i*100,0,0])*/
        /*pulley(xaxis_idler_pulley, orient=[0,1,0]);*/
    }

}

module x_carriage_holes()
{
    for(i=[-1,1])
    translate([
            i*(xaxis_bearing[2]/2+xaxis_carriage_bearing_distance/2),
            xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_y, 
            xaxis_rod_distance/2
    ])
    {
        bearing_mount_holes(xaxis_bearing, orient=[1,0,0]);
        cubea([xaxis_bearing[2]*2,xaxis_bearing[1]/2+10,xaxis_bearing[1]+1*mm], align=[0,1,0]);
    }

    translate([
            0,
            xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_y,
            -xaxis_rod_distance/2])
    {
        bearing_mount_holes(xaxis_bearing, orient=[1,0,0]);
        cubea([xaxis_bearing[2]*2,xaxis_bearing[1]/2+10,xaxis_bearing[1]+1*mm], align=[0,1,0]);
    }

    // Extruder mounting holes
    /*translate([0,0,xaxis_carriage_mount_offset_z])*/
    /*for(j=[-1,1])*/
    /*for(i=[-1,1])*/
    /*{*/
        /*translate([i*xaxis_carriage_mount_distance/2,0,j*xaxis_carriage_mount_distance/2])*/
        /*{*/
            /*screw_dia = lookup(ThreadSize, xaxis_carriage_mount_screws);*/
            /*cylindera(d=screw_dia, h=100, orient=[0,1,0]);*/
        /*}*/
    /*}*/

    translate([0,xaxis_carriage_beltpath_offset+.1,0])
    {
        // Cut clearing space for the belt
        /*translate([0,-xaxis_beltpath_width/2,-xaxis_beltpath_height/2])*/
            /*#rcubea([500,xaxis_beltpath_width+1,5], align=[0,1,0], extrasize=[0,0,4], extrasize_align=[0,0,1]);*/

        translate([0,-xaxis_beltpath_width/2,0])
        {
            difference()
            {
                rcubea([500,xaxis_beltpath_width*2,xaxis_beltpath_height], align=[0,1,0]);
                for(x=[-1,1])
                translate([x*(xaxis_carriage_beltfasten_w/2+5),-xaxis_beltpath_width/2,xaxis_pulley_inner_d/2])
                    rcubea([xaxis_carriage_beltfasten_w,xaxis_beltpath_width*2,xaxis_beltpath_height/3], align=[0,1,-1]);
            }
        }

        /*belt_thickness=1.5;*/
        /*for(i=[-1,1])*/
            /*translate([i*30,0,0])*/
                /*rcubea([15,xaxis_beltpath_width,15-belt_thickness], align=[0,0,0]);*/

        // Cut in the middle for belt
        /*rcubea([7,xaxis_beltpath_width,xaxis_beltpath_height], align=[0,0,0]);*/

        /*translate([0,-xaxis_beltpath_width/2,xaxis_pulley_inner_d/2])*/
        /*{*/
            /*// Belt slit*/
            /*rcubea([500,xaxis_beltpath_width,belt_thickness], align=[0,1,0]);*/

            /*[>// Teeth cuts<]*/
            /*[>teeth = 50;<]*/
            /*[>teeth_height = 2;<]*/
            /*[>translate([-belt_tooth_distance/2*teeth-.5,0,0])<]*/
            /*[>for(i=[0:teeth])<]*/
            /*[>{<]*/
                /*[>translate([i*belt_tooth_distance,0,0])<]*/
                    /*[>cubea([belt_tooth_distance*belt_tooth_ratio,xaxis_carriage_teeth_height,teeth_height], align=[0,0,-1]);<]*/
            /*[>}<]*/
        /*}*/
    }
}


module extruder_gear_small()
{
    difference()
    {
        union()
        {
            hull()
            {
                cylindera(d=extruder_gear_small_d_inner, h=7*mm, orient=[0,1,0], align=[0,1,0]);
                cylindera(d=10*mm, h= 3*mm, orient=[0,1,0], align=[0,1,0]);
            }
            cylindera(d=extruder_gear_small_d_inner, h=13*mm, orient=[0,1,0], align=[0,1,0]);
        }
        cylindera(d=5*mm, h=13*mm+.1, orient=[0,1,0], align=[0,1,0]);
    }
}


module extruder_gear_big(align=[0,0,0], orient=[0,0,1])
{
    total_h = extruder_gear_big_h[0]+extruder_gear_big_h[1];
    size_align([extruder_gear_big_d_inner, extruder_gear_big_d_inner, total_h], align=align, orient=orient)
    translate([0,0,-extruder_gear_big_h[0] + total_h/2])
    difference()
    {
        union()
        {
            cylindera(d=extruder_gear_big_d_inner, h=extruder_gear_big_h[0], orient=[0,0,1], align=[0,0,1]);
            cylindera(d=12*mm, h=extruder_gear_big_h[1], orient=[0,0,1], align=[0,0,-1]);
        }
        translate([0,0,-.5])
        cylindera(d=5*mm, h=total_h+.2, orient=[0,0,1], align=[0,0,0]);
    }
}


module motor_mount_cut(motor=Nema17, h=10*mm)
{
    screw_dist = lookup(NemaDistanceBetweenMountingHoles, motor);

    // round dia
    translate([0, .1, 0])
    cylindera(d=1.1*lookup(NemaRoundExtrusionDiameter, motor), h=h, orient=[0,1,0], align=[0,1,0]);

    // motor axle
    translate([0, .1, 0])
    cylindera(d=1.2*lookup(NemaAxleDiameter, motor), h=lookup(NemaFrontAxleLength, motor)+2*mm, orient=[0,1,0], align=[0,1,0]);

    // bearing for offloading force on motor shaft
    /*translate([0, -1*mm-xaxis_pulley[1]-.1, 0])*/
    scale(1.03)
    bearing(bearing_MR105, override_h=h, orient=[0,1,0], align=[0,-1,0]);

    motor_thread=ThreadM3;
    motor_nut=MHexNutM3;
    for(x=[-1,1])
    for(z=[-1,1])
    translate([x*screw_dist/2, -h, z*screw_dist/2])
    {
        if(x!=-1 || z!=-1)
        screw_cut(motor_nut, h=h, with_nut=false, orient=[0,1,0], align=[0,1,0]);
    }
}
extruder_a_h = 14*mm;

module extruder_a(show_vitamins=false)
{
    difference()
    {
        hull()
        /*union()*/
        {
            side = 15*mm;
            rcubea([extruder_motor_holedist+side/2,extruder_a_h,extruder_motor_holedist+side/2], align=[0,1,0]);
            /*hull()*/
            /*{*/
                /*for(x=[-1,1])*/
                /*for(z=[-1,1])*/
                /*translate([(extruder_motor_holedist/2)*x,0,(extruder_motor_holedist/2)*z])*/
                /*rotate([0,x*45,0])*/
                /*rcubea([side/2,extruder_a_h,side/2], align=[0,1,0]);*/
            /*}*/
            translate(extruder_gear_big_offset)
            cylindera(d=extruder_gear_big_d_outer+3*mm, h=extruder_a_h, orient=[0,1,0], align=[0,-1,0], round_radius=2);
        }

        translate([0,extruder_a_h,0])
        {
            translate(extruder_gear_big_offset)
            {
                /*scale([1.3,2.0,1.3])*/
                /*#extruder_gear_big(orient=[0,-1,0], align=[0,-1,0]);*/

                // big gear cutout
                translate([0,-bearing_MR105[2]+.1,0])
                cylindera(d=extruder_gear_big_d_outer+1*mm, h=extruder_a_h+.2, orient=[0,1,0], align=[0,1,0]);

                translate([0,.1,0])
                cylindera(d=extruder_shaft_d+.5*mm, h=extruder_a_h+.2, orient=[0,1,0], align=[0,1,0]);

                translate([0,.1,0])
                scale(1.03)
                bearing(bearing_MR105, override_h=6*mm, orient=[0,1,0], align=[0,-1,0]);
            }

            motor_mount_cut(extruder_motor, h=extruder_a_h+1);
        }

    }

    if(show_vitamins)
    translate([0,extruder_a_h,0])
    {
        translate([0,-extruder_gear_motor_dist,0])
        {
            extruder_gear_small();

            // big gear
            translate(extruder_gear_big_offset)
            {
                translate([0,1,0])
                translate([0,-bearing_MR105[2]+.1,0])
                extruder_gear_big(orient=[0,-1,0], align=[0,-1,0]);

                translate([0,1,0])
                bearing(bearing_MR105, orient=[0,1,0], align=[0,-1,0]);

                translate([0,bearing_MR105[2],0])
                {
                    cylindera(h=60*mm, d=extruder_shaft_d, orient=[0,1,0], align=[0,1,0]);
                }
            }
        }
        motor(extruder_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
    }
}

// from E3D V6 heatsink drawing
// http://wiki.e3d-online.com/wiki/File:DRAWING-V6-175-SINK.png
// each entry == dia + h
hotmount_d_h=[[16*mm,3.7*mm],[12*mm,6*mm],[16*mm,3*mm]];
hotmount_outer_size_xy=max(vec_i(hotmount_d_h,0))+5*mm;
hotmount_outer_size_h=max(vec_i(hotmount_d_h,1))+5*mm;
hotmount_offset_h=-6*mm;
// which side does hotend slide in (x-axis, i.e. -1 is left, 1 is right)
hotmount_clamp_side=1;
hotmount_tolerance=1.05*mm;

// hotmount clamp screws distance from center
hotmount_clamp_thread = ThreadM3;
hotmount_clamp_nut = MHexNutM3;

hotmount_clamp_screw_dia = lookup(ThreadSize, hotmount_clamp_thread);
hotmount_clamp_screws_dist = hotmount_d_h[1][1] + 1.5*hotmount_clamp_screw_dia;
hotmount_clamp_pad = 0;
hotmount_clamp_thickness = 5*mm;
hotmount_clamp_y = 2*(hotmount_clamp_screws_dist + hotmount_clamp_screw_dia + hotmount_clamp_pad);
hotmount_clamp_height = hotmount_d_h[1][1];

module hotmount_cutout(extend_cut=false)
{
    // cutout of j-head/e3d heatsink mount
    heights=vec_i(hotmount_d_h,1);
    for(e=v_itrlen(hotmount_d_h))
    {
        hs=v_sum(heights,e-1);
        translate([0,0,-hs])
        {
            d=hotmount_d_h[e][0]*hotmount_tolerance;
            h=hotmount_d_h[e][1]*hotmount_tolerance;
            cylindera(d=d,h=h,align=[0,0,-1]);
            if(extend_cut)
            {
                cubea([extruder_b_w/2+1,d,h],align=[hotmount_clamp_side,0,-1]);
            }
        }
    }
}


module hotmount_clamp()
{
    difference()
    {
        union()
        {
            translate([extruder_b_w/2 * hotmount_clamp_side, 0, 0]);
            {
                cubea([hotmount_clamp_thickness, hotmount_clamp_y, hotmount_clamp_height], align=[-hotmount_clamp_side,0,0]);
            }

            difference()
            {
                translate([extruder_b_w/2 * hotmount_clamp_side, 0, 0]);
                {
                    cubea([extruder_b_w/2, hotmount_d_h[1][0], hotmount_clamp_height], align=[-hotmount_clamp_side,0,0]);
                }

                translate([(-extruder_b_w/2 * hotmount_clamp_side) + (-0.5*hotmount_clamp_side), 0, hotmount_d_h[0][1]+hotmount_d_h[1][1]/2])
                {
                    hotmount_cutout(extend_cut = false);
                }
            }

        }

        // clamp mount screw holes
        for(i=[-1,1])
        {
            translate([.1, i*hotmount_clamp_screws_dist, 0])
                rotate([0,90,0])
                cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread), h=hotmount_clamp_thickness+.2, align=[0,0,-hotmount_clamp_side], extra_h=2);
        }
    }
}

extruder_b_bearing = bearing_MR105;
extruder_b_w = hobbed_gear_d_outer+10*mm;


guidler_arm_len = 15*mm;

extruder_offset_guidler = extruder_filapath_offset-[hobbed_gear_d_inner/2,0,0]+[guidler_bearing[1],0,0];

guidler_mount_off_d=-guidler_bearing[1]/1.7;
guidler_mount_off_h=-guidler_bearing[1]/1.7;
extruder_guidler_mount_off = [hobbed_gear_d_inner/2+10,0,guidler_mount_off_h];

module extruder_b(show_vitamins=false)
{
    difference()
    {
        /*hull()*/
        union()
        {
            // main house
            extruder_b_size=[10,extruder_filapath_offset,10];
            rcubea(extruder_b_size);

            // gear support
            translate([0,-hobbed_gear_h/2,0])
            {
                // hobbed gear support
                cylindera(d=hobbed_gear_d_outer+5*mm, h=abs(extruder_filapath_offset[1])+hobbed_gear_h/2, align=[0,-1,0], orient=[0,1,0]);

                // bearing support
                cylindera(d=extruder_b_bearing[1]+5*mm, h=extruder_b_bearing[2]+4*mm, align=[0,1,0], orient=[0,1,0]);

            }

            // guidler mount
            translate(extruder_guidler_mount_off)
            {
                cylindera(d=guidler_mount_d, h=guidler_mount_w, orient=[0,1,0]);
            }

            // hotmount support
            translate([hobbed_gear_d_inner/2,0,-hobbed_gear_d_outer/2 + hotmount_offset_h])
            cubea([extruder_b_w, hotmount_outer_size_xy, hotmount_outer_size_h], align=[0,0,-1]);

            // clamp mount screw holes
            translate([hobbed_gear_d_inner/2,0,-hobbed_gear_d_outer/2 + hotmount_offset_h])
            for(i=[-1,1])
            {
                translate([0, i*hotmount_clamp_screws_dist, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
                cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread)+6*mm, h=extruder_b_w, orient=[1,0,0]);
            }
        }

        // guidler mount screw
        translate(extruder_guidler_mount_off)
        {
            cylindera(d=lookup(ThreadSize, guidler_screws_thread), h=guidler_mount_w+.1, orient=[0,1,0]);
        }

        // hobbed gear (inner)
        cylindera(h=hobbed_gear_h, d=hobbed_gear_d_outer+2*mm, orient=[0,1,0], align=[0,0,0]);

        // hotmount clamp screws
        translate([hobbed_gear_d_inner/2,0,-hobbed_gear_d_outer/2 + hotmount_offset_h])
            for(i=[-1,1])
            {
                translate([0, i*hotmount_clamp_screws_dist, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
                    rotate([0,90,0])
                    cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread), h=extruder_b_w+10);
            }

        // filament path
        translate([hobbed_gear_d_outer/2,0,0])
            cylindera(h=1000, d=4*mm, orient=[0,0,1], align=[0,0,0]);

        // gear cutout
        translate([0,-hobbed_gear_h/2-.5*mm,0])
            cylindera(d=extruder_b_bearing[1]+.3*mm, h=extruder_b_bearing[2]+.5*mm, align=[0,1,0], orient=[0,1,0]);

        for(x=[1])
        translate([x*hobbed_gear_d_inner/2,0,0])
        scale([1.03,1,1.03])
        {
            cubea([guidler_bearing[1]+1*mm,guidler_w+1*mm,guidler_bearing[1]*2], align=[x,0,1]);
            cylindera(d=guidler_bearing[1]+1*mm, h=guidler_w+1*mm, orient=[0,1,0], align=[x,0,0]);
        }

        translate([hobbed_gear_d_inner/2,0,-hobbed_gear_d_outer/2 + hotmount_offset_h+.01])
        {
            hotmount_cutout(extend_cut=true);

            // clamp mount screw holes
            for(i=[-1,1])
            {
                translate([0, i*hotmount_clamp_screws_dist, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
                cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread), h=extruder_b_w+1, orient=[1,0,0]);
            }

            // hotmount clamp cutout
            translate([extruder_b_w/2 * (hotmount_clamp_side), 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
            {
                rcubea([hotmount_clamp_thickness+0.2, hotmount_clamp_y+0.2, hotmount_clamp_height+0.2], align=[-hotmount_clamp_side,0,0], extrasize=[1,0,0], extrasize_align=[hotmount_clamp_side,0,0]);
            }
        }
    }

    if(show_vitamins)
    {
        translate([hobbed_gear_d_inner/2,0,-hobbed_gear_d_outer/2 + hotmount_offset_h+.01])
            translate([extruder_b_w/2 * (hotmount_clamp_side), 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
            hotmount_clamp();

        translate([0,-hobbed_gear_h/2-extruder_b_bearing[2]-.5*mm,0])
        {
            cylindera(h=extruder_a_h+extruder_offset_a[1]-extruder_filapath_offset[1], d=extruder_shaft_d, orient=[0,1,0], align=[0,-1,0]);

            bearing(extruder_b_bearing, orient=[0,1,0], align=[0,1,0]);
        }

        // hobbed gear
        cylindera(h=hobbed_gear_h, d=hobbed_gear_d_inner, orient=[0,1,0], align=[0,0,0]);
        for(y=[-1,1])
            translate([0,y*hobbed_gear_h/2,0])
            {
                cylindera(h=hobbed_gear_h/3, d=hobbed_gear_d_outer, orient=[0,1,0], align=[0,y,0]);
            }
    }
}

// Final part
module x_carriage(show_bearings=true)
{
    difference()
    {
        /*hull()*/
        union()
        {
            x_carriage_base(show_bearings=show_bearings);
            translate(extruder_offset)
            translate(extruder_offset_a)
            {
                for(x=[-1,1])
                for(z=[-1,1])
                translate([x*extruder_motor_holedist/2,0,z*extruder_motor_holedist/2])
                cylindera(d=10*mm, h=extruder_offset_a[1], orient=[0,1,0], align=[0,1,0], round_radius=2);
            }
        }
        translate(extruder_offset)
        translate(extruder_offset_a)
        {
            for(x=[-1,1])
            for(z=[-1,1])
            translate([x*extruder_motor_holedist/2,0,z*extruder_motor_holedist/2])
            translate([0,.1,0])
            cylindera(d=3*mm, h=extruder_offset_a[1]+.2, orient=[0,1,0], align=[0,1,0]);
        }
        x_carriage_holes();
    }
}

/*translate([0,-42,38])*/
/*rotate([0,0,90])*/
/*translate([0,-1,-42])*/
/*translate([-83,25,-42])*/
/*rotate([90,0,0])*/
/*import("stl/i3R_Compact_E3Dv6_Extruder_1.75_01.STL");*/

module x_extruder_hotend()
{
    hotend_conn =[[0,0,27.8-hotmount_offset_h],[0,0,1]];
    translate(extruder_offset)
    translate(extruder_filapath_offset)
    attach(extruder_conn_hotend, hotend_conn)
        rotate([90,0,270])
        %import("stl/E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");

}

house_w = 20;
house_h = 30;


// length of the guidler bearing bolt/screw
guidler_bolt_h=10*mm;

guidler_mount_w=guidler_bearing[2];
guidler_mount_d=8*mm;

guidler_w=max(guidler_mount_w+7, guidler_bearing[2]*2.8);
guidler_d=5;
guidler_h=8;
guidler_extra_h_up=guidler_bearing[1]/2+hotmount_clamp_screw_dia/2;


guidler_screws_thread = ThreadM3;
guidler_screws_thread_dia= lookup(ThreadSize, guidler_screws_thread);
guidler_screws_distance=4*mm;
guidler_screws_mount_d = 10*mm;
guidler_screws_mount_d_offset = 0*mm;

guidler_srew_distance = 10;

house_guidler_screw_h = guidler_screws_thread_dia+8*mm;
house_guidler_screw_h_offset = house_h/2 + guidler_screws_thread_dia -3*mm;

module extruder_guidler()
{
    // everything inside this module is relative to the center of the 
    // bearing (that clamps the filament)
    difference()
    {
        union()
        {

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off_d-guidler_mount_d/2, 0])
                cubea([guidler_w, guidler_d, guidler_h], align=[0,1,0]);

                // guidler bearing bolt holder
                cylindera(d=guidler_bearing[0]*1.5,h=guidler_w, orient=[1,0,0]);
            }

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off_d-guidler_mount_d/2, 0])
                cubea([guidler_w, guidler_d, guidler_h], align=[0,1,0], extrasize=[0,0,guidler_extra_h_up], extrasize_align=[0,0,1]);

                // guidler mount point
                translate([0,guidler_mount_off_d, guidler_mount_off_h])
                cylindera(d=guidler_mount_d,h=guidler_w, orient=[1,0,0]);
            }

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off_d-guidler_mount_d/2, guidler_h])
                cubea([guidler_w, guidler_d, 1], align=[0,1,0]);

                // guidler screws mount
                for(i=[-1,1])
                translate([i*(guidler_screws_distance),guidler_mount_off_d-guidler_mount_d/2, house_guidler_screw_h_offset])
                cylindera(r=guidler_screws_thread_dia/2*3,h=guidler_d, align=[0,-1,0], orient=[0,1,0]);

            }
        }

        // cutouts for clamping screws
        for(i=[-1,1])
        translate([i*(guidler_screws_distance),guidler_mount_off_d-guidler_mount_d/2, house_guidler_screw_h_offset])
        {
            r= guidler_screws_thread_dia/2*1.1;
            cubea([r*2,house_w+.1,r]);
            for(v=[-1,1])
            translate([0, -0.1, v*r/2])
            {
                cylindera(r=r,h=house_w+1, align=[0,-1,0], orient=[0,1,0]);
            }
        }

        // port hole to see bearing
        translate([0,-guidler_bearing[1]/2,0])
        cubea([guidler_bearing[0]*1.1, 100, guidler_bearing[1]/2], align=[0,0,1]);

        // cutout middle mount point pivot
        translate([0,guidler_mount_off_d, guidler_mount_off_h])
        cylindera(d=guidler_mount_d*1.25,h=guidler_mount_w*1.1, orient=[1,0,0]);

        // mount bolt hole
        translate([0,guidler_mount_off_d, guidler_mount_off_h])
        cylindera(d=lookup(ThreadSize, guidler_screws_thread),h=100, orient=[1,0,0]);

        // guidler bearing bolt holder cutout
        union()
        {
            cubea([guidler_bolt_h*1.05+2*e,guidler_bearing[0]*1.05,guidler_bearing[0]*1.05],align=[0,1,0]);

            cylindera(d=guidler_bearing[0]*1.05, h=guidler_bolt_h*1.05, orient=[1,0,0]);
        }

        // guidler bearing cutout
        cylindera(d=guidler_bearing[1]*1.1, h=guidler_bearing[2]*1.1, orient=[1,0,0]);
    }


    %if(show_extras)
    {
        cylindera(d=guidler_bearing[1], h=guidler_bearing[2], orient=[1,0,0]);
        cylindera(d=guidler_bearing[0], h=guidler_bolt_h, orient=[1,0,0]);
    }
}

extruder_offset_b = extruder_filapath_offset-[hobbed_gear_d_inner/2,0,0];

/*if(false)*/
{
    %x_carriage(show_bearings=false);

    translate(extruder_offset)
    {
        translate(extruder_offset_a)
        extruder_a(show_vitamins=true);

        translate(extruder_offset_b)
        {
            extruder_b(show_vitamins=true);
        }

        translate(extruder_offset_guidler)
        rotate([0,0,90])
        {
            extruder_guidler(show_extras=true);
        }
    }
    //filament path
    %translate(extruder_filapath_offset)
        cylindera(h=1000, d=1.75*mm, orient=[0,0,1], align=[0,0,0]);
}
