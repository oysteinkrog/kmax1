use <thing_libutils/misc.scad>
use <thing_libutils/bearing.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/timing-belts.scad>
use <thing_libutils/bearing-linear.scad>
use <x-carriage.scad>
use <z-motor-mount.scad>
include <z-motor-mount.h>

include <thing_libutils/bearing_data.scad>
include <thing_libutils/pulley.scad>
include <thing_libutils/materials.scad>

include <x-end.h>

module xaxis_end_body(part, with_motor, beltpath_index=0, nut_top=false, with_xrod_adjustment=true)
{
    nut_h = zaxis_nut[4];
    bearing_sizey = zaxis_bearing_OD + 5*mm;

    xaxis_rod_d_support = xaxis_rod_d+5*mm;
    rod_outer_padding_support = with_xrod_adjustment?15*mm:5*mm;

    if(part==undef)
    {
        difference()
        {
            xaxis_end_body(part="pos", with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);
            xaxis_end_body(part="neg", with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);
        }
        %xaxis_end_body(part="vit", with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        if(with_motor)
        {
            screw_dist = lookup(NemaDistanceBetweenMountingHoles, xaxis_motor);
            for(x=[-1,1])
            for(z=[-1,1])
            tz(xaxis_beltpath_z_offsets[beltpath_index])
            translate(xaxis_end_motor_offset)
                translate([x*screw_dist/2, 0, z*screw_dist/2])
                cylindera(d=lookup(ThreadSize,xaxis_motor_thread)+4*mm, h=motor_mount_wall_thick, orient=Y, align=[0,-1,0], round_r=2);
            }

        // nut mount
        mirror([0,0,nut_top?1:0])
        translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        {
            // main nut support
            rcylindera(h=zaxis_nut[4], d=zaxis_nut[0]+5*mm, align=Z);

            // nut screw holes support
            rotate(Z*90)
            for(x=[-1,1])
            translate([x*zaxis_nut[5], 0, 0])
            rcylindera(h=zaxis_nut[4], d=lookup(ThreadSize, zaxis_nut[6])+5*mm, align=Z);

            // lead screw
            // ensure some support for the leadscrew cutout all the way to the top
            /*rcylindera(h=xaxis_end_wz, d=zaxis_nut[2]*2, align=Z);*/
        }


        // x axis rod holders
        for(z=[-1,1])
        tz(z*(xaxis_rod_distance/2))
        tx(xaxis_end_width_right(with_motor))
        rcylindera(h=xaxis_end_width_right(with_motor)+xaxis_end_width(with_motor)+rod_outer_padding_support, d=xaxis_rod_d_support, orient=X, align=-X);

        // endstops mount support
        if(xaxis_endstop_type == "SWITCH")
        {
            t(xaxis_endstop_pos(with_motor))
            rcubea(xaxis_endstop_size_switch, align=-X-Y);
        }
        else if(xaxis_endstop_type == "SN04")
        {
            t(xaxis_endstop_pos(with_motor))
            translate(xaxis_endstop_offset_SN04)
            rcubea(xaxis_endstop_size_SN04, align=-XAXIS-ZAXIS);
        }

        // belt idler screw cut support
        for(z=[-1,1])
        for(y=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([0,y*-xaxis_beltpath_width/2,0])
            cylindera(orient=Y, d=15*mm, h=7*mm, align=-y*Y);
        }
    }
    else if(part=="neg")
    {
        for(z=[-1,1])
        tz(z*(xaxis_rod_distance/2))
        {
            tx(with_xrod_adjustment?-2*mm:0*mm)
            tx(zaxis_rod_screw_distance_x)
            cylindera(h=xaxis_rod_l, d=xaxis_rod_d+.4*mm, orient=X, align=X);

            tx(-xaxis_end_width(with_motor)-xaxis_end_width_right(with_motor))
            if(with_xrod_adjustment)
            {
                tx(-2*mm)
                nut_trap_cut(nut=NutHexM4, trap_offset=8*mm, screw_l=12*mm, screw_offset=2*mm, trap_axis=Y, cut_screw=true, orient=X, align=X);
            }
        }
    }
    else if(part=="vit")
    {
    }
}

module xaxis_end(part, with_motor=false, stop_x_rods=true, beltpath_index=0, show_motor=false, nut_top=false, show_nut=false, show_rods=false, show_bearings=false, with_xrod_adjustment=true)
{
    nut_h = zaxis_nut[4];
    extra_size = with_motor?0*mm:0*mm;
    extra_align = 1;

    if(part==undef)
    {
        difference()
        {
            xaxis_end(part="pos", with_motor=with_motor, stop_x_rods=stop_x_rods, beltpath_index=beltpath_index, show_motor=show_motor, nut_top=nut_top, show_nut=show_nut, show_rods=show_rods, show_bearings=show_bearings, with_xrod_adjustment=with_xrod_adjustment);
            xaxis_end(part="neg", with_motor=with_motor, stop_x_rods=stop_x_rods, beltpath_index=beltpath_index, show_motor=show_motor, nut_top=nut_top, show_nut=show_nut, show_rods=show_rods, show_bearings=show_bearings, with_xrod_adjustment=with_xrod_adjustment);
        }
        %xaxis_end(part="vit", with_motor=with_motor, stop_x_rods=stop_x_rods, beltpath_index=beltpath_index, show_motor=show_motor, nut_top=nut_top, show_nut=show_nut, show_rods=show_rods, show_bearings=show_bearings, with_xrod_adjustment=with_xrod_adjustment);
    }
    else if(part=="pos")
    {
        // projection against z, ensure easy print
        material(Mat_Plastic)
        proj_extrude_axis(axis=Z, offset=xaxis_end_wz/2)
        {
            xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);

            // z smooth bearing mounts support
            translate(-xaxis_zaxis_distance_y*Y)
            for(z=[-1,1])
            translate(-z*Z*(xaxis_end_wz/2))
            {
                linear_bearing_mount(
                    part=part,
                    bearing=zaxis_bearing,
                    ziptie_type=ziptie_type,
                    ziptie_bearing_distance=ziptie_bearing_distance,
                    orient=Z*z,
                    align=Z*z,
                    with_zips=true,
                    offset_flange=true,
                    mount_dir_align=xaxis_z_bearing_mount_dir,
                    mount_style=xaxis_z_bearing_mount_style
                    );
            }

        }
    }
    else if(part=="neg")
    {
        xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);

        // belt idler screw cut
        for(z=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([0, -xaxis_beltpath_width/2 - 7*mm, 0])
            {
                screw_cut(nut=NutHexM5, h=xaxis_beltpath_width+13*mm, with_nut=true, orient=Y, align=Y);
            }
        }

        //endstop mount screw cuts
        if(xaxis_endstop_type == "SWITCH")
        {
            t(xaxis_endstop_pos(with_motor))
            translate(xaxis_endstop_screw_offset_switch)
            for(z=[-1,1])
            translate([-5*mm, xaxis_endstop_size_switch.y, z*9.5*mm/2])
            {
                screw_cut(nut=NutHexM2_5, h=10*mm, head_embed=false, with_head=true, with_nut=false, orient=-Y, align=-Y);
            }
        }
        else if(xaxis_endstop_type == "SN04")
        {
            t(xaxis_endstop_pos(with_motor))
            translate(xaxis_endstop_screw_offset_SN04)
            for(y=[-1,1])
            translate([-0*mm,y*10.5*mm/2,xaxis_endstop_size_SN04[2]])
            {
                translate(xaxis_endstop_offset_SN04)
                screw_cut(nut=NutHexM3, h=20*mm, head_embed=false, with_head=true, with_nut=false, orient=-Z, align=-Z);
            }
        }

        xaxis_end_beltpath(height=xaxis_beltpath_height_body, width=xaxis_beltpath_width);

        // z smooth bearing mounts cut
        translate(-xaxis_zaxis_distance_y*Y)
        for(z=[-1,1])
        translate(-z*Z*(xaxis_end_wz/2))
        {
            linear_bearing_mount(
                part=part,
                bearing=zaxis_bearing,
                ziptie_type=ziptie_type,
                ziptie_bearing_distance=ziptie_bearing_distance,
                orient=Z*z,
                align=Z*z,
                with_zips=true,
                offset_flange=true,
                mount_dir_align=xaxis_z_bearing_mount_dir,
                mount_style=xaxis_z_bearing_mount_style
                );
        }

        if(with_motor)
        {
            screw_dist = lookup(NemaDistanceBetweenMountingHoles, xaxis_motor);

            // axle
            translate([0,0,xaxis_beltpath_z_offsets[beltpath_index]])
            translate(xaxis_end_motor_offset)
            {
                round_d=1.1*lookup(NemaRoundExtrusionDiameter, xaxis_motor);
                translate([0, .1, 0])
                translate(Y)
                teardrop(d=round_d,h=motor_mount_wall_thick, orient=Y, align=-Y, roll=90, truncate=0.9);

                // motor axle
                translate([0, .1, 0])
                cylindera(d=1.2*lookup(NemaAxleDiameter, xaxis_motor), h=lookup(NemaFrontAxleLength, xaxis_motor)+3*mm, orient=Y, align=Y);

                // bearing for offloading force on motor shaft
                translate([0, -2.5*mm-xaxis_pulley[1]-.1, 0])
                scale(1.03)
                cylindera(d=bearing_MR105[1], h=6*mm, orient=Y, align=[0,-1,0]);

                for(x=[-1,1])
                for(z=[-1,1])
                translate([0,-xaxis_end_motor_offset[1],0])
                translate([x*screw_dist/2, -(xaxis_beltpath_width/2+3*mm), z*screw_dist/2])
                {
                    if(!(x==1 && z == (beltpath_index==0?1:-1)))
                    screw_cut(xaxis_motor_nut, h=25, with_nut=false, orient=Y, align=Y);
                }
            }

        }

        // nut mount
        mirror([0,0,nut_top?1:0])
        tx(zaxis_rod_screw_distance_x)
        ty(-xaxis_zaxis_distance_y)
        tz(-xaxis_end_wz/2)
        rotate(90*Z)
        {
            union()
            {
                translate([0,0,-.1])
                {
                    // nut
                    cylindera(h=nut_h+1, d=zaxis_nut[0]*1.05, align=Z);

                    // lead screw
                    translate([0,0,-.1])
                    cylindera(h=lookup(NemaFrontAxleLength,zaxis_motor), d=zaxis_nut[2]*1.5, align=Z);

                    for(i=[-1,1])
                    translate([i*zaxis_nut[5], 0, -zaxis_nut[3]])
                    screw_cut(thread=zaxis_nut[6], h=16*mm, with_nut=false, orient=Z, align=Z);
                }
            }
        }
    }
    else if(part=="vit")
    {
        xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);

        translate(-xaxis_zaxis_distance_y*Y)
        for(z=[-1,1])
        translate(-z*Z*(xaxis_end_wz/2))
        {
            linear_bearing_mount(
                part=part,
                bearing=zaxis_bearing,
                ziptie_type=ziptie_type,
                ziptie_bearing_distance=ziptie_bearing_distance,
                orient=Z*z,
                align=Z*z,
                with_zips=true,
                offset_flange=true,
                mount_dir_align=xaxis_z_bearing_mount_dir,
                mount_style=xaxis_z_bearing_mount_style
                );
        }

        if(with_motor)
        {
            translate([0,0,xaxis_beltpath_z_offsets[beltpath_index]])
            translate(xaxis_end_motor_offset)
            {
                // 1mm due to motor offset
                translate([0,-1*mm,0])
                {
                    // 1mm between pulley and motor
                    translate([0,-1*mm,0])
                    pulley(xaxis_pulley, flip=false, orient=Y, align=[0,-1,0]);

                    if(show_motor)
                    {
                        motor(model=xaxis_motor, size=NemaMedium, dual_axis=false, orient=-Y);
                    }
                }
            }
        }

        //endstop
        if($show_vit)
        {
            if(xaxis_endstop_type == "SWITCH")
            {
                t(xaxis_endstop_pos(with_motor))
                difference()
                {
                    union()
                    {
                    material(Mat_PlasticBlack)
                        rcubea(xaxis_endstop_size_switch, align=-X+Y);

                        color("red")
                        tz(-xaxis_endstop_size_switch.z/2+6*mm)
                        ty(xaxis_endstop_size_switch.y/2)
                        cubea([1.5*mm, 3*mm, 1*mm], align=X);
                    }

                    translate(xaxis_endstop_screw_offset_switch)
                    for(z=[-1,1])
                    translate([-5*mm, 0, z*9.5*mm/2])
                    screw(nut=NutHexM2_5, with_nut=false, h=10*mm, orient=-Y, align=Y);
                }
            }
            else if(xaxis_endstop_type == "SN04")
            {
                t(xaxis_endstop_pos(with_motor))
                translate(xaxis_endstop_offset_SN04)
                translate([-36,-9,0])
                rotate(ZAXIS*-90)
                import("stl/SN04-N_Inductive_Proximity_Sensor_3528_0.stl");
            }
        }

        // belt idler pulley screw
        for(z=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([0, -xaxis_beltpath_width/2 - 7*mm, 0])
            {
                screw(nut=NutHexM5, h=25*mm, with_nut=true, orient=Y, align=Y);
            }
        }

        for(z=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            pulley(xaxis_idler_pulley, orient=Y);
        }

        if(show_nut)
        {
            mirror([0,0,nut_top?1:0])
            tx(zaxis_rod_screw_distance_x)
            ty(-xaxis_zaxis_distance_y)
            tz(-xaxis_end_wz/2-zaxis_nut[3])
            xaxis_end_znut();
        }


        if(show_rods)
        {
            for(z=[-1,1])
            tz(z*xaxis_rod_distance/2)
            ty(-xaxis_zaxis_distance_y)
            cylindera(d=zaxis_rod_d, h=zaxis_rod_l, orient=Z);
        }
    }
}

module xaxis_end_beltpath(height, width, length = 1000, align=N, orient=X)
{
    hull()
    for(z=[-1,1])
    translate([0,0,z*height/2])
    teardrop(h=length, d=width, orient=orient, align=align, roll=-180*min(0,z), truncate=1);
}

module xaxis_end_znut()
{
    difference()
    {
        material(zaxis_nut_mat)
        union()
        {
            cylindera(d=zaxis_nut[1], h=zaxis_nut[3], orient=Z, align=Z);
            cylindera(d=zaxis_nut[0], h=zaxis_nut[4], orient=Z, align=Z);
        }

        translate([0,0,-.1])
        cylindera(d=zaxis_nut[2], h=zaxis_nut[4]+.2, orient=Z, align=Z);
    }
}


if(false)
{
    /*sides = [-1,1];*/
    sides = [-1];
    // x axis
    {
        /*if(!$preview_mode)*/
        {
            for(z=xaxis_beltpath_z_offsets)
            tz(z)
            ty(xaxis_zaxis_distance_y)
            tx(-sign(z)*(-main_width/2-zmotor_mount_rod_offset_x+xaxis_end_motor_offset[0]))
            rotate(90*X)
            belt_path(
                len=main_width+xaxis_end_motor_offset[0],
                belt_width=xaxis_belt_width,
                belt=xaxis_belt,
                pulley_d=xaxis_pulley_inner_d,
                orient=X, align=-sign(z)*X);
        }

        // x carriage
        for(x=sides)
        translate(x*40*mm*X)
        mirror([x<0?0:1,0,0])
        {
            x_carriage_withmounts(beltpath_sign=x, with_sensormount=x<0);

            x_carriage_extruder();
        }

        // x smooth rods
        color(color_rods)
        for(z=[-1,1])
        translate([xaxis_rod_offset_x,xaxis_zaxis_distance_y,z*(xaxis_rod_distance/2)])
        cylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=X);

        tz(-100*mm)
        for(x=sides)
        tx(x*(main_width/2))
        mirror([x==-1?0:1,0,0])
        {
            tx(zmotor_mount_rod_offset_x)
            tx(-x*(extrusion_size+zaxis_rod_d/2))
            tz(zaxis_motor_offset_z)
            mirror(X)
            zaxis_motor_mount(show_motor=true);

            // z smooth rods
            tz(zaxis_motor_offset_z-80*mm)
            material(Mat_Chrome)
            cylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=Z);
        }

        for(x=sides)
        tx(x*(main_width/2))
        ty(xaxis_zaxis_distance_y)
        mirror([max(0,x),0,0])
        {
            xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);

            xaxis_end_bucket();
            }
        }

}

if(false)
{
    for(x=[-1,1])
    translate([x*100*mm,0,xaxis_end_wz/2])
    mirror([max(0,x),0,0])
    {
        xaxis_end(with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false, with_xrod_adjustment=true);
    }
}

module part_x_end_right()
{
    x=1;
    translate([0,0,xaxis_end_wz/2])
    mirror([max(0,x),0,0])
    xaxis_end(with_motor=true, beltpath_index=max(0,x), with_xrod_adjustment=true);
}

module part_x_end_left()
{
    x=-1;
    translate([0,0,xaxis_end_wz/2])
    mirror([max(0,x),0,0])
    xaxis_end(with_motor=true, beltpath_index=max(0,x), with_xrod_adjustment=true);
}
