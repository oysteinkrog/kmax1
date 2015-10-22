include <thing_libutils/metric-thread.scad>;
include <thing_libutils/metric-hexnut.scad>;
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
include <MCAD/stepper.scad>
include <MCAD/motors.scad>

include <config.scad>

module capmount(show_sensor=false,lower_height=12,mount_lower=12,height=10,thickness=5,screws_spacing=21,screw_offset=[1,0],screws_diameter=4,sensor_spacing=3,sensor_height=[15,40,5],sensor_diameter=12)

{
    mount_start = 1.7+sensor_spacing+screws_spacing+screws_diameter+2*screw_offset[0];
    if(show_sensor)
    {
        translate([-8+sensor_diameter/2+thickness,-.5+mount_start+thickness+sensor_diameter/2,-39])
        {
            translate([0,0,sensor_height[1]+sensor_height[2]])
                fncylindera(d=sensor_diameter-0.5,h=sensor_height[0]);
            translate([0,0,sensor_height[2]])
                %fncylindera(d=sensor_diameter-0.5,h=sensor_height[1]);
            fncylindera(d=sensor_diameter-0.5,h=sensor_height[2]);
        }
    }

    //  Mount
    $fn=50;
    difference() {
        translate([0,0,-lower_height])
            cube([thickness+1, mount_start, height+lower_height]);


        //Screws 1
        translate([2*e, 4+screw_offset[0], height/2+screw_offset[1]])
        {
            rotate([0,90,0])
            {
                fncylindera(d=screws_diameter, h=thickness+1);
                translate([0,0,2.5])
                    fncylindera(h = 4, d=8.2, $fn=6);
            }
            //Screws 2
            translate([0,screws_spacing,0])
                rotate([0,90,0])
                {
                    fncylindera(d=screws_diameter, h=thickness+1);
                    translate([0,0,2.5])
                        fncylindera(h = 4, d=8.2, $fn=6);
                }
        }

    }
    //Sensor mount
    $fn=200;
    translate([-8,-.3,0])
        difference() {
            union() {
                translate([sensor_diameter/2+thickness,mount_start+thickness+sensor_diameter/2, -lower_height])
                    fncylindera(d=sensor_diameter+2*thickness, h=height+lower_height-mount_lower);

            }
            translate([sensor_diameter/2+thickness,mount_start+thickness+sensor_diameter/2, -height/2])
                fncylindera(d=sensor_diameter+0,5, h=2*height, center=true);

            cutoff=[1,2];
            translate([0,mount_start, -lower_height-e])
                cubea([cutoff[0],sensor_diameter+thickness*2,height+lower_height-mount_lower+2*e],[1,1,1]);

            translate([sensor_diameter+thickness*2,mount_start, -lower_height-e])
                cubea([cutoff[1],sensor_diameter+thickness*2,height+lower_height-mount_lower+2*e],[-1,1,1]);
        }
}

house_bearing=bearing_MR128;
guidler_bearing=bearing_625;

house_padding_wd=11*mm;
house_padding_h=4*mm;

filapath_width=10*mm;

// 4mm ptfe tube
filament_path_d = 4*mm;

// offset from the center of the bolt to the filament path
bolt_center_offset = 4.2*mm;

hotend_mount_h=10.5*mm;

// from E3D V6 heatsink drawing
// http://wiki.e3d-online.com/wiki/File:DRAWING-V6-175-SINK.png
// each entry == dia + h
hotmount_d_h=[[16*mm,3.7*mm],[12*mm,6*mm],[16*mm,3*mm]];
hotmount_outer_size=max(vec_i(hotmount_d_h,0))+10*mm;
hotmount_h_offset=-2*mm;
// which side does hotend slide in (x-axis, i.e. -1 is left, 1 is right)
hotmount_clamp_side=1*mm;

hotmount_tolerance=1.05*mm;

// hotmount clamp screws distance from center
hotmount_clamp_thread = ThreadM3;
hotmount_clamp_nut = MHexNutM3;

hotmount_clamp_screw_dia = lookup(ThreadSize, hotmount_clamp_thread);
hotmount_clamp_screws_dist = hotmount_d_h[1][1] + 2*hotmount_clamp_screw_dia;
hotmount_clamp_pad = 2.5*mm;
hotmount_clamp_thickness = 5*mm;
hotmount_clamp_y = 2*(hotmount_clamp_screws_dist + hotmount_clamp_screw_dia + hotmount_clamp_pad);
hotmount_clamp_height = hotmount_d_h[1][1];

// length of the guidler bearing bolt/screw
guidler_bolt_h=10*mm;

guidler_mount_w=guidler_bearing[2];
guidler_mount_d=9*mm;

guidler_w=max(guidler_mount_w+7, guidler_bearing[2]*2.8);
guidler_d=5;
guidler_h=12;
guidler_extra_h_up=guidler_bearing[1]/2+hotmount_clamp_screw_dia/2;

guidler_mount_off_d=-guidler_bearing[1]/1.7;
guidler_mount_off_h=-guidler_bearing[1]/1.7;

extruder_guidler_mount_off_y = guidler_mount_off_d - guidler_bearing[1]/2;

house_inner_w=max(guidler_w+3, filament_d*2 + 4*2);

guidler_screws_thread = ThreadM3;
guidler_screws_thread_dia= lookup(ThreadSize, guidler_screws_thread);
guidler_screws_distance=6*mm;
guidler_screws_mount_d = 10*mm;
guidler_screws_mount_d_offset = 0*mm;

xcarriage_mount_hole_distance = 23*mm;
xcarriage_mount_w = xcarriage_mount_hole_distance + 6*mm;
xcarriage_mount_d = 6*mm;
xcarriage_mount_h = xcarriage_mount_w;

house_w = max(house_inner_w+2*house_bearing[2], hotmount_outer_size, xcarriage_mount_w);
house_d=house_bearing[1]/2+house_padding_wd;
house_h=house_bearing[1]+house_padding_h;

house_guidler_screw_h = guidler_screws_thread_dia+8*mm;
house_guidler_screw_h_offset = house_h/2 + guidler_screws_thread_dia + 4*mm;

CustomNema17 = [
                [NemaModel, 17],
                [NemaLengthShort, 33*mm],
                [NemaLengthMedium, 39*mm],
                [NemaLengthLong, 47*mm],
                [NemaSideSize, 42.20*mm], 
                [NemaDistanceBetweenMountingHoles, 31.04*mm], 
                [NemaMountingHoleDiameter, 4*mm], 
                [NemaMountingHoleDepth, 4.5*mm], 
                [NemaMountingHoleLip, -1*mm], 
                [NemaMountingHoleCutoutRadius, 0*mm], 
                [NemaEdgeRoundingRadius, 7*mm], 
                [NemaRoundExtrusionDiameter, 22*mm], 
                [NemaRoundExtrusionHeight, 1.9*mm], 
                [NemaAxleDiameter, 5*mm], 
                // custom front axle length
                [NemaFrontAxleLength, 22*mm], 
                [NemaBackAxleLength, 15*mm],
                [NemaAxleFlatDepth, 0.5*mm],
                [NemaAxleFlatLengthFront, 15*mm],
                [NemaAxleFlatLengthBack, 14*mm]
         ];
extruder_motor = CustomNema17;

// 80t + 20t w/228-2GT-6 belt
gears_distance=38.8*mm;
motor_offset_x = -9*mm;
motor_offset_y = 38*mm;
motor_offset_z = -pythag_leg(motor_offset_y,gears_distance);

alpha = 0.7;
/*alpha = 1;*/
color_xcarriage = [0.3,0.8,0.3, alpha];
color_hotend = [0.8,0.4,0.4, alpha];
color_extruder = [0.2,0.6,0.9, alpha];
color_guidler = [0.4,0.5,0.8, alpha];

extruder_guidler_roll = 45;

house_offset_xcarriage_y = house_d+19*mm;
house_offset_xcarriage_z = -25;

// extruder connection point for guidler
extruder_conn_guidler = [ [0, extruder_guidler_mount_off_y, guidler_mount_off_h],  [1,0,0]];
extruder_conn_hotend = [[0,0,-house_h/2+hotmount_h_offset-0.1],[0,0,1]];
extruder_conn_xcarriage=[[0, house_offset_xcarriage_y, house_offset_xcarriage_z],[0,1,0]];
/*extruder_conn_xcarriage=[[house_w/2+10, 15,-36],[-1,0,0]];*/

extruder_conn_hotmount_clamp=[[house_w/2*(hotmount_clamp_side), 0,-house_h/2+hotmount_h_offset -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2], [0,0,0]];
hotmount_clamp_conn = [[0,0,0],[0,0,0]];

module extruder_guidler_mount(){

    translate([0,guidler_mount_off_d-guidler_bearing[1]/2, guidler_mount_off_h])
    {
        cubea([guidler_mount_w,guidler_mount_d,guidler_mount_d],align=[0,0,-1], extrasize=[0,5,0], extrasize_align=[0,1,0]);
        rotate([0,90,0])
        {
            fncylindera(d=guidler_mount_d, h=guidler_mount_w);
        }

        translate([0,0,-guidler_mount_d/2-1])
            cubea([house_w,guidler_mount_d,guidler_mount_d/2+1],align=[0,0,-1], extrasize=[0,5,0], extrasize_align=[0,1,0]);
    }
}

module extruder_own(show_filament=true)
{
    color(color_extruder)
    difference()
    {
        union(){

            hull()
            {
                // main house
                translate([0,bolt_center_offset,0])
                {
                    /*rotate([0,90,0])*/
                    /*fncylindera(h=house_w, d=house_d);*/
                    cubea(size=[house_w,house_d,house_h], align=[0,0,0]);
                }

                // hotend mount housing
                translate([0,0,-house_h/2 + hotmount_h_offset])
                {
                    /*cubea([house_w/2, hotmount_outer_size, hotend_mount_h], align=[-1,0,-1], extrasize=[guidler_mount_w/2,0,-hotmount_h_offset], extrasize_align=[1,-1,1]);*/
                    cubea([house_w, hotmount_outer_size, hotend_mount_h], align=[0,0,-1]);
                }

            }

            hull()
            {
                // main house
                translate([0,bolt_center_offset,0])
                {
                    /*rotate([0,90,0])*/
                    /*fncylindera(h=house_w, d=house_d);*/
                    cubea(size=[house_w, house_d, house_h], align=[0,0,0]);
                }

                // guidler screws mount
                translate([0, guidler_screws_mount_d_offset, house_guidler_screw_h_offset])
                {
                    cubea([house_w, guidler_screws_mount_d, house_guidler_screw_h], align=[0,0,0]);

                    for(i=[-1,1])
                    translate([i*(guidler_screws_distance), 0, 0])
                    rotate([0,90,90])
                    fncylindera(d=house_guidler_screw_h, h=guidler_screws_mount_d);
                }

                // mount onto xcarriage
                translate([0,0,0])
                    translate([0, house_offset_xcarriage_y, house_offset_xcarriage_z])
                    cubea([xcarriage_mount_w,xcarriage_mount_d,xcarriage_mount_h],[0,-1,0]);

                /*translate([0, house_offset_xcarriage_y, house_offset_xcarriage_z])*/
                /*cubea([xcarriage_mount_w,house_offset_xcarriage_y,xcarriage_mount_h],[0,-1,0]);*/
            }

            translate([0,bolt_center_offset,0])
            translate([motor_offset_x,motor_offset_y,motor_offset_z])
            {
                difference()
                {
                    slide_dist=4;
                    mount_thickness = motor_offset_x+house_w/2;
                    side = motorWidth(CustomNema17);

                    translate([-mount_thickness,0,0])
                        cubea([mount_thickness, side+slide_dist, side],[1,0,0]);

                    translate([-mount_thickness-1,0,0])
                        rotate([90,90,90])
                        linear_extrude(mount_thickness+2)
                        stepper_motor_mount(17, slide_distance=4, mochup=false);
                }
            }

            // guidler mount
            extruder_guidler_mount();
        }

        translate([0,bolt_center_offset,0])
        translate([motor_offset_x,motor_offset_y,motor_offset_z])
        {
            slide_dist=4;
            side = motorWidth(CustomNema17);
                mount_thickness = motor_offset_x+house_w/2;

            cubea([motorLength(CustomNema17), side+slide_dist, side],[1,0,0]);

            translate([-mount_thickness-1,0,0])
                rotate([90,90,90])
                linear_extrude(mount_thickness+2)
                stepper_motor_mount(17, slide_distance=4, mochup=false);
        }

        // guidler screws cutouts
        for(i=[-1,1])
        translate([i*(guidler_screws_distance), guidler_screws_mount_d_offset, house_guidler_screw_h_offset])
        {
            r= guidler_screws_thread_dia/2 * 1.1;
            cubea([r*2, guidler_screws_mount_d+1, r]);
            for(v=[-1,1])
            translate([0,0, v*r/2])
            {
                rotate([0,90,90])
                    fncylindera(r=r,h=guidler_screws_mount_d+1);
            }

            // guidler screw nuts drop-in slots
            translate([0,0, -r*2])
            cubea([nut_m3[1]*1.1,nut_m3[2]*1.25,house_guidler_screw_h], align=[0,0,1], extrasize=[0,0,1], extrasize_align=[0,0,1]);
        }

        // filament path ptfe line cutout
        fncylindera(d=filament_path_d, h=50, align=[0,0,0]);

        translate([0,0,-house_h/2+hotmount_h_offset])
        {
            hotmount_cutout(extend_cut=true);

            // clamp mount screw holes
            for(i=[-1,1])
            {
                translate([0, i*hotmount_clamp_screws_dist, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
                    rotate([0,90,0])
                    fncylindera(r=screw_m3[0], h=house_w+1);
            }

            translate([house_w/2 * (hotmount_clamp_side), 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
            {
                cubea([hotmount_clamp_thickness+0.2, hotmount_clamp_y+0.2, hotmount_clamp_height+0.2], align=[-hotmount_clamp_side,0,0], extrasize=[1,0,0], extrasize_align=[hotmount_clamp_side,0,0]);
            }
        }

        // cutout pivot to make sure guidler can rotate out
        guidler_pivot_r=pythag_hyp(abs(guidler_mount_off_d),abs(guidler_mount_off_h))+(guidler_bearing[1])/2;
        difference()
        {
            union()
            {
                /*translate([-house_inner_w/2,0,0])*/
                    /*translate([0,extruder_guidler_mount_off_y, guidler_mount_off_h])*/
                    /*rotate([0,90,0])*/
                    /*pie_slice(guidler_pivot_r*1.05, 120, 180, house_inner_w, $fn=50);*/

                translate([-house_inner_w/2,0,0])
                    translate([0,extruder_guidler_mount_off_y, guidler_mount_off_h])
                    rotate([0,90,0])
                    pie_slice(guidler_mount_d/2*1.25, 0, 180, house_inner_w/2 - guidler_mount_w/2, $fn=50);

                translate([guidler_mount_w/2,0,0])
                    translate([0,extruder_guidler_mount_off_y, guidler_mount_off_h])
                    rotate([0,90,0])
                    pie_slice(guidler_mount_d/2*1.25, 0, 180, house_inner_w/2 - guidler_mount_w/2, $fn=50);
            }

            extruder_guidler_mount();
        }

        // cutout inside main house for guidler
        guidler_pivot_r=pythag_hyp(guidler_mount_off_d,guidler_mount_off_h);
        translate([-house_inner_w/2,-guidler_bearing[1]/2, 0])
        {
            rotate([0,90,0])
            {
                pie_slice(r=guidler_bearing[1]/2*1.02, start_angle=0, end_angle=360, h=house_inner_w);
            }
        }

        /*translate([0,-guidler_bearing[1]/2,0])*/
        /*rotate([0,90,0])*/
        /*fncylindera(d=guidler_bearing[1]*1.05, h=house_inner_w);*/

        translate([0,bolt_center_offset,0])
        {
            // left bearing
            translate([-house_w/2-2*e,0,0])
                rotate([90,0,90])
                fncylindera(d=house_bearing[1]*1.02, h=house_bearing[2], align=[0,0,1]);

            // right bearing
            translate([house_w/2+2*e,0,0])
                rotate([90,0,90])
                fncylindera(d=house_bearing[1]*1.02, h=house_bearing[2], align=[0,0,-1]);

            // hobbed bolt
            rotate([90,0,90])
                fncylindera(d=8.5, h=house_w+1);
        }

        // guidler mount bolt hole
        translate([0,guidler_mount_off_d-guidler_bearing[1]/2, guidler_mount_off_h])
            rotate([0,90,0])
            fncylindera(r=screw_m3[0],h=guidler_w+1);
    }

    if(show_filament)
    {
        // filament
        fncylindera(d=filament_d, h=50);
    }

    /*translate([0,0,-house_h/2])*/
}

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
            fncylindera(d=d,h=h,align=[0,0,-1]);
            if(extend_cut)
            {
                cubea([house_w/2+1,d,h],align=[hotmount_clamp_side,0,-1]);
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
            translate([house_w/2 * hotmount_clamp_side, 0, 0]);
            {
                cubea([hotmount_clamp_thickness, hotmount_clamp_y, hotmount_clamp_height], align=[-hotmount_clamp_side,0,0]);
            }

            difference()
            {
                translate([house_w/2 * hotmount_clamp_side, 0, 0]);
                {
                    cubea([house_w/2, hotmount_d_h[1][0], hotmount_clamp_height], align=[-hotmount_clamp_side,0,0]);
                }

                translate([(-house_w/2 * hotmount_clamp_side) + (-0.5*hotmount_clamp_side), 0, hotmount_d_h[0][1]+hotmount_d_h[1][1]/2])
                {
                    hotmount_cutout(extend_cut = false);
                }
            }

        }

        // clamp mount screw holes
        for(i=[-1,1])
        {
            translate([0, i*hotmount_clamp_screws_dist, 0])
                rotate([0,90,0])
                fncylindera(r=screw_m3[0], h=hotmount_clamp_thickness, align=[0,0,-hotmount_clamp_side], extra_h=1);
        }
    }
}

// guidler connection point
guidler_conn = [ [0, guidler_mount_off_d, guidler_mount_off_h],  [1,0,0]];

module guidler()
{
    // everything inside this module is relative to the center of the 
    // bearing (that clamps the filament)
    color(color_guidler)
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
                rotate([0,90,0])
                    fncylindera(d=guidler_bearing[0]*1.5,h=guidler_w);
            }
            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off_d-guidler_mount_d/2, 0])
                    cubea([guidler_w, guidler_d, guidler_h], align=[0,1,0], extrasize=[0,0,guidler_extra_h_up], extrasize_align=[0,0,1]);

                // guidler mount point
                translate([0,guidler_mount_off_d, guidler_mount_off_h])
                    rotate([0,90,0])
                    fncylindera(d=guidler_mount_d,h=guidler_w);
            }

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off_d-guidler_mount_d/2, guidler_h])
                    cubea([guidler_w, guidler_d, 1], align=[0,1,0]);

                // guidler screws mount
                for(i=[-1,1])
                translate([i*(guidler_screws_distance),guidler_mount_off_d-guidler_mount_d/2, house_guidler_screw_h_offset])
                rotate([0,90,90])
                fncylindera(r=guidler_screws_thread_dia/2*3,h=guidler_d, align=[0,0,1]);

            }
        }

        // cutouts for clamping screws
        for(i=[-1,1])
        translate([i*(guidler_screws_distance),guidler_mount_off_d-guidler_mount_d/2, house_guidler_screw_h_offset])
        {
            r= guidler_screws_thread_dia/2*1.1;
            cubea([r*2,house_w+1,r]);
            for(v=[-1,1])
                translate([0,0, v*r/2])
                {
                    rotate([0,90,90])
                        fncylindera(r=r,h=house_w+1);
                }
        }

        // port hole to see bearing
        translate([0,-guidler_bearing[1]/2,0])
            cubea([guidler_bearing[0]*1.1, 100, guidler_bearing[1]/2], align=[0,0,1]);

        // cutout middle mount point pivot
        translate([0,guidler_mount_off_d, guidler_mount_off_h])
            rotate([0,90,0])
            {
                fncylindera(d=guidler_mount_d*1.25,h=guidler_mount_w*1.1);
            }

        // mount bolt hole
        translate([0,guidler_mount_off_d, guidler_mount_off_h])
            rotate([0,90,0])
            fncylindera(r=screw_m3[0],h=100);

        // guidler bearing bolt holder cutout
        union() {
            cubea([guidler_bolt_h*1.05+2*e,guidler_bearing[0]*1.05,guidler_bearing[0]*1.05],align=[0,1,0]);

            rotate([0,90,0])
                fncylindera(d=guidler_bearing[0]*1.05, h=guidler_bolt_h*1.05);
        }

        // guidler bearing cutout
        rotate([0,90,0])
            fncylindera(d=guidler_bearing[1]*1.1, h=guidler_bearing[2]*1.1);
    }


    %if(show_extras)
    {
        rotate([0,90,0])
        {
            fncylindera(d=guidler_bearing[1], h=guidler_bearing[2]);
            fncylindera(d=guidler_bearing[0], h=guidler_bolt_h);
        }
    }
}


module extras()
{
    hob_offset_x = -5*mm;

    // hobbed bolt
    // measurements from
    // http://wiki.e3d-online.com/wiki/E3D_HobbGoblin_Drawings
    hob_l = 64.5*mm;

    // center of the hob (from left side)
    hob_center = 37*mm;

    hob_conn_extruder=[[-hob_l/2+hob_center,0,0], [0,0,0]];

    attach([[0,bolt_center_offset,0],[0,0,0]], hob_conn_extruder)
    {
        /*connector(hob_conn_extruder);*/

        // hob-goblin hobbed bolt
        union()
        {
            thread_left = 20.5;
            thread_right = 14;
            hob_width = 4.2;
            color([0.1,0.2,0.3])
                translate([-hob_l/2,0,0])
                rotate([0,90,0])
                fncylindera(h=thread_left, d=8, align=[0,0,1]);

            color([0.6,0.6,0.6])
            difference()
            {
                translate([-hob_l/2+thread_left,0,0])
                    rotate([0,90,0])
                    fncylindera(h=hob_l-thread_left-thread_right, d=8, align=[0,0,1]);

                translate([-hob_l/2+hob_center,0,0])
                    rotate([0,90,0])
                    fncylindera(h=hob_width, d=8.1);
            }
            color([0.6,0.2,0.3])
                translate([-hob_l/2+hob_center,0,0])
                rotate([0,90,0])
                fncylindera(h=hob_width, d=7);

            color([0.1,0.2,0.3])
            translate([hob_l/2-thread_right,0,0])
                rotate([0,90,0])
                fncylindera(h=thread_right, d=8, align=[0,0,1]);

            /*rotate([0,90,0])*/
                /*fncylindera(h=hob_l, d=8);*/

            /*translate([-hob_l/2+hob_center,0,0])*/
                /*rotate([0,90,0])*/
                /*fncylindera(h=hob_width, d=8.1);*/

        }

        hob_conn_cog = [[-hob_l/2 + 13*mm,0,0], [-1,0,0]];

        /*connector(hob_conn_cog);*/
        // gear/cog
        // attach onto hobbed bolt
        cog_conn = [[11*mm,0,0],[1,0,0]];
        attach(hob_conn_cog, cog_conn, 019)
        {
            rotate([270,0,90])
                import("stl/gt2_extruder_cog_80tooth.stl");
        }
    }

    // motor/belt
    translate([0,bolt_center_offset,0])
    translate([motor_offset_x,motor_offset_y,motor_offset_z])
    {
        // main motor body
        motor(extruder_motor, NemaShort, dualAxis=false, orientation=[0,90,0]);

        translate([-2,0,0])
            rotate([0,0,180])
            import("stl/GT2_20tooth.stl");
    }

    // hotend
    hotend_conn =[[0,0,21.35*mm],[0,0,1]];
    attach(extruder_conn_hotend, hotend_conn)
        color(color_hotend)
        rotate([90,0,270])
        import("stl/E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");

    // x carriage
    xcarriage_conn =[[-0.4,-8.5,-1],[0,-1,0]];
    attach(extruder_conn_xcarriage, xcarriage_conn)
    {
        /*connector(xcarriage_conn);*/
        color(color_xcarriage)
            translate([282*mm,-170,14])
            rotate([90,180,180])
            import("../wilson/x-carriage.stl");
    }
}

module extruder()
{
    extruder_own();

    attach(extruder_conn_guidler, guidler_conn, extruder_guidler_roll)
    {
        guidler(show_extras=true);
    }

    attach(extruder_conn_hotmount_clamp, hotmount_clamp_conn)
    {
        /*connector(hotmount_clamp_conn);*/
        hotmount_clamp(); }

    if(true) { extras(); } }

module print() { extruder_conn_layflat = [[-house_w/2,0,0],[-1,0,0]];
attach([[0,0,0],[0,0,-1]], extruder_conn_layflat) {
        /*connector(extruder_conn_layflat);*/
        extruder_own(false,false); }

    guidler_conn_layflat = [ [0, guidler_mount_off_d-guidler_mount_d/2,
    guidler_mount_off_h],  [0,-1,0]]; attach([[34*mm,10*mm,0],[0,0,-1]],
    guidler_conn_layflat) {
        /*connector(guidler_conn_layflat);*/
        guidler(false); }

    hotmount_clamp_conn_layflat=[[0,0,0],[-1,0,0]];
    attach([[54*mm,0,0],[0,0,1]], hotmount_clamp_conn_layflat) {
        /*connector(hotmount_clamp_conn);*/
        hotmount_clamp(); } }

/*extruder();*/
/*print();*/

