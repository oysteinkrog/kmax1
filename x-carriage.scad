include <config.scad>
include <x-end.scad>
include <thing_libutils/system.scad>;
include <thing_libutils/units.scad>;
include <thing_libutils/timing-belts.scad>
include <thing_libutils/gears-data.scad>

use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/transforms.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/linear-extrusion.scad>;
use <thing_libutils/bearing.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/gears.scad>

xaxis_carriage_bearing_distance = xaxis_rod_distance/sqrt(2) - 5*mm;
xaxis_carriage_padding = 1*mm;
xaxis_carriage_mount_distance = xaxis_carriage_bearing_distance+5*mm;
xaxis_carriage_mount_offset_z = 0*mm;
xaxis_carriage_teeth_height=xaxis_belt_width*1.5;
xaxis_carriage_mount_screws = ThreadM4;

xaxis_carriage_top_width = xaxis_bearing[2]*xaxis_bearings_top + xaxis_carriage_bearing_distance*(xaxis_bearings_top-1) + xaxis_carriage_padding*2;
xaxis_carriage_bottom_width = xaxis_bearing_bottom[2]*xaxis_bearings_bottom + xaxis_carriage_bearing_distance*(xaxis_bearings_bottom-1) + 2*xaxis_carriage_padding;

xaxis_carriage_conn = [[0, -xaxis_bearing[1]/2 - xaxis_carriage_bearing_offset_y,0], [0,0,0]];

xaxis_carriage_beltfasten_w = 11*mm;
xaxis_carriage_beltfasten_h = 4*mm;
xaxis_carriage_beltfasten_dist = xaxis_carriage_beltfasten_w/2+2*mm;

xaxis_carriage_thickness = xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_y;

extruder_drivegear_d_outer = 12.65*mm;
extruder_drivegear_d_inner = 11.5*mm;
extruder_drivegear_h = 11*mm;

gear_60t_mod05 =[
[GearMod, 0.5],
[GearTeeth, 60]
];

gear_13t_mod05 =[
[GearMod, 0.5],
[GearTeeth, 13]
];

// 13t metal gear and 60t metal gear
extruder_gear_small = gear_13t_mod05;
extruder_gear_big = gear_60t_mod05;

extruder_gears_distance=calc_gears_center_distance(gear_60t_mod05,gear_13t_mod05);
extruder_gear_small_PD = calc_gear_PD(extruder_gear_small);
extruder_gear_big_PD = calc_gear_PD(extruder_gear_big);
extruder_gear_big_OD = calc_gear_OD(extruder_gear_big);

extruder_gear_big_h = [3.85*mm, 5*mm];
extruder_motor = dict_replace_multiple(Nema17,
        [
        [NemaLengthMedium, 11.75*mm],
        [NemaFrontAxleLength, 5*mm],
        ]);

extruder_a_h = 13*mm;

extruder_a_bearing = bearing_MR125;
extruder_b_bearing = bearing_MR125;

extruder_filapath_offset = [0, -20*mm, 0] + [extruder_drivegear_d_inner/2,0,0];
extruder_b_drivegear_offset = extruder_filapath_offset - [extruder_drivegear_d_inner/2,0,0];
extruder_b_bearing_offset = extruder_b_drivegear_offset - [0,extruder_drivegear_h/2+extruder_b_bearing[2]/2+1*mm];

extruder_b_w = extruder_drivegear_d_outer+15*mm;

extruder_b_mount_thick = 5*mm;

extruder_b_mount_offsets=[
    /*[extruder_filapath_offset[0]-1*(extruder_b_w/2+4*mm),0,-15*mm],*/
    /*[extruder_filapath_offset[0]+1*(extruder_b_w/2+4*mm)-5*mm,0,-25*mm],*/
    /*[extruder_filapath_offset[0]-4*mm,0,44.5*mm-15*mm]*/

    [extruder_filapath_offset[0]-1*(extruder_b_w/2+4*mm),0,-13*mm],
    [extruder_filapath_offset[0]+1*(extruder_b_w/2+4*mm),0,-13*mm],
    [extruder_filapath_offset[0]-4*mm,0,35*mm-15*mm]
];

/*extruder_b_sensormount_offset=[35,-7,-41];*/
extruder_b_sensormount_offset=[-25,-7,-41];

extruder_a_bearing_offset_y = [0,-.5*mm,0];

extruder_motor_mount_angle = 45;

// dist between gear and motor
extruder_gear_motor_dist = .5*mm;
extruder_motor_gear_offset_angle = -90;
extruder_motor_offset_x = cos(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_offset_z = sin(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_holedist = lookup(NemaDistanceBetweenMountingHoles, extruder_motor);

extruder_gear_big_offset=[-extruder_motor_offset_x,0,extruder_motor_offset_z];

extruder_offset = [-extruder_filapath_offset[0]+6*mm, 0, 24.5*mm];
extruder_offset_a = -extruder_gear_big_offset+[
    0,
    xaxis_bearing[1] + xaxis_carriage_bearing_offset_y + 2*mm,
    0];

// shaft from big gear to hobbed gear
extruder_shaft_d = 5*mm;
extruder_shaft_len_b = abs(extruder_filapath_offset[1])+extruder_drivegear_h/2+extruder_b_bearing[2];
extruder_shaft_len = extruder_shaft_len_b+extruder_a_h+extruder_offset_a[1];

echo("Extruder B main shaft length: ", extruder_shaft_len);

extruder_hotmount_clamp_nut = NutHexM3;
extruder_hotmount_clamp_thread = ThreadM3;

module x_carriage(part=undef, beltpath_sign=1)
{
    if(part==undef)
    {
        difference()
        {
            x_carriage(part="pos");
            x_carriage(part="neg");
        }
    }
    else if(part=="pos")
    {
        hull()
        {
            // top bearings
            translate([0,0,xaxis_rod_distance/2])
            rcubea([xaxis_carriage_top_width, xaxis_carriage_thickness, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

            /*rcubea([xaxis_carriage_top_width,xaxis_carriage_thickness,xaxis_rod_distance/2], align=[0,1,0]);*/

            // bottom bearing
            translate([0,0,-xaxis_rod_distance/2])
            rcubea([xaxis_carriage_bottom_width, xaxis_carriage_thickness, xaxis_bearing_bottom[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

            /// support for extruder mount
            translate(extruder_offset)
            for(pos=extruder_b_mount_offsets)
            translate(pos)
            rcylinder(r=4*mm, align=[0,1,0], orient=[0,1,0]);

            // extruder A mount
            translate(extruder_offset)
            translate(extruder_offset_a)
            {
                rotate([0,extruder_motor_mount_angle,0])
                for(x=[-1,1])
                for(z=[-1,1])
                {
                    translate([x*extruder_motor_holedist/2,-extruder_offset_a[1],z*extruder_motor_holedist/2])
                    cylindera(d=extruder_b_mount_dia, h=xaxis_carriage_thickness, orient=[0,1,0], align=[0,1,0], round_radius=2);
                }
            }

            for(z=xaxis_beltpath_z_offsets)
            translate([0, xaxis_carriage_beltpath_offset_y, z])
            mirror([0,0,sign(z)<1?1:0])
            mirror([1,0,0])
            {
                beltpath(part=part, with_tensioner=beltpath_sign==sign(z));
            }
        }
    }
    else if(part=="neg")
    {
        for(x=[-1,1])
        {
            dist_top = (xaxis_bearings_top-1) * (xaxis_carriage_bearing_distance+xaxis_bearing[2])/2;
            translate([
                    x*dist_top,
                    xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_y,
                    xaxis_rod_distance/2
            ])
            {
                bearing_mount_holes(bearing_type=xaxis_bearing, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, orient=[1,0,0]);
                cubea([xaxis_bearing[2]+2*mm,xaxis_bearing[1]/2+10,xaxis_bearing[1]+1*mm], align=[0,1,0]);
            }

            dist_bot = (xaxis_bearings_bottom-1) * (xaxis_carriage_bearing_distance+xaxis_bearing[2])/2;
            for(x=[-1,1])
            translate([
                    x*dist_bot,
                    xaxis_bearing_bottom[1]/2+xaxis_carriage_bearing_offset_y,
                    -xaxis_rod_distance/2])
            {
                bearing_mount_holes(bearing_type=xaxis_bearing_bottom, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, orient=[1,0,0]);
                cubea([xaxis_bearing_bottom[2]*2*mm,xaxis_bearing_bottom[1]/2+10,xaxis_bearing_bottom[1]+1*mm], align=[0,1,0]);
            }
        }

        for(z=xaxis_beltpath_z_offsets)
        translate([0, xaxis_carriage_beltpath_offset_y, z])
        mirror([0,0,sign(z)<1?1:0])
        mirror([1,0,0])
        {
            beltpath(part=part, with_tensioner=beltpath_sign==sign(z));
        }
    }
    else if(part=="vit")
    {
        for(x=[-1,1])
        {
            dist_top = (xaxis_bearings_top-1) * (xaxis_carriage_bearing_distance+xaxis_bearing[2])/2;
            translate([
                x*dist_top,
                xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_y,
                xaxis_rod_distance/2
            ])
            bearing(xaxis_bearing, orient=[1,0,0]);

            dist_bot = (xaxis_bearings_bottom-1) * (xaxis_carriage_bearing_distance+xaxis_bearing[2])/2;
            translate([
                x*dist_bot,
                xaxis_bearing_bottom[1]/2 + xaxis_carriage_bearing_offset_y,
                -xaxis_rod_distance/2
            ])
            bearing(xaxis_bearing_bottom, orient=[1,0,0]);
        }
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
                cylindera(d=extruder_gear_small_PD, h=7*mm, orient=[0,1,0], align=[0,1,0]);
                cylindera(d=10*mm, h= 3*mm, orient=[0,1,0], align=[0,1,0]);
            }
            cylindera(d=extruder_gear_small_PD, h=13*mm, orient=[0,1,0], align=[0,1,0]);
        }
        cylindera(d=5*mm, h=13*mm+.1, orient=[0,1,0], align=[0,1,0]);
    }
}


module extruder_gear_big(align=[0,0,0], orient=[0,0,1])
{
    total_h = extruder_gear_big_h[0]+extruder_gear_big_h[1];
    size_align([extruder_gear_big_PD, extruder_gear_big_PD, total_h], align=align, orient=orient, orient_ref=[0,0,1])
    translate([0,0,-extruder_gear_big_h[0] + total_h/2])
    difference()
    {
        union()
        {
            cylindera(d=extruder_gear_big_PD, h=extruder_gear_big_h[0], orient=[0,0,1], align=[0,0,1]);
            cylindera(d=12*mm, h=extruder_gear_big_h[1], orient=[0,0,1], align=[0,0,-1]);
        }
        translate([0,0,-.5])
        cylindera(d=5*mm, h=total_h+.2, orient=[0,0,1], align=[0,0,0]);
    }
}


module extruder_a_motor_mount_cut(motor=Nema17, h=10*mm)
{
    screw_dist = lookup(NemaDistanceBetweenMountingHoles, motor);

    // round dia
    translate([0, .1, 0])
    {
        cylindera(d=1.1*lookup(NemaRoundExtrusionDiameter, motor), h=2*mm, orient=[0,1,0], align=[0,-1,0]);

        translate([0,-2*mm+.1,0])
        cylindera(d1=1.1*lookup(NemaRoundExtrusionDiameter, motor),d2=lookup(NemaRoundExtrusionDiameter, motor)*mm/1.5, h=h/2, orient=[0,1,0], align=[0,-1,0]);

        translate([0,-2*mm+.1-h/2+.1,0])
        cylindera(d=0.5*lookup(NemaRoundExtrusionDiameter, motor), h=h/2, orient=[0,1,0], align=[0,-1,0]);

        // motor axle
        cylindera(d=1.2*lookup(NemaAxleDiameter, motor), h=lookup(NemaFrontAxleLength, motor)+2*mm, orient=[0,1,0], align=[0,-1,0]);
    }

    motor_thread=ThreadM3;
    motor_nut=NutHexM3;
    for(x=[-1,1])
    for(z=[-1,1])
    translate([x*screw_dist/2, -h, z*screw_dist/2])
    {
        if(x!=-1 || z!=-1)
        {
            screw_cut(motor_nut, h=h, with_nut=false, orient=[0,1,0], align=[0,1,0]);
        }
    }
}

module extruder_a(part=undef)
{
    between_bearing_and_gear=0*mm;
    if(part==undef)
    {
        difference()
        {
            extruder_a(part="pos");
            extruder_a(part="neg");
        }
    }
    else if(part=="pos")
    {
        hull()
        {
            side = 15*mm;
            hull()
            {
                rotate([0,extruder_motor_mount_angle,0])
                for(x=[-1,1])
                for(z=[-1,1])
                translate([(extruder_motor_holedist/2)*x,0,(extruder_motor_holedist/2)*z])
                rotate([0,x*extruder_motor_mount_angle,0])
                cylindera(d=extruder_b_mount_dia, h=extruder_a_h, orient=[0,1,0], align=[0,1,0]);
            }

            // support round big gear, needed?
            /*translate(extruder_gear_big_offset)*/
            /*cylindera(d=extruder_gear_big_OD+2*mm+5*mm, h=extruder_a_h, orient=[0,1,0], align=[0,1,0], round_radius=2);*/

            // support around bearing
            translate([0,extruder_a_h,0])
            translate([0,-extruder_gear_motor_dist,0])
            translate(extruder_gear_big_offset)
            translate(extruder_a_bearing_offset_y)
            scale(1.02)
            cylindera(d=extruder_a_bearing[1]+5*mm, h=extruder_a_bearing[2], orient=[0,1,0], align=[0,-1,0]);
        }
    }
    else if(part=="support")
    {
        translate([0,extruder_a_h,0])
        translate(extruder_gear_big_offset)
        translate([0,.1,0])
        scale(1.5)
        bearing(extruder_a_bearing, extra_h=.3*mm, orient=[0,1,0], align=[0,-1,0]);
    }
    else if(part=="neg")
    {
        //cutouts for access to small gear tightscrew
        rotate([0,extruder_motor_mount_angle,0])
        for(i=[-1:0])
        rotate([0,i*90,0])
        translate([0,0,lookup(NemaSideSize, extruder_motor)/2])
        translate([0,extruder_a_h,0])
        teardrop(d=17*mm, h=lookup(NemaSideSize, extruder_motor)/2, orient=[0,0,1], roll=90, align=[0,0,-1]);

        //cutouts for access to big gear tightscrew
        /*translate(extruder_gear_big_offset)*/
        /*translate([0,extruder_gear_big_h[0],0])*/
        /*translate([1,extruder_gear_big_h[1]/2+1*mm,0])*/
        /*for(i=[0:6])*/
        /*rotate([0,20+i*-35,0])*/
        /*teardrop(d=9*mm, h=1000, orient=[1,0,0], align=[-1,0,0], roll=90);*/

        translate([0,extruder_a_h,0])
        {
            translate([0,-extruder_gear_motor_dist,0])
            translate(extruder_gear_big_offset)
            {
                // big gear cutout
                translate([0,-between_bearing_and_gear,0])
                translate([0,-extruder_a_bearing[2],0])
                {
                    cylindera(d=extruder_gear_big_OD+5*mm, h=extruder_a_h+.2, orient=[0,1,0], align=[0,-1,0]);
                }

                cylindera(d=extruder_shaft_d+1*mm, h=extruder_a_h+.2, orient=[0,1,0], align=[0,-1,0]);

                translate(extruder_a_bearing_offset_y)
                scale(1.02)
                cylindera(d=extruder_a_bearing[1], h=1000*mm, orient=[0,1,0], align=[0,-1,0]);
            }

            rotate([0,-extruder_motor_mount_angle,0])
            extruder_a_motor_mount_cut(extruder_motor, h=extruder_a_h+1);
        }
    }
    else if(part=="vit")
    {
        translate([0,extruder_a_h,0])
        {
            translate([0,-extruder_gear_motor_dist,0])
            {
                extruder_gear_small();

                // big gear
                translate(extruder_gear_big_offset)
                {
                    translate([0,-between_bearing_and_gear,0])
                    translate([0,-extruder_a_bearing[2],0])
                    extruder_gear_big(orient=-YAXIS, align=-YAXIS);

                    // bearing
                    translate(extruder_a_bearing_offset_y)
                    bearing(extruder_a_bearing, orient=[0,1,0], align=[0,-1,0]);

                    cylindera(h=60*mm, d=extruder_shaft_d, orient=[0,1,0], align=[0,-1,0]);
                }
            }
            rotate([0,extruder_motor_mount_angle,0])
            {
                translate([0,-1*mm,0])
                {
                    %motor(extruder_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);

                    // motor heatsink
                    translate([0,lookup(NemaLengthMedium, extruder_motor)+2*mm,0])
                    {
                        w = lookup(NemaSideSize, extruder_motor);
                        color([.5,.5,.5])
                        cubea([40*mm,11*mm,40*mm], align=[0,1,0]);

                        // fan
                        color([.9,.9,.9])
                        translate([0,11*mm,0])
                        {
                            difference()
                            {
                                cubea([40*mm,10*mm,40*mm], align=YAXIS);
                                cylindera(d=38*mm, h=10*mm+.1, orient=YAXIS, align=[0,-1,0]);
                            }

                        }
                    }

                }

            }

        }
    }
}

// from E3D V6 heatsink drawing
// http://wiki.e3d-online.com/wiki/File:DRAWING-V6-175-SINK.png
// each entry == dia + h
hotmount_d_h=[[16*mm,3.7*mm],[12*mm,6*mm],[16*mm,3*mm]];
hotmount_outer_size_xy=max(vec_i(hotmount_d_h,0))+5*mm;
hotmount_outer_size_h=max(vec_i(hotmount_d_h,1))+5*mm;
// relative to hotend mount
hotmount_clamp_offset = [0, 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2];

// which side does hotend slide in (x-axis, i.e. -1 is left, 1 is right)
hotmount_tolerance=1.05*mm;

// hotmount clamp screws distance from center
hotmount_clamp_thread = ThreadM3;
hotmount_clamp_nut = NutKnurlM3_5_42;

hotmount_clamp_screw_dia = lookup(ThreadSize, hotmount_clamp_thread);
hotmount_clamp_screws_dist = hotmount_d_h[1][1] + 1.2*hotmount_clamp_screw_dia;
hotmount_clamp_pad = 0;
hotmount_clamp_thickness = 5*mm;
hotmount_clamp_w = [
2*(hotmount_clamp_screws_dist + hotmount_clamp_screw_dia + hotmount_clamp_pad),
2*(hotmount_clamp_screws_dist - hotmount_clamp_screw_dia/2),
];
hotmount_clamp_height = hotmount_d_h[1][1];

module hotend_cut(extend_cut=false, extend_cut_amount = extruder_b_w/2+1)
{
    // cutout of j-head/e3d heatsink mount
    heights=vec_i(hotmount_d_h,1);
    for(e=v_itrlen(hotmount_d_h))
    {
        hs=v_sum(heights,e);
        translate([0,0,-hs])
        {
            d=hotmount_d_h[e][0]*hotmount_tolerance;
            h=hotmount_d_h[e][1]*hotmount_tolerance;
            cylindera(d=d,h=h,align=[0,0,1]);
            if(extend_cut)
            {
                cubea([d, extend_cut_amount, h], align=-YAXIS+ZAXIS);
            }
        }
    }
}

module hotmount_clamp(part=undef)
{
    if(part==undef)
    {
        difference()
        {
            hotmount_clamp(part="pos");
            hotmount_clamp(part="neg");
        }
    }
    else if(part=="pos")
    {
        translate([0, -hotmount_clamp_offset-extruder_filapath_offset[1], 0])
        translate([0, 0, 0-hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
        {
            rcubea([hotmount_clamp_w[0], hotmount_clamp_thickness, hotmount_clamp_height], align=[0,1,0]);
        }
        translate([0, -hotmount_clamp_offset-extruder_filapath_offset[1], 0])
        translate([0, 0, 0-hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
        {
            rcubea([hotmount_clamp_w[1], hotmount_d_h[1][0], hotmount_clamp_height], align=[0,1,0]);
        }
    }
    else if(part=="neg")
    {
        hotend_cut(extend_cut = false);

        // clamp mount screw holes
        translate([0, -hotmount_clamp_offset-extruder_filapath_offset[1], 0])
        translate([0, 0, 0-hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
        for(i=[-1,1])
        translate([i*hotmount_clamp_screws_dist, 0, 0])
        screw_cut(thread=extruder_hotmount_clamp_thread, h=30*mm, nut_offset=0*mm, head_embed=false, orient=[0,1,0], align=[0,1,0]);
    }
}

module hotmount_clamp_cut()
{
    // clamp mount screw holes
    translate([0, -hotmount_clamp_offset-extruder_filapath_offset[1], 0])
    translate([0, 0, 0-hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
    for(i=[-1,1])
    translate([i*hotmount_clamp_screws_dist, 0, 0])
    screw_cut(thread=extruder_hotmount_clamp_thread, h=30*mm, nut_offset=0*mm, head_embed=false, orient=[0,1,0], align=[0,1,0]);

    // hotmount clamp cutout
    translate([0, -hotmount_clamp_offset-extruder_filapath_offset[1], 0])
    translate([0, 0, 0-hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
    {
        rcubea([hotmount_clamp_w[0], hotmount_clamp_thickness, hotmount_clamp_height], align=[0,1,0], extrasize=[0,100,0], extrasize_align=[0,-1,0]);
    }
    translate([0, 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2+.1])
    {
        rcubea([hotmount_clamp_w[1], 1000, hotmount_clamp_height+.2], align=[0,-1,0]);
    }

    hotend_cut(extend_cut = true);
}

hotmount_clamp_offset = abs(extruder_filapath_offset[1])+extruder_drivegear_h/2+extruder_b_bearing[2]+4*mm;

module extruder_b(part=undef, with_sensormount=true)
{
    if(part==undef)
    {
        difference()
        {
            extruder_b(part="pos", with_sensormount=with_sensormount);
            extruder_b(part="neg", with_sensormount=with_sensormount);
        }
    }
    else if(part=="pos")
    {
        // mount onto carriage
        hull()
        {
            for(pos=extruder_b_mount_offsets)
            translate(pos)
            cylindera(d=extruder_b_mount_dia, h=extruder_b_mount_thick, orient=[0,1,0], align=[0,-1,0], round_radius=2);

            // hobbed gear bearing support
            translate(extruder_b_bearing_offset)
            cylindera(d=extruder_b_bearing[1]+5*mm, h=extruder_b_bearing[2]+2*mm, orient=YAXIS, align=YAXIS, round_radius=2);

            // hotmount support
            translate(hotend_mount_offset)
            {
                rcubea([extruder_b_w, hotmount_outer_size_xy, hotmount_outer_size_h], align=[0,0,-1]);

                translate([0,-extruder_b_drivegear_offset[1],0])
                rcubea([extruder_b_w, abs(extruder_b_drivegear_offset[1]), hotmount_outer_size_h], align=[0,-1,-1]);
            }

            // guidler screw nuts support
            translate(extruder_b_drivegear_offset)
            translate([extruder_b_guidler_screw_offset_x, 0, extruder_b_guidler_screw_offset_h])
            {
                for(i=[-1,1])
                translate([0,i*(guidler_screws_distance),  0])
                cylindera(h=house_guidler_screw_h, d=guidler_screws_mount_d, orient=[1,0,0], round_radius=2);
            }

            // support for clamp mount screw holes
            translate(hotend_mount_offset)
            translate([0, 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
            for(x=[-1,1])
            {
                translate([x*hotmount_clamp_screws_dist, 0, 0])
                cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread)+6*mm, h=extruder_b_w, orient=[0,1,0]);
            }
        }

        // mount onto carriage
        hull()
        {
            for(pos=extruder_b_mount_offsets)
            translate(pos)
            cylindera(d=extruder_b_mount_dia, h=extruder_b_mount_thick, orient=[0,1,0], align=[0,-1,0], round_radius=2);

            if(with_sensormount)
            intersection()
            {
                translate(extruder_b_sensormount_offset)
                translate(-[0,extruder_b_sensormount_offset[1],0])
                sensormount(part, align=-YAXIS);
                cubea([1000,extruder_b_mount_thick,1000], align=[0,-1,0]);
            }
        }

        if(with_sensormount)
        translate(extruder_b_sensormount_offset)
        rotate([-90,0,0])
        hull()
        {
            linear_extrude(1)
                projection()
                rotate([90,0,0])
                sensormount(part, align=-YAXIS);

            rotate([90,0,0])
                translate(-[0,extruder_b_sensormount_offset[1],0])
                sensormount(part, align=-YAXIS);

            rotate([90,0,0])
                sensormount(part, align=-YAXIS);
        }

        hull()
        {
            // hobbed gear support
            translate(extruder_b_drivegear_offset)
            cylindera(d=extruder_drivegear_d_outer+5*mm, h=abs(extruder_b_drivegear_offset[1])+extruder_drivegear_h/2, orient=[0,1,0], align=[0,0,0], round_radius=2);

            // hobbed gear bearing support
            translate(extruder_b_bearing_offset)
            cylindera(d=extruder_b_bearing[1]+5*mm, h=extruder_b_bearing[2]+2*mm, orient=YAXIS, align=YAXIS, round_radius=2);

            // guidler screw nuts support
            translate(extruder_b_drivegear_offset)
            translate([extruder_b_guidler_screw_offset_x, 0, extruder_b_guidler_screw_offset_h])
            {
                for(i=[-1,1])
                translate([0,i*(guidler_screws_distance),  0])
                cylindera(h=house_guidler_screw_h, d=guidler_screws_mount_d, orient=[1,0,0], round_radius=2);
            }

            // guidler mount
            translate(extruder_b_drivegear_offset)
            translate(extruder_guidler_mount_off)
            {
                cylindera(d=guidler_mount_d, h=guidler_mount_w, orient=[0,1,0]);
            }

            // hotmount support
            translate(hotend_mount_offset)
            {
                rcubea([extruder_b_w, hotmount_outer_size_xy, hotmount_outer_size_h], align=[0,0,-1]);

                translate([0,-extruder_b_drivegear_offset[1],0])
                rcubea([extruder_b_w, abs(extruder_b_drivegear_offset[1]), hotmount_outer_size_h], align=[0,-1,-1]);
            }

            // support for clamp mount screw holes
            translate(hotend_mount_offset)
            translate([0, 0, -hotmount_d_h[0][1]-hotmount_d_h[1][1]/2])
            for(x=[-1,1])
            {
                translate([x*hotmount_clamp_screws_dist, 0, 0])
                cylindera(d=lookup(ThreadSize, extruder_hotmount_clamp_thread)+6*mm, h=extruder_b_w, orient=[0,1,0]);
            }
        }

    }
    else if(part=="neg")
    {
        // mount onto carriage
        for(pos=extruder_b_mount_offsets)
        translate(pos)
        translate([0, -extruder_b_mount_thick, 0])
        screw_cut(nut=NutKnurlM3_3_42, h=extruder_b_mount_thick+xaxis_carriage_thickness-xaxis_beltpath_width/2, head_embed=true, orient=[0,1,0], align=[0,1,0]);

        // drive gear window cutout
        translate(extruder_b_drivegear_offset)
        translate([-.1,-.5*mm,0])
        translate(-[extruder_drivegear_d_inner,0,0])
        {
            s=[extruder_drivegear_d_inner,extruder_drivegear_h+1*mm,extruder_drivegear_d_inner];
            cubea(s, align=[0,0,0], extrasize=[0,3*mm,0], extrasize_align=YAXIS);
        }

        translate(extruder_b_drivegear_offset)
        {
            guidler_w_cut = guidler_w+2*mm;
            guidler_w_cut_inner = guidler_bearing[2]+1*mm;
            guidler_w_cut_ext = 1000;
            difference()
            {
                union()
                {
                    /*hull()*/
                    {
                        /*hull()*/
                        {
                            translate([extruder_drivegear_d_inner/2,0,0])
                            translate(3*mm*XAXIS)
                            {
                                cubea([guidler_bearing[1]+1*mm,guidler_w_cut,guidler_bearing[1]*2], align=[1,0,1]);
                            }

                            // cut for guidler bearing
                            translate(extruder_guidler_mount_off)
                            translate(-[-guidler_mount_off[1],0,guidler_mount_off[2]])
                            cylindera(d=guidler_bearing[1]+2*mm, h=guidler_w_cut_inner, orient=[0,1,0], align=[0,0,0]);

                            // cut for guidler
                            translate(extruder_guidler_mount_off)
                            translate(-[-guidler_mount_off[1],0,guidler_mount_off[2]])
                            cylindera(d=guidler_bearing[0]+4*mm, h=guidler_w_cut, orient=[0,1,0], align=[0,0,0]);

                            guidler_pivot_r=pythag_hyp(abs(guidler_mount_off[1]),abs(guidler_mount_off[2]))+(guidler_bearing[1])/2;

                            // cutout pivot to make sure guidler can rotate out
                            translate([0,-guidler_w_cut/2,0])
                            translate(extruder_guidler_mount_off)
                            translate([0,0,-guidler_mount_d/2])
                            rotate([0,90,90])
                            pie_slice(guidler_pivot_r, 130, 270, guidler_w_cut);
                        }
                    }
                    translate(extruder_guidler_mount_off)
                    {
                        difference()
                        {
                            cylindera(d=guidler_mount_d+3*mm, h=guidler_w_cut, orient=[0,1,0], align=[0,0,0]);

                            cylindera(d=guidler_mount_d+3*mm+.1, h=guidler_mount_w, orient=[0,1,0], align=[0,0,0]);
                        }

                        translate(-[0,extruder_b_drivegear_offset[1],0])
                        translate(-[0,extruder_b_mount_thickness/2,0])
                        hull()
                        {
                            cylindera(d=guidler_screws_thread_dia+3*mm, h=guidler_w_cut_ext, orient=[0,1,0], align=[0,-1,0]);
                            translate([0,0,-(guidler_screws_thread_dia+0*mm)])
                            cubea([10,guidler_w_cut_ext,100], align=[1,-1,1]);
                        }
                    }
                }
                // dont cut away the guilder mount
                translate(extruder_guidler_mount_off)
                {
                    cylindera(d=guidler_mount_d, h=guidler_mount_w, orient=[0,1,0]);
                    cubea([guidler_mount_d, guidler_mount_w, 10], align=[0,0,-1]);
                }
            }
        }

        // guidler screws cutouts
        translate(extruder_b_drivegear_offset)
        for(y=[-1,1])
        translate([extruder_b_guidler_screw_offset_x, y*(guidler_screws_distance), extruder_b_guidler_screw_offset_h])
        {
            r= guidler_screws_thread_dia/2 * 1.1;
            cubea([1000, r*2, r]);

            for(v=[-1,1])
                translate([0,0, v*r/2])
                    cylindera(r=r,h=1000, orient=[1,0,0]);

            // guidler screw nuts drop-in slots
            nut_trap_cut(nut=guidler_screws_nut, screw_l=1000, screw_l_extra=1000, trap_axis=[0,0,1], orient=[1,0,0]);
        }

        // guidler mount screw
        translate(extruder_b_drivegear_offset)
        translate(extruder_guidler_mount_off)
        {
            cylindera(d=lookup(ThreadSize, guidler_screws_thread), h=guidler_mount_w+.1, orient=[0,1,0]);
        }

        // cutout for hobbed gear (inner)
        translate(extruder_b_drivegear_offset)
        translate([0,-extruder_drivegear_d_outer/2,0])
        cylindera(
                h=abs(extruder_b_drivegear_offset[1])+extruder_drivegear_h/2+1.1*mm,
                d=extruder_drivegear_d_outer+1.5*mm,
                orient=[0,1,0],
                align=[0,1,0]
                );

        // filament path
        translate(extruder_filapath_offset)
        {
            // above drive gear
            cylindera(h=1000, d=filament_d+.7*mm, orient=[0,0,1], align=[0,0,1]);

            // below drive gear (into hotend)
            cylindera(h=1000, d=4*mm, orient=[0,0,1], align=[0,0,-1]);
        }

        // b bearing cutout
        translate(extruder_b_bearing_offset)
        translate([0,-extruder_b_bearing[2]/2,0])
        cylindera(d=extruder_b_bearing[1]+.3*mm, h=extruder_b_bearing[2]+1000, align=YAXIS, orient=YAXIS);

        // drive gear cutout
        translate(extruder_b_drivegear_offset)
        translate([0,-extruder_drivegear_h/2+1*mm,0])
        cylindera(h=abs(extruder_b_drivegear_offset[1])+extruder_drivegear_h/2+extruder_b_bearing[2]+1*mm, d=extruder_b_bearing[1]+.1*mm, orient=[0,1,0], align=[0,1,0]);

        // extruder shaft
        translate(extruder_b_bearing_offset)
        translate([0,-extruder_b_bearing[2]-.5*mm,0])
        cylindera(h=extruder_shaft_len+.2, d=extruder_shaft_d, orient=[0,1,0], align=[0,1,0]);

        translate(hotend_mount_offset)
        {
            hotend_cut(extend_cut=true);
            hotmount_clamp(part=part);
            hotmount_clamp_cut();
        }

        if(with_sensormount)
        translate(extruder_b_sensormount_offset)
            sensormount(part, align=-YAXIS);
    }
    else if(part=="vit")
    {
        /*// debug to ensure sensor/hotend positions are correct*/
        /*if(false)*/
        translate(-80*ZAXIS)
        {
            translate(v_xy(hotend_mount_offset))
            {
                cylindera();

                translate(sensormount_sensor_hotend_offset)
                cylindera();
            }
        }

        translate(hotend_mount_offset)
        {
            hotmount_clamp();
        }

        translate(extruder_b_bearing_offset)
        {
            bearing(extruder_b_bearing, orient=[0,1,0], align=[0,0,0]);

            translate([0,-extruder_b_bearing[2]/2,0])
            cylindera(h=extruder_shaft_len+.2, d=extruder_shaft_d, orient=[0,1,0], align=[0,1,0]);
        }

        translate(extruder_b_drivegear_offset)
        {
            // drive gear
            cylindera(h=extruder_drivegear_h, d=extruder_drivegear_d_inner, orient=[0,1,0], align=[0,0,0]);
            for(y=[-1,1])
            translate([0,y*extruder_drivegear_h/2,0])
            {
                cylindera(h=extruder_drivegear_h/3, d=extruder_drivegear_d_outer, orient=[0,1,0], align=[0,-y,0]);
            }
        }

        if(with_sensormount)
        translate(extruder_b_sensormount_offset)
        {
            sensormount(part, align=-YAXIS);
        }
    }
}

// Final part
module x_carriage_withmounts(part, show_vitamins=false, beltpath_sign)
{
    if(part==undef)
    {
        difference()
        {
            x_carriage_withmounts(part="pos", show_vitamins=show_vitamins, beltpath_sign=beltpath_sign);
            x_carriage_withmounts(part="neg", show_vitamins=show_vitamins, beltpath_sign=beltpath_sign);
        }

        if(show_vitamins)
        {
            x_carriage(part="vit");
        }
    }
    else if(part=="pos")
    {
        /*hull()*/
        /*union()*/
        {
            x_carriage(part=part, beltpath_sign=beltpath_sign);

            // endstop bumper for physical switch endstop
            if(xaxis_endstop_type == "SWITCH")
            {
                translate([-xaxis_carriage_top_width/2,0,xaxis_end_wz/2])
                rcubea(size=xaxis_endstop_size_switch, align=YAXIS+ZAXIS+XAXIS);
            }
            else if(xaxis_endstop_type == "SN04")
            {
                translate([-xaxis_carriage_top_width/2,0,xaxis_end_wz/2-2*mm])
                rcubea(size=[20*mm,xaxis_endstop_size_SN04[1]+4*mm,xaxis_endstop_size_SN04[2]], align=YAXIS+ZAXIS+XAXIS);
            }

            // extruder A mount
            translate(extruder_offset)
            translate(extruder_offset_a)
            {
                rotate([0,extruder_motor_mount_angle,0])
                for(x=[-1,1])
                for(z=[-1,1])
                {
                    if(x!=1||z!=-1)
                    translate([x*extruder_motor_holedist/2,0,z*extruder_motor_holedist/2])
                    cylindera(d=extruder_b_mount_dia, h=extruder_offset_a[1], orient=[0,1,0], align=[0,-1,0], round_radius=2);
                }
            }
        }
    }
    else if(part=="neg")
    {
        x_carriage(part=part, beltpath_sign=beltpath_sign);

        // rod between extruder part A and B
        translate(extruder_offset)
        {
            cylindera(h=100*mm, d=extruder_shaft_d+5*mm, orient=[0,1,0], align=[0,0,0]);
        }

        // extruder A mount cutout
        translate(extruder_offset)
        translate(extruder_offset_a)
        translate(-[0,extruder_offset_a[1],0])
        {
            rotate([0,extruder_motor_mount_angle,0])
            for(x=[-1,1])
            for(z=[-1,1])
            if(x!=1||z!=-1)
            translate([x*extruder_motor_holedist/2,0,z*extruder_motor_holedist/2])
            translate([0,.1,0])
            screw_cut(
                    nut=NutHexM3,
                    h=extruder_offset_a[1]+.2,
                    head_embed=true,
                    with_nut=false,
                    orient=[0,1,0],
                    align=[0,1,0]
                    );
        }

        // extruder B mount cutout
        translate(extruder_offset)
        translate([0,-extruder_b_mount_thick,0])
        {
            for(pos=extruder_b_mount_offsets)
            translate(pos)
            {
                screw_cut(nut=NutKnurlM3_3_42, h=extruder_b_mount_thick+xaxis_carriage_thickness-xaxis_beltpath_width/2, head_embed=false, orient=[0,1,0], align=[0,1,0]);
            }
        }

        // endstop bumper for physical switch endstop
        if(xaxis_endstop_type == "SWITCH")
        {
        }
        else if(xaxis_endstop_type == "SN04")
        {
            translate([-xaxis_carriage_top_width/2,xaxis_endstop_size_SN04[1]/2+4*mm,xaxis_end_wz/2+8.5*mm-2*mm])
            screw_cut(nut=NutHexM4, h=16*mm, head_embed=true, with_nut=false, orient=XAXIS, align=ZAXIS+XAXIS);
        }
    }
}

// as per E3D spec
hotend_height = 63*mm;
hotend_mount_offset = extruder_filapath_offset + [0,0,-extruder_drivegear_d_outer/2 + -5*mm];
hotend_mount_conn = [hotend_mount_offset, [0,0,1]];
hotend_conn = [[0,21.475,0], [0,1,0]];

module x_extruder_hotend()
{
    import("stl/E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");

    /*translate([0,-20,0])*/
    /*translate(extruder_offset)*/
    /*translate(hotend_mount_offset)*/
    /*cubea([10,10,hotend_height], align=[0,0,-1]);*/
}

guidler_bearing = bearing_MR105;

guidler_mount_off = [0,-guidler_bearing[1]/1.8, -guidler_bearing[1]/1.4];
extruder_guidler_mount_off = [-.3*mm -guidler_mount_off[1]+extruder_drivegear_d_outer/2+guidler_bearing[1]/2,0,guidler_mount_off[2]];

// length of the guidler bearing bolt/screw
guidler_mount_w=guidler_bearing[2];
guidler_mount_d=8*mm;
guidler_bolt_h=guidler_bearing[2]+4*mm;

guidler_w=max(guidler_mount_w+9*mm, guidler_bearing[2]*2.8);
guidler_d=5;
guidler_h=7;
guidler_extra_h_up=guidler_bearing[1]/2+hotmount_clamp_screw_dia/2;

guidler_screws_thread = ThreadM3;
guidler_screws_nut = NutHexM3;
guidler_screws_thread_dia= lookup(ThreadSize, guidler_screws_thread);
guidler_screws_distance=4*mm;
guidler_screws_mount_d = guidler_screws_thread_dia*2+5*mm;

guidler_srew_distance = 10;

house_guidler_screw_h = guidler_screws_thread_dia+10*mm;

extruder_b_guidler_screw_offset_h = 15*mm + guidler_screws_thread_dia -6*mm;
extruder_b_guidler_screw_offset_x = 2*mm;

extruder_b_mount_thickness = 10*mm;
extruder_b_mount_dia = 10*mm;

x_carriage_w = max(xaxis_carriage_top_width, xaxis_carriage_bottom_width, sqrt(2)*(extruder_motor_holedist+extruder_b_mount_dia));

module extruder_guidler(part, show_vit=false)
{
    if(part==undef)
    {
        difference()
        {
            extruder_guidler(part="pos");
            extruder_guidler(part="neg");
        }
        if(show_vit)
        {
            extruder_guidler(part="vit");
        }
    }
    else if(part=="pos")
    {
        union()
        {

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off[1]-guidler_mount_d/2, 0])
                rcubea([guidler_w, guidler_d, guidler_h], align=[0,1,0]);

                // guidler bearing bolt holder
                cylindera(d=guidler_bearing[0]+2*mm,h=guidler_w, orient=[1,0,0], round_radius=2);
            }

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off[1]-guidler_mount_d/2, 0])
                rcubea([guidler_w, guidler_d, guidler_h], align=[0,1,0], extrasize=[0,0,guidler_extra_h_up], extrasize_align=[0,0,1]);

                // guidler mount point
                translate([0,guidler_mount_off[1], guidler_mount_off[2]])
                cylindera(d=guidler_mount_d,h=guidler_w, orient=[1,0,0], round_radius=2);
            }

            hull()
            {
                // guidler main block
                translate([0,guidler_mount_off[1]-guidler_mount_d/2, guidler_h])
                rcubea([guidler_w, guidler_d, 1], align=[0,1,0]);

                // guidler screws mount
                for(i=[-1,1])
                translate([i*(guidler_screws_distance),guidler_mount_off[1]-guidler_mount_d/2, extruder_b_guidler_screw_offset_h])
                cylindera(r=guidler_screws_thread_dia/2*3,h=guidler_d, align=[0,1,0], orient=[0,1,0], round_radius=2);

                // tab above screw mount, for easier open
                translate([0,guidler_mount_off[1]-guidler_mount_d/2, extruder_b_guidler_screw_offset_h+guidler_screws_thread_dia/2*3])
                cylindera(r=5*mm,h=guidler_d/2, align=[0,1,0], orient=[0,1,0], round_radius=2);

            }
        }
    }
    else if(part=="neg")
    {
        // cutouts for clamping screws
        for(i=[-1,1])
        translate([i*(guidler_screws_distance),guidler_mount_off[1]-guidler_mount_d/2, extruder_b_guidler_screw_offset_h])
        {
            // offset for spring
            translate(7*mm*-YAXIS)
            screw_cut(thread=guidler_screws_thread, h=40*mm, orient=YAXIS, align=YAXIS);

            r= guidler_screws_thread_dia/2*1.1;
            cubea([r*2,guidler_d+.2,r], align=[0,1,0]);
            for(v=[-1,1])
            translate([0, -0.1, 0])
            translate([0, 0, v*r/2])
            cylindera(r=r,h=guidler_d+.2, align=[0,1,0], orient=[0,1,0]);
        }

        bearing_cut_w = guidler_bearing[2]+1*mm;

        // port hole to see bearing
        translate([0,-guidler_bearing[1]/2+2*mm,0])
        cubea([bearing_cut_w, 100, guidler_bearing[1]/2+2*mm], align=[0,0,1]);

        // cutout middle mount point pivot
        translate([0,guidler_mount_off[1], guidler_mount_off[2]])
        cylindera(d=guidler_mount_d+2*mm,h=guidler_mount_w+1*mm, orient=[1,0,0]);

        // mount screw hole
        translate([-guidler_w/2,guidler_mount_off[1], guidler_mount_off[2]])
        screw_cut(thread=guidler_screws_thread, h=16*mm, orient=XAXIS, align=XAXIS);

        // guidler bearing screw holder cutout
        union()
        {
            cubea([guidler_bolt_h*1.05+2*e,guidler_bearing[0]*1.05,guidler_bearing[0]*1.05],align=[0,1,0]);

            cylindera(d=guidler_bearing[0]*1.05, h=guidler_bolt_h*1.05, orient=[1,0,0]);
        }

        // guidler bearing cutout
        cylindera(d=guidler_bearing[1]+3*mm, h=guidler_bearing[2]+.5*mm, orient=[1,0,0]);
    }
    else if(part=="vit")
    {
        bearing(guidler_bearing, orient=[1,0,0]);

        // bearing bolt
        cylindera(d=guidler_bearing[0], h=guidler_bolt_h, orient=[1,0,0]);
    }
}

module sensor_LJ12A3_mount(part=undef, height=10,sensormount_thickness=5,screws_spacing=21,screw_offset=[1,0],screws_diameter=4,sensor_spacing=3,sensor_height=[15,40,5],sensor_diameter=12)
{
}

sensor_diameter=12;
sensormount_thickness=5;
sensormount_OD_cut = 0*mm;
sensormount_OD = sensor_diameter+2*sensormount_thickness;
sensormount_h_ = 10;
sensormount_size = [sensormount_OD,sensormount_OD-2*sensormount_OD_cut,sensormount_h_];

sensormount_sensor_hotend_offset = v_xy(extruder_b_sensormount_offset) - v_y(sensormount_size/2) - v_xy(hotend_mount_offset);
echo("Sensor mount offset", sensormount_sensor_hotend_offset);

module sensormount(part=undef, align=[0,0,0])
{
    /*sensormount_cylinder(part=part, align=align);*/
    if(part == "pos")
    {
        cubea();
    }
    else if(part == "neg")
    {
        cubea(s=[11,11,11]);
    }
    if(part == "vit")
    {
        %translate([-6,2,5])
        /*rotate(ZAXIS*-90 + XAXIS*180)*/
        /*rotate(XAXIS*180)*/
        rotate(XAXIS*90)
        rotate(ZAXIS*180)
        import("stl/SN04-N_Inductive_Proximity_Sensor_3528_0.stl");
    }
}

module sensormount_cylinder(part=undef, screws_spacing=21,screw_offset=[1,0],screws_diameter=4,sensor_spacing=3,sensor_height=[15,40,5],align=[0,0,0])
{
    sensor_h = v_sum(sensor_height,2);

    size_align(size=sensormount_size, align=align, orient=[0,0,1])
    {
        if(part == "pos")
        {
            //Sensor mount
            cylindera(d=sensormount_OD, h=sensormount_h_);
            cubea([sensormount_OD,sensormount_OD/2,sensormount_h_], align=[0,1,0]);
        }

        else if(part == "neg")
        {
            translate([0,0,sensormount_h_/2])
            cylindera(d=sensormount_OD+1*mm, h=sensor_h, align=[0,0,1]);

            cylindera(d=sensor_diameter+0,5, h=sensormount_h_+.2);

            translate([0,0,-sensormount_h_/2])
            cylindera(d=sensormount_OD+1*mm, h=sensor_h, align=[0,0,-1]);

            for(y=[-1,1])
                translate([0,y*sensormount_OD/2, 0])
                    cubea([sensor_diameter+sensormount_thickness*2,sensormount_OD_cut,sensormount_h_+2*e],[0,-y,0]);
        }
        else if(part == "vit")
        {
            translate([0,0,sensor_h/2])
            {
                for(e=v_itrlen(sensor_height))
                {
                    hs=v_sum(sensor_height, e);
                    translate([0,0,-hs])
                    {
                        if(e==0||e==2)
                        {
                            color([0.3,.4,0])
                            cylindera(d=sensor_diameter,h=sensor_height[e], align=[0,0,1]);
                        }
                        else
                        {
                            cylindera(d=sensor_diameter,h=sensor_height[e], align=[0,0,1]);
                        }
                    }
                }
            }
        }
    }
}

module e3d_heatsink_duct()
{
    hotend_heatsink_diameter = 25;
    hotend_heatsink_height = 32;
    hotend_heatsink_offset = 16; // offset off bottom of body that heatsink starts

    length = 55;
    width = 40;
    height = hotend_heatsink_offset+hotend_heatsink_height;

    fan_hole_dist = 32;
    m3_hexnut_dia = 6.4;
    m3_hexnut_flat_dia = 5.54;
    m3_hexnut_thickness = 2.4;

    difference() {
        union() {
            //cube([length, width, hotend_heatsink_offset+hotend_heatsink_height]);
            hull() {
                translate([0,0,20]) cube([20,40,height-20]);
                translate([50,5+17.5,height/2+20/2]) cube([5,30,height-20],center=true);
                translate([1,20,20]) rotate([0, 90, 0]) cylinder(r=38/2,h=1,center=true);
            }
        }

        // hotend heatsink hole
        translate([50, 5+17.75, hotend_heatsink_offset]) cylinder(r=hotend_heatsink_diameter/2, hotend_heatsink_height+1);
        translate([50, 5+17.75, 0]) cylinder(r=25/2, hotend_heatsink_offset+1);

        // first portion of fan duct
        difference() {
            hull() {
                translate([-1,20,20]) rotate([0, 90, 0]) cylinder(r=35/2,h=1,center=true);
                translate([50,5+17.5,24+25/2]) cube([20,20,20],center=true);
            }
            /*// support material ribs*/
            /*translate([0,12,0]) cube([length, 1, height]);*/
            /*translate([0,18,0]) cube([length, 1, height]);*/
            /*translate([0,23,0]) cube([length, 1, height]);*/
            /*translate([0,28,0]) cube([length, 1, height]);*/
        }

        // m3 traps for fan
        for (end = [-1,1]) {
            translate([-1,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([0,90,0]) cylinder(r=1.6,h=30,center=true, $fn=7);
            translate([5,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([0,90,0]) rotate([0,0,30]) cylinder(r=m3_hexnut_dia/2,h=m3_hexnut_thickness,center=true,$fn=6);
            translate([5-m3_hexnut_thickness/2,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([end*-90,0,0]) translate([0,-m3_hexnut_flat_dia/2,0]) cube([m3_hexnut_thickness,m3_hexnut_flat_dia,10]);
        }

        if (1) {
            // clearance existing fan mounts
            cube([10,width,8]);

            // hole for clearance for wingnuts
            //translate([10,0,0]) cube([length-10,width+1,10]);

            translate([25, 5+17.75, 9]) cylinder(r=2.5, h=5, center=true);

        }
        else
        {
            // whatever. just get rid of everything for the bottom whatever mm
            //translate([-1,-1,-1]) cube([length+2,width+2,18+1]);
        }

        // clearance for bearing holder
        translate([18,0,0]) cube([40,5,25]);
        translate([10-3,0,0]) cube([50,9,6.5]);

        // TODO; clearance for extruder mounting bolt
    }
}

module beltpath(part, with_tensioner=true)
{
    belt_t2 = belt_t2_thickness(xaxis_belt) + .2*mm;
    tension_screw_nut = NutHexM3;
    tension_screw_thread = ThreadM3;
    tension_screw_dia = lookup(ThreadSize, tension_screw_thread);
    angle_screw_thread = ThreadM4;
    angle_screw_dia = 3.25*mm;
    width = max(xaxis_carriage_top_width,55*mm);
    height = belt_t2*8;

    if(part==undef)
    {
        difference()
        {
            beltpath("pos", with_tensioner=with_tensioner);
            beltpath("neg", with_tensioner=with_tensioner);
        }
    }
    else if(part=="pos")
    {
        translate([0, -xaxis_carriage_beltpath_offset_y, 0])
        rcubea([width, xaxis_carriage_thickness, height], align=[0,1,0]);

        rcubea([width, xaxis_belt_width, height], extrasize=[0,angle_screw_dia+3*mm,0], extrasize_align=-YAXIS);
    }
    else if(part=="neg")
    {
        translate(-xaxis_pulley_inner_d/2*ZAXIS)
        {
            if(with_tensioner)
            {
                translate([0,0,belt_t2/4])
                cubea([1000, xaxis_belt_width+.1, belt_t2]);

                /*translate([0,0,angle_screw_dia/2])*/
                {
                    hull()
                    {
                        for(i=[-1,1])
                        translate(i*11*mm*XAXIS)
                        cylindera(d=angle_screw_dia+belt_t2, h=xaxis_belt_width+.1, orient=YAXIS);
                    }

                    hull()
                    {
                        /*translate(*8*mm*XAXIS)*/
                        for(i=[-1,1])
                        translate(i*10*mm*XAXIS)
                        translate(-xaxis_belt_width*YAXIS)
                        cylindera(d=angle_screw_dia+.2, h=10000, orient=YAXIS, align=YAXIS);
                    }

                    translate([0,-xaxis_belt_width,0])
                    {
                        // cut for angle screw
                        translate(-1*2*mm*YAXIS)
                        translate(-1*11*mm*XAXIS)
                        cylindera(d=angle_screw_dia+.2*mm, h=1000, orient=XAXIS, align=XAXIS);

                        translate(-1*11*mm*XAXIS)
                        nut_trap_cut(nut=tension_screw_nut, orient=-XAXIS, trap_axis=YAXIS);

                        // cut for tension screw
                        translate(-1*25*mm*XAXIS)
                        /*translate(-width/2*XAXIS)*/
                        screw_cut(nut=tension_screw_nut, h=25*mm, with_head=true, head_embed=true, with_nut=false, orient=XAXIS, align=XAXIS);
                    }
                }

            }
            else
            {
                cubea([1000, xaxis_belt_width+3*mm, belt_t2*1.8], extrasize=[0,0,1*mm], extrasize_align=ZAXIS);
            }

            translate(xaxis_pulley_inner_d*ZAXIS)
            cubea([1000, xaxis_belt_width+3*mm, belt_t2*2]);
        }
    }
    else if(part=="vit")
    {
        translate(-xaxis_pulley_inner_d/2*ZAXIS)
        if(with_tensioner)
        {
            // 90 angle metal screw
            translate([0,0,angle_screw_dia/2])
            {
                translate([0,-angle_screw_dia/2,0])
                cylindera(d=angle_screw_dia+.2*mm, h=25*mm, orient=XAXIS, align=XAXIS);
                cylindera(d=angle_screw_dia+.2*mm, h=5*mm, orient=YAXIS, align=YAXIS+XAXIS);

                /*translate([0,-xaxis_belt_width,0])*/
                /*{*/
                    /*translate(-1*11*mm*XAXIS)*/
                    /*#screw(thread=tension_screw_thread, orient=XAXIS, align=-XAXIS);*/
                /*}*/
            }
        }
    }
}

module test_beltpath(x)
{
    difference()
    {
        for(z=xaxis_beltpath_z_offsets)
        translate([0, xaxis_carriage_beltpath_offset_y, z])
        mirror([0,0,sign(z)<1?1:0])
        {
            beltpath(part="pos", with_tensioner=sign(z)==x);
        }

        for(z=xaxis_beltpath_z_offsets)
        translate([0, xaxis_carriage_beltpath_offset_y, z])
        mirror([0,0,sign(z)<1?1:0])
        {
            beltpath(part="neg", with_tensioner=sign(z)==x);
        }
    }

    /*for(z=xaxis_beltpath_z_offsets)*/
    /*translate([0, xaxis_carriage_beltpath_offset_y, z])*/
    /*mirror([0,0,sign(z)<1?1:0])*/
    /*{*/
        /*%beltpath(part="vit", with_tensioner=sign(z)==x);*/
    /*}*/
}

// flip for printing
/*e3d_heatsink_duct();*/

// extruder guidler mount point
extruder_conn_guidler = [ extruder_guidler_mount_off, [0,1,0]];

// guidler connection point
extruder_guidler_conn_mount = [ guidler_mount_off,  [1,0,0]];
extruder_guidler_roll = 45;

if(false)
attach(extruder_conn_guidler, extruder_guidler_conn_mount, extruder_guidler_roll)
{
    extruder_guidler(show_extras=true);
}

if(false)
extruder_a(show_vitamins=true);

alpha = 0.7;
/*alpha = 1;*/
color_xcarriage = [0.3,0.5,0.3, alpha];
color_hotend = [0.8,0.4,0.4, alpha];
color_extruder = [0.2,0.6,0.9, alpha];
color_guidler = [0.4,0.5,0.8, alpha];
color_filament = [0,0,0, alpha];
                // belt path cutout

explode=[0,0,0];
/*explode=[0,10,0];*/

module x_carriage_full(show_vitamins=true)
{
    x_carriage_withmounts(show_vitamins=show_vitamins);

    x_carriage_extruder(show_vitamins=show_vitamins);
}

module x_carriage_extruder(show_vitamins=false, with_sensormount=false)
{
    translate(extruder_offset)
    {
        translate([explode[0],explode[1],explode[2]])
        translate(extruder_offset_a)
        {
            extruder_a();
            if(show_vitamins)
            extruder_a(part="vit");
        }

        translate([explode[0],-explode[1],explode[2]])
        {
            difference()
            {
                extruder_b(part="pos", with_sensormount=with_sensormount);

                extruder_b(part="neg", with_sensormount=with_sensormount);

                /*translate([0,-21,0])*/
                /*cubea([1000,1000,1000], align=[0,-1,0]);*/
            }
        }

        if(show_vitamins)
        translate([explode[0],-explode[1],explode[2]])
        extruder_b(part="vit", with_sensormount=with_sensormount);

        translate([explode[0],-explode[1],explode[2]])
        translate(extruder_b_drivegear_offset)
        attach(extruder_conn_guidler, extruder_guidler_conn_mount, extruder_guidler_roll)
        {
            extruder_guidler(show_vit=true);
        }

        /*translate([explode[0],-explode[1],explode[2]])*/
        /*translate([-95,53,20])*/
        /*rotate([-152,0,0])*/
        /*import("stl/E3D_40_mm_Duct.stl");*/

        /*translate([explode[0],-explode[1],explode[2]])*/
        /*translate([-123.5,78.5,-54])*/
        /*rotate([0,0,-90])*/
        /*import("stl/E3D_30_mm_Duct.stl");*/

        translate([explode[0],-explode[1],explode[2]])
        color(color_hotend)
        attach(hotend_mount_conn, hotend_conn, roll=-90)
        {
            x_extruder_hotend();
        }

        translate([explode[0],-explode[1],explode[2]])
        //filament path
        color(color_filament)
        translate(extruder_filapath_offset)
        cylindera(h=1000, d=1.75*mm, orient=[0,0,1], align=[0,0,0]);
    }
}

module part_x_carriage_left()
{
    rotate([0,0,180])
    rotate([90,0,0])
    x_carriage_withmounts(beltpath_sign=-1);
}

module part_x_carriage_left_extruder_a()
{
    rotate([-90,0,0])
    extruder_a();
}

module part_x_carriage_left_extruder_b()
{
    rotate([-90,0,0])
    extruder_b(with_sensormount=true);
}

module part_x_carriage_right()
{
    rotate([0,0,180])
    rotate([90,0,0])
    mirror([1,0,0])
    x_carriage_withmounts(beltpath_sign=1);
}

module part_x_carriage_right_extruder_a()
{
    rotate([-90,0,0])
    mirror([1,0,0])
    extruder_a();
}

module part_x_carriage_right_extruder_b()
{
    rotate([-90,0,0])
    mirror([1,0,0])
    extruder_b(with_sensormount=false);
}

module part_x_carriage_hotmount_clamp()
{
    translate([0, 0, hotmount_d_h[1][1]/2])
    translate([0, 0, 0+hotmount_d_h[0][1]+hotmount_d_h[1][1]/2])
    hotmount_clamp();
}

module part_x_carriage_extruder_guidler()
{
    guidler_conn_layflat = [ [0, guidler_mount_off[1]-guidler_mount_d/2, guidler_mount_off[2]],  [0,-1,0]]; 
    attach([[0*mm,0*mm,0],[0,0,-1]], guidler_conn_layflat)
    {
        extruder_guidler(show_vit=false);
    }
}

if(false)
{
    /*for(x=[-1])*/
    for(x=[-1,1])
    translate(x*40*mm*XAXIS)
    mirror([x<0?0:1,0,0])
    {
        x_carriage_withmounts(show_vitamins=false, beltpath_sign=x);

        x_carriage_extruder(show_vitamins=true, with_sensormount=x<0);

        /*mirror([x>0?0:1,0,0])*/
        /*test_beltpath(x=x);*/
    }

    for(z=[-1,1])
    for(z=xaxis_beltpath_z_offsets)
    translate([-main_width/2, xaxis_carriage_beltpath_offset_y, z])
    rotate([90,0,0])
    belt_path(main_width, xaxis_belt_width, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);

    /*for(offset=[0,1])*/
    /*translate([offset*60,0,0])*/
    /*rotate([90,0,0])*/
    /*x_carriage_withmounts(show_vitamins=false, beltpath_sign=offset);*/

    for(x=[-1,1])
    translate([x*200,0,0])
    translate([0, xaxis_carriage_beltpath_offset_y, 0])
    mirror([max(0,x),0,0])
    {
        xaxis_end(with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false, with_xrod_adjustment=true);
    }
}
