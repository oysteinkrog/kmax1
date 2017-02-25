include <MCAD/motors.scad>
include <MCAD/stepper.scad>

include <config.scad>
include <thing_libutils/misc.scad>
include <thing_libutils/bearing.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/timing-belts.scad>

motor_mount_wall_thick = xaxis_pulley[1] - xaxis_pulley[0]/2 + 4*mm;
xaxis_end_pulley_offset = 41*mm;
xaxis_end_motorsize = lookup(NemaSideSize,xaxis_motor);
xaxis_end_motor_offset=[xaxis_end_motorsize/2+zaxis_bearing[1]/2+1*mm,motor_mount_wall_thick-2*mm,0];
xaxis_end_wz = xaxis_rod_distance+xaxis_rod_d+5*mm;

xaxis_endstop_size_switch = [10.3*mm, 20*mm, 6.3*mm];
xaxis_endstop_screw_offset_switch = [-2.45*mm, 0*mm, 0*mm];

xaxis_endstop_size_SN04 = [34.15*mm, 18.15*mm, 17.8*mm];
xaxis_endstop_screw_offset_SN04 = [-27.5*mm, 0*mm, 0*mm];
xaxis_endstop_offset_SN04 = [-3*mm, 0*mm, 0*mm];

function xaxis_end_width(with_motor) = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : zaxis_bearing[1]/2+zaxis_nut[1];

module xaxis_end_body(part, with_motor, beltpath_index=0, nut_top=false, with_xrod_adjustment=false)
{
    nut_h = zaxis_nut[4];
    bearing_sizey = zaxis_bearing[1] + 5*mm;

    xaxis_end_xrod_offset_z = xaxis_rod_l/2 - (main_width/2 + zmotor_mount_rod_offset_x);
    xaxis_rod_d_support = xaxis_rod_d+5*mm;
    xaxis_rod_l_support = xaxis_end_xrod_offset_z + 8*mm + (with_xrod_adjustment?8*mm:0);

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
    {
        if(with_motor)
        {
            screw_dist = lookup(NemaDistanceBetweenMountingHoles, xaxis_motor);
            for(x=[-1,1])
            for(z=[-1,1])
            translate([0,0,xaxis_beltpath_z_offsets[beltpath_index]])
            translate(xaxis_end_motor_offset)
            {
                translate([x*screw_dist/2, 0, z*screw_dist/2])
                cylindera(d=lookup(ThreadSize,xaxis_motor_thread)+4*mm, h=motor_mount_wall_thick, orient=[0,1,0], align=[0,-1,0], rounding_radius=2);
            }
        }

        // nut mount
        mirror([0,0,nut_top?1:0])
        translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        {
            // main nut support
            cylindera(h=zaxis_nut[4], d=zaxis_nut[0]+5*mm, align=[0,0,1], round_radius=2);

            // nut screw holes support
            for(x=[-1,1])
            translate([x*zaxis_nut[5], 0, 0])
            cylindera(h=zaxis_nut[4], d=lookup(ThreadSize, zaxis_nut[6])+5*mm, align=[0,0,1], round_radius=2);

            // lead screw
            // ensure some support for the leadscrew cutout all the way to the top
            /*cylindera(h=xaxis_end_wz, d=zaxis_nut[2]*2, align=[0,0,1], round_radius=2);*/
        }

        // x axis rod holders
        for(z=[-1,1])
        translate([0,0,z*(xaxis_rod_distance/2)])
        cylindera(h=xaxis_rod_l_support, d=xaxis_rod_d_support, orient=[1,0,0], align=[-1,0,0], round_radius=2);

        /*if(xaxis_endstop_type == "SWITCH")*/
        {
            translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
            {
                rcubea(xaxis_endstop_size_switch, align=[-1,0,-1]);
            }
        }
        /*else if(xaxis_endstop_type == "SN04")*/
        {
            translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
            {
                translate(xaxis_endstop_offset_SN04)
                rcubea(xaxis_endstop_size_SN04, align=[-1,0,-1]);
            }
        }

        // support around z axis bearings
        translate([0, -xaxis_zaxis_distance_y, 0])
        cylindera(h=xaxis_end_wz,d=bearing_sizey, orient=[0,0,1], align=[0,0,0], round_radius=2);

        // belt idler screw cut support
        for(z=[-1,1])
        for(y=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([0,y*-xaxis_beltpath_width/2,0])
            cylindera(orient=YAXIS, d=15*mm, h=7*mm, align=-y*YAXIS);
        }
    }
    else if(part=="neg")
    {
        // cut support around z axis bearings
        translate([0, -xaxis_zaxis_distance_y, 0])
        translate([0,0,.1])
        cubea([bearing_sizey+.1, bearing_sizey+.2, xaxis_end_wz+.4], orient=[0,0,1], align=[0,-1,0]);

        // x smooth rods
        for(z=[-1,1])
        translate([0,0*mm,z*(xaxis_rod_distance/2)])
        {
            xoff = - xaxis_end_xrod_offset_z -(with_xrod_adjustment?6:0)*mm;
            translate([xoff,0,0])
            cylindera(h=abs(xoff)+xaxis_end_width(with_motor)+1,d=xaxis_rod_d+.5*mm, orient=[1,0,0], align=[1,0,0]);

            if(with_xrod_adjustment)
            {
                translate([-xaxis_rod_l_support+5*mm,0,0])
                nut_trap_cut(nut=NutHexM4, trap_axis=YAXIS, orient=-XAXIS, align=XAXIS);

                translate([-xaxis_rod_l_support-7*mm,0,0])
                cylindera(d=10, h=10, orient=XAXIS);
            }
        }
    }
    else if(part=="vit")
    {
    }
}

module xaxis_end(part, with_motor=false, stop_x_rods=true, beltpath_index=0, show_motor=false, nut_top=false, show_nut=false, show_rods=false, show_bearings=false, with_xrod_adjustment=false)
{
    nut_h = zaxis_nut[4];
    extrasize = with_motor?0*mm:0*mm;
    extrasize_align = 1;

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
        hull()
        {
            xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);

            // projection against z, ensure easy print
            translate([0,0,-xaxis_end_wz/2])
                linear_extrude(1)
                projection(cut=false)
                xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);
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
                screw_cut(nut=NutHexM5, h=xaxis_beltpath_width+13*mm, with_nut=true, orient=[0,1,0], align=[0,1,0]);
            }
        }

        //endstop mount screw cuts
        /*if(xaxis_endstop_type == "SWITCH")*/
        {
            translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
            translate(xaxis_endstop_screw_offset_switch)
            for(y=[-1,1])
            translate([-5*mm,y*9.5*mm/2,xaxis_endstop_size_switch[2]])
            {
                screw_cut(nut=NutHexM2_5, h=10*mm, embed_head=false, with_head=true, with_nut=false, orient=[0,0,-1], align=[0,0,-1]);
            }
        }
        /*else if(xaxis_endstop_type == "SN04")*/
        {
            translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
            translate(xaxis_endstop_screw_offset_SN04)
            for(y=[-1,1])
            translate([-0*mm,y*10.5*mm/2,xaxis_endstop_size_SN04[2]])
            {
                translate(xaxis_endstop_offset_SN04)
                screw_cut(nut=NutHexM3, h=20*mm, embed_head=false, with_head=true, with_nut=false, orient=[0,0,-1], align=[0,0,-1]);
            }
        }

        xaxis_end_beltpath(height=xaxis_beltpath_height_body, width=xaxis_beltpath_width);

        // z smooth bearing mounts
        for(z=[-1,1])
        {
            translate([0,0,z*(xaxis_end_wz/2-2*mm)])
            translate([0, -xaxis_zaxis_distance_y, 0])
            {
                bearing_mount_holes(
                        bearing_type=zaxis_bearing,
                        ziptie_type=ziptie_type,
                        ziptie_bearing_distance=ziptie_bearing_distance,
                        orient=ZAXIS,
                        align=[0,0,-z],
                        with_zips=true
                        );
                /*hull()*/
                /*{*/
                    /*cylindera(d=zaxis_bearing[1],h=xaxis_end_wz);*/

                    /*translate([-5*cm,0,0])*/
                    /*cylindera(d=zaxis_bearing[1],h=xaxis_end_wz);*/
                /*}*/
            }
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
                translate([0,1,0])
                teardrop(d=round_d,h=motor_mount_wall_thick, tear_orient=[0,0,1], orient=[0,1,0], align=[0,-1,0], roll=90, truncate=0.9);

                // motor axle
                translate([0, .1, 0])
                cylindera(d=1.2*lookup(NemaAxleDiameter, xaxis_motor), h=lookup(NemaFrontAxleLength, xaxis_motor)+3*mm, orient=[0,1,0], align=[0,1,0]);

                // bearing for offloading force on motor shaft
                translate([0, -2.5*mm-xaxis_pulley[1]-.1, 0])
                scale(1.03)
                cylindera(d=bearing_MR105[1], h=6*mm, orient=[0,1,0], align=[0,-1,0]);

                for(x=[-1,1])
                for(z=[-1,1])
                translate([0,-xaxis_end_motor_offset[1],0])
                translate([x*screw_dist/2, -(xaxis_beltpath_width/2+3*mm), z*screw_dist/2])
                {
                    if(!(x==1 && z == (beltpath_index==0?1:-1)))
                    screw_cut(xaxis_motor_nut, h=25, with_nut=false, orient=[0,1,0], align=[0,1,0]);
                }
            }

        }

        // nut mount
        mirror([0,0,nut_top?1:0])
        translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        {
            union()
            {
                translate([0,0,-.1])
                {
                    // nut
                    cylindera(h=nut_h+1, d=zaxis_nut[0]*1.05, align=[0,0,1]);

                    // lead screw
                    translate([0,0,-.1])
                    cylindera(h=lookup(NemaFrontAxleLength,zaxis_motor), d=zaxis_nut[2]*1.5, align=[0,0,1]);

                    for(i=[-1,1])
                    translate([i*zaxis_nut[5], 0, -zaxis_nut[3]])
                    screw_cut(thread=zaxis_nut[6], h=20*mm, with_nut=false, orient=ZAXIS, align=ZAXIS);
                }
            }
        }
    }
    else if(part=="vit")
    {
        xaxis_end_body(part=part, with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top, with_xrod_adjustment=with_xrod_adjustment);

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
                    pulley(xaxis_pulley, flip=false, orient=[0,1,0], align=[0,-1,0]);

                    if(show_motor)
                    {
                        motor(xaxis_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
                    }
                }
            }
        }

        //endstop
        if($show_vit)
        {
            /*if(xaxis_endstop_type == "SWITCH")*/
            {
                translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
                {
                    difference()
                    {
                        rcubea(xaxis_endstop_size_switch, align=[-1,0,1]);

                        translate(xaxis_endstop_screw_offset_switch)
                        for(y=[-1,1])
                        translate([-5*mm,y*9.5*mm/2,xaxis_endstop_size_switch[2]])
                        screw(nut=NutHexM2_5, h=6*mm, orient=[0,0,-1], align=[0,0,-1]);
                    }
                }
            }
            /*else if(xaxis_endstop_type == "SN04")*/
            {
                translate([xaxis_end_width(with_motor),0,(xaxis_rod_distance/2)+xaxis_rod_d])
                {
                    translate(xaxis_endstop_offset_SN04)
                    translate([-36,-9,0])
                    rotate(ZAXIS*-90)
                    import("stl/SN04-N_Inductive_Proximity_Sensor_3528_0.stl");
                }
            }
        }

        // belt idler pulley screw
        for(z=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([0, -xaxis_beltpath_width/2 - 7*mm, 0])
            {
                screw(nut=NutHexM5, h=25*mm, with_nut=true, orient=[0,1,0], align=[0,1,0]);
            }
        }

        for(z=[-1,1])
        translate([xaxis_end_pulley_offset,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            pulley(xaxis_idler_pulley, orient=[0,1,0]);
        }

        if(show_nut)
        {
            mirror([0,0,nut_top?1:0])
            translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2-zaxis_nut[3]])
            xaxis_end_znut();
        }


        if(show_rods)
        {
            for(z=[-1,1])
                translate([0,0,z*xaxis_rod_distance/2])
                translate([0, -xaxis_zaxis_distance_y, 0])
                cylindera(d=zaxis_rod_d, h=zaxis_rod_l, orient=[0,0,1]);
        }

        if(show_bearings)
        {
            for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
            translate([0, -xaxis_zaxis_distance_y, 0])
            bearing(zaxis_bearing);
        }
    }
}

module xaxis_end_beltpath(height, width, length = 1000, align=[0,0,0], orient=[1,0,0])
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
        union()
        {
            cylindera(d=zaxis_nut[1], h=zaxis_nut[3], orient=[0,0,1], align=[0,0,1]);
            cylindera(d=zaxis_nut[0], h=zaxis_nut[4], orient=[0,0,1], align=[0,0,1]);
        }

        translate([0,0,-.1])
        cylindera(d=zaxis_nut[2], h=zaxis_nut[4]+.2, orient=[0,0,1], align=[0,0,1]);
    }
}


if(false)
{
    // x axis
    /*translate([0,0,axis_pos_z])*/
    {
        /*if(!$preview_mode)*/
        {
            zrod_offset = zmotor_mount_rod_offset_x;
            for(x=[-1,1])
            {
                z=xaxis_beltpath_z_offsets[x<0?0:x];
                xo = x>0?xaxis_end_pulley_offset:xaxis_end_motor_offset[0];
                xw = x<0?xaxis_end_pulley_offset:xaxis_end_motor_offset[0];
                translate([-main_width/2-xo/2, xaxis_zaxis_distance_y, z])
                rotate([90,0,0])
                color("black")
                belt_path(main_width+xw, 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);
            }
        }

        /*translate([axis_pos_x,0,0])*/
        /*{*/
            // x carriage
            /*attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],[0,0,0]])*/
            /*{*/
                /*x_carriage_full();*/
            /*}*/
        /*}*/

        // x smooth rods
        color(color_rods)
        for(z=[-1,1])
        translate([xaxis_rod_offset_x,xaxis_zaxis_distance_y,z*(xaxis_rod_distance/2)])
        cylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

        for(x=[-1,1])
        translate([x*(main_width/2), 0, 0])
        translate([x*(zmotor_mount_rod_offset_x),0,0])
        cylindera(h=zaxis_rod_l,d=zaxis_rod_d, orient=ZAXIS, align=[0,0,0]);

        for(x=[-1,1])
        {
            translate([x*(main_width/2), 0, 0])
            {
                translate([0, xaxis_zaxis_distance_y, 0])
                translate([x*zmotor_mount_rod_offset_x, 0, 0])
                mirror([max(0,x),0,0])
                {
                    xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);
                }
            }
        }
    }

}

if(false)
{
    for(x=[-1,1])
    translate([x*55,x*55,xaxis_end_wz/2])
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
