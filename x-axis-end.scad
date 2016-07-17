include <MCAD/motors.scad>
include <MCAD/stepper.scad>

include <config.scad>
include <thing_libutils/misc.scad>
include <thing_libutils/bearing.scad>
use <thing_libutils/metric-screw.scad>
use <thing_libutils/timing-belts.scad>

motor_mount_wall_thick = xaxis_pulley[1] - xaxis_pulley[0]/2 + 4*mm;
xaxis_end_motorsize = lookup(NemaSideSize,xaxis_motor);
xaxis_end_motor_offset=[xaxis_end_motorsize/2+7*mm,motor_mount_wall_thick-2*mm,0];
xaxis_end_wz = xaxis_rod_distance+zaxis_bearing[2]+5*mm;

// overlap of the X and Z rods
xaxis_end_xz_rod_overlap = 4*mm;

// how much "stop" for the x rods
xaxis_end_rod_stop = 10*mm;

xaxis_endstop_size = [10.3*mm, 20*mm, 6.3*mm];
xaxis_endstop_screw_offset = [-1.8*mm, 0*mm, 0*mm];

module xaxis_end_body(part, with_motor, beltpath_index=0, nut_top=false)
{
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    bearing_sizey= zaxis_bearing[1]+10*mm;

    if(part==undef)
    {
        difference()
        {
            xaxis_end_body(part="pos", with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top);
            xaxis_end_body(part="neg", with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top);
        }
    }
    else if(part=="pos")
    {
        if(with_motor)
        translate([0,0,xaxis_beltpath_z_offsets[beltpath_index]])
        translate(xaxis_end_motor_offset)
        rcubea([xaxis_end_motorsize, motor_mount_wall_thick, xaxis_end_motorsize], rounding_radius=3, align=[0,-1,0]);

        // nut mount
        mirror([0,0,nut_top?1:0])
        translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        {
            cylindera(h=zaxis_nut[4], d=zaxis_nut[1], align=[0,0,1], round_radius=2);

            // lead screw
            // ensure some support for the leadscrew cutout all the way to the top
            cylindera(h=xaxis_end_wz, d=zaxis_nut[2]*2, align=[0,0,1], round_radius=2);
        }

        // x axis rod holders
        xaxis_rod_d_support = xaxis_rod_d+5*mm;
        for(z=[-1,1])
        translate([-xaxis_end_xz_rod_overlap,0,z*(xaxis_rod_distance/2)])
        cylindera(h=wx_+xaxis_end_xz_rod_overlap, d=xaxis_rod_d_support, orient=[1,0,0], align=[1,0,0], round_radius=2);

        translate([wx_,0,(xaxis_rod_distance/2)+xaxis_rod_d])
        {
            rcubea(xaxis_endstop_size, align=[-1,0,-1]);
        }

        // support around z axis bearings
        translate([0, -xaxis_zaxis_distance_y, 0])
        cylindera(h=xaxis_end_wz,d=bearing_sizey, orient=[0,0,1], align=[0,0,0], round_radius=2);
    }
    else if(part=="neg")
    {
        // cut support around z axis bearings
        translate([0, -xaxis_zaxis_distance_y, 0])
        translate([0,0,.1])
        cubea([bearing_sizey/2+.1, bearing_sizey+.2, xaxis_end_wz+.4], orient=[0,0,1], align=[-1,0,0]);

        // cut away some of nut mount support
        mirror([0,0,nut_top?1:0])
        translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        translate([0,-zaxis_nut[0]/2-1*mm,0])
        cubea([zaxis_nut[4]*2,zaxis_nut[4]+.2,zaxis_nut[4]+.2], align=[0,-1,1]);
    }
    else if(part=="vit")
    {
    }
}

module xaxis_end(part, with_motor=false, stop_x_rods=false, beltpath_index=0, show_motor=false, nut_top=false, show_nut=false, show_rods=false, show_bearings=false)
{
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    extrasize = with_motor?0*mm:0*mm;
    extrasize_align = 1;

    if(part==undef)
    {
        difference()
        {
            xaxis_end(part="pos", with_motor=with_motor, stop_x_rods=stop_x_rods, beltpath_index=beltpath_index, show_motor=show_motor, nut_top=nut_top, show_nut=show_nut, show_rods=show_rods, show_bearings=show_bearings);
            xaxis_end(part="neg", with_motor=with_motor, stop_x_rods=stop_x_rods, beltpath_index=beltpath_index, show_motor=show_motor, nut_top=nut_top, show_nut=show_nut, show_rods=show_rods, show_bearings=show_bearings);
        }
    }
    else if(part=="pos")
    {
        hull()
        {
            xaxis_end_body(with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top);

            // projection against z, ensure easy print
            translate([0,0,-xaxis_end_wz/2])
                linear_extrude(1)
                projection(cut=false)
                xaxis_end_body(with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top);
        }
    }
    else if(part=="neg")
    {
        //endstop mount screw cuts
        translate([wx_,0,(xaxis_rod_distance/2)+xaxis_rod_d])
        translate(xaxis_endstop_screw_offset)
        for(y=[-1,1])
        translate([-5*mm,y*9.5*mm/2,-2*mm])
        nut_trap_cut(nut=MHexNutM3, screw_l=6*mm, screw_l_extra=0*mm, trap_axis=[-1,0,0], orient=[0,0,1], align=[0,0,-1]);

        xaxis_end_beltpath(height=xaxis_beltpath_height_body);

        // z smooth bearing mounts
        for(z=[-1,1])
        {
            translate([0,0,z*xaxis_rod_distance/2])
            translate([0, -xaxis_zaxis_distance_y, 0])
            {
                bearing_mount_holes(
                        zaxis_bearing,
                        ziptie_type,
                        ziptie_bearing_distance,
                        orient=[0,0,1],
                        with_zips=true,
                        show_zips=false
                        );
                /*hull()*/
                /*{*/
                    /*cylindera(d=zaxis_bearing[1],h=xaxis_end_wz);*/

                    /*translate([-5*cm,0,0])*/
                    /*cylindera(d=zaxis_bearing[1],h=xaxis_end_wz);*/
                /*}*/
            }
        }

        // x smooth rods
        x_rod_stop = stop_x_rods ? xaxis_end_rod_stop : 0;
        for(z=[-1,1])
        translate([-xaxis_end_xz_rod_overlap-.1+x_rod_stop,0,z*(xaxis_rod_distance/2)])
        cylindera(h=wx_+xaxis_end_xz_rod_overlap-x_rod_stop+.2,d=xaxis_rod_d+.2*mm, orient=[1,0,0], align=[1,0,0]);

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
                teardrop(d=round_d,h=motor_mount_wall_thick, tear_orient=[0,0,1], orient=[0,1,0], align=[0,-1,0], roll=90, truncate=0);

                // motor axle
                translate([0, .1, 0])
                cylindera(d=1.2*lookup(NemaAxleDiameter, xaxis_motor), h=lookup(NemaFrontAxleLength, xaxis_motor)+3*mm, orient=[0,1,0], align=[0,1,0]);

                // bearing for offloading force on motor shaft
                translate([0, -2.5*mm-xaxis_pulley[1]-.1, 0])
                scale(1.03)
                cylindera(d=bearing_MR105[1], h=6*mm, orient=[0,1,0], align=[0,-1,0]);

                xaxis_motor_thread=ThreadM3;
                xaxis_motor_nut=MHexNutM3;
                for(x=[-1,1])
                for(z=[-1,1])
                translate([0,-xaxis_end_motor_offset[1],0])
                translate([x*screw_dist/2, -(xaxis_beltpath_width/2+4*mm), z*screw_dist/2])
                {
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
                    translate([i*13.5*mm, 0, -zaxis_nut[3]])
                    screw_cut(thread=ThreadM3, h=16*mm, with_nut=false, orient=[0,0,1], align=[0,0,1]);
                }
            }
        }
    }
    else if(part=="vit")
    {
        if(with_motor && show_motor)
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
                    motor(xaxis_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
                }
            }
        }

        //endstop
        %if($show_vit)
        {
            translate([wx_,0,(xaxis_rod_distance/2)+xaxis_rod_d])
            {
                difference()
                {
                    rcubea(xaxis_endstop_size, align=[-1,0,1]);

                    translate(xaxis_endstop_screw_offset)
                    for(y=[-1,1])
                    translate([-5*mm,y*9.5*mm/2,xaxis_endstop_size[2]])
                    screw_cut(nut=MHexNutM3, h=10*mm, orient=[0,0,-1], align=[0,0,-1]);
                }
            }
        }

        %if(show_nut)
        {
            mirror([0,0,nut_top?1:0])
            translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2-zaxis_nut[3]])
            xaxis_end_znut();
        }


        %if(show_rods)
        {
            for(z=[-1,1])
                translate([0,0,z*xaxis_rod_distance/2])
                translate([0, -xaxis_zaxis_distance_y, 0])
                cylindera(d=zaxis_rod_d, h=zaxis_rod_l, orient=[0,0,1]);
        }

        %if(show_bearings)
        {
            for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
            translate([0, -xaxis_zaxis_distance_y, 0])
            bearing(zaxis_bearing);
        }
    }
}

module xaxis_end_beltpath(height, width=xaxis_beltpath_width, length = 1000)
{
    hull()
    for(z=[-1,1])
    translate([0,0,z*height/2])
    teardrop(h=length, d=width, orient=[1,0,0], roll=-180*min(0,z), truncate=.5);
}

module xaxis_end_idlerholder(part, width=xaxis_beltpath_width, length=10, beltpath_index=0)
{
    width = 20*mm;

    if(part==undef)
    {
        difference()
        {
            xaxis_end_idlerholder(part="pos", width=xaxis_beltpath_width, length=length, beltpath_index=beltpath_index);
            xaxis_end_idlerholder(part="neg", width=xaxis_beltpath_width, length=length, beltpath_index=beltpath_index);
        }
    }
    else if(part=="pos")
    {
        hull()
        {
            // support for x smooth rods
            for(z=[-1,1])
            translate([0,0,z*(xaxis_rod_distance/2)])
            cylindera(h=width, d=xaxis_rod_d+4*mm, orient=[1,0,0], align=[1,0,0], round_radius=2);

            // extra support for pulley
            translate([0,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
            translate([width/2,0,0])
            cylindera(h=8*mm+pulley_height(xaxis_idler_pulley), d=xaxis_idler_pulley[3], orient=[0,1,0], round_radius=2);
        }
    }
    else if(part=="neg")
    {
        for(z=[-1,1])
        {
            translate([0,0,z*(xaxis_rod_distance/2)])
            {
                // x smooth rods
                translate([width/2+.1,0,0])
                cylindera(h=width/2,d=xaxis_rod_d+.2*mm, orient=[1,0,0], align=[1,0,0]);

                screw_cut(nut=MHexNutM4, h=16*mm, with_nut=false, orient=[1,0,0], align=[1,0,0]);

                translate([6*mm,0,0])
                nut_trap_cut(nut=MHexNutM4, screw_l=16*mm, trap_axis=[0,-1,0], orient=[1,0,0], $show_vit=false);
            }
        }

        translate([0,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([width/2,0,0])
                pulley(xaxis_idler_pulley, orient=[0,1,0]);

            translate([width/2,0,0])
                cylindera(d=lookup(ThreadSize, ThreadM5), h=100, orient=[0,1,0]);

            xaxis_end_beltpath(height=xaxis_beltpath_height_holders);
        }
    }
    else if(part=="vit")
    {
        %translate([0,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        translate([width/2,0,0])
        pulley(xaxis_idler_pulley, orient=[0,1,0]);
    }
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


include <thing_libutils/misc.scad>;
if(false)
{
    // x axis
    /*translate([0,0,axis_pos_z])*/
    {
        /*if(!preview_mode)*/
        {
            zrod_offset = zmotor_mount_rod_offset_x;
            for(z=[-1,1])
            for(z=xaxis_beltpath_z_offsets)
            translate([-z*3*mm, xaxis_zaxis_distance_y, z])
            belt_path(5*mm+main_width+2*(zrod_offset)+xaxis_end_motor_offset[0], 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[0,0,0]);
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
        {
            translate([x*(main_width/2), 0, 0])
            {
                translate([0, xaxis_zaxis_distance_y, 0])
                translate([x*zmotor_mount_rod_offset_x, 0, 0])
                mirror([max(0,x),0,0])
                {
                    xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);
                    xaxis_end(part="vit", with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);
                }

                translate([x*95, xaxis_zaxis_distance_y, 0])
                mirror([0,0,max(0,x)])
                mirror([max(0,x),0,0])
                xaxis_end_idlerholder();
            }
        }
    }

}

if(false)
{
    zrod_offset = zmotor_mount_rod_offset_x;
    for(z=[-1,1])
    for(z=xaxis_beltpath_z_offsets)
    translate([0,0,xaxis_end_wz/2])
    translate([-main_width/2-zrod_offset+xaxis_end_motor_offset[0], xaxis_zaxis_distance_y, z])
    belt_path(main_width+2*(zrod_offset)+xaxis_end_motor_offset[0], 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);

    translate([0, xaxis_zaxis_distance_y, 0])
    {
        for(x=[-1,1])
        translate([x*55,0,xaxis_end_wz/2])
        mirror([max(0,x),0,0])
        {
            xaxis_end(with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false);
            xaxis_end(part="vit", with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false);
        }

        for(x=[-1,1])
        translate([0,0,xaxis_end_wz/2])
        translate([x*45,25,0])
        translate([x*105,0,0])
        mirror([max(0,x),0,0])
        rotate([0,-90,0])
        xaxis_end_idlerholder(beltpath_index=max(0,x));
    }
}
