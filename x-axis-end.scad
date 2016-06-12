include <MCAD/motors.scad>
include <MCAD/stepper.scad>

include <config.scad>
include <thing_libutils/misc.scad>
include <thing_libutils/bearing.scad>
use <thing_libutils/metric-screw.scad>

motor_mount_wall_thick = xaxis_pulley[1] - xaxis_pulley[0]/2 + 4*mm;
xaxis_end_motorsize = lookup(NemaSideSize,xaxis_motor);
xaxis_end_motor_offset=[xaxis_end_motorsize/2+9*mm,motor_mount_wall_thick-2*mm,0];
xaxis_end_wz = xaxis_rod_distance+zaxis_bearing[2]+5*mm;

// overlap of the X and Z rods
xaxis_end_xz_rod_overlap = 4*mm;

// how much "stop" for the x rods
xaxis_end_rod_stop = 10*mm;

module xaxis_end_body(with_motor, beltpath_index=0, nut_top=false)
{
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;

    /*%rcubea([wx_, xaxis_rod_d*2, xaxis_end_wz], rounding_radius=3, align=[with_motor?1:-1,0,0]);*/

    if(with_motor)
    translate([0,0,xaxis_beltpath_z_offsets[beltpath_index]])
    translate(xaxis_end_motor_offset)
    rcubea([xaxis_end_motorsize, motor_mount_wall_thick, xaxis_end_motorsize], rounding_radius=3, align=[0,-1,0]);

    // nut mount
    mirror([0,0,nut_top?1:0])
    translate([zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
    {
        union()
        {
            cylindera(h=zaxis_nut[4], d=zaxis_nut[1], align=[0,0,1]);

            // lead screw
            // ensure some support for the leadscrew cutout all the way to the top
            /*cylindera(h=xaxis_end_wz, d=zaxis_nut[2]*2, align=[0,0,1]);*/
        }
    }

    // x axis rod holders
    for(z=[-1,1])
    translate([-xaxis_end_xz_rod_overlap,0,z*(xaxis_rod_distance/2)])
        cylindera(h=wx_+xaxis_end_xz_rod_overlap,d=xaxis_rod_d+5*mm, orient=[1,0,0], align=[1,0,0]);


    // support around z axis bearings
    translate([0, -xaxis_zaxis_distance_y, 0])
    {
        difference()
        {
            sizey= zaxis_bearing[1]+10*mm;
            cylindera(h=xaxis_end_wz,d=sizey, orient=[0,0,1], align=[0,0,0]);
            translate([0,0,.1])
            cubea([sizey/2+.1, sizey+.2, xaxis_end_wz+.4], orient=[0,0,1], align=[-1,0,0]);
            /*#cubea([sizey+.1, sizey/2+.2, xaxis_end_wz+.4], orient=[0,0,1], align=[0,-1,0]);*/
        }
    }
}

module xaxis_end(with_motor=false, stop_x_rods=false, beltpath_index=0, show_motor=false, nut_top=false, show_nut=false, show_rods=false, show_bearings=false)
{
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    difference()
    {
        extrasize = with_motor?0*mm:0*mm;
        extrasize_align = 1;

       hull()
        {
            xaxis_end_body(with_motor=with_motor, beltpath_index=beltpath_index, nut_top=nut_top);

            // projection against z, ensure easy print
            translate([0,0,-xaxis_end_wz/2])
                linear_extrude(1)
                projection(cut=false)
                xaxis_end_body(with_motor);
        }


        xaxis_end_beltpath(height=xaxis_beltpath_height+v_sum(v_abs(xaxis_beltpath_z_offsets)));

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
        cylindera(h=wx_+xaxis_end_xz_rod_overlap-x_rod_stop+.2,d=xaxis_rod_d, orient=[1,0,0], align=[1,0,0]);

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

                union()
                {
                    cylindera(d=round_d, h=motor_mount_wall_thick, orient=[0,1,0], align=[0,1,0]);
                    rotate([0,45,0])
                    difference()
                    {
                        cubea([round_d, motor_mount_wall_thick, round_d], align=[0,-1,0]);

                        cubea([round_d, motor_mount_wall_thick, round_d/2], align=[0,-1,-1]);
                        cubea([round_d/2, motor_mount_wall_thick, round_d], align=[1,-1,0]);
                    }
                }

                // motor axle
                translate([0, .1, 0])
                cylindera(d=1.2*lookup(NemaAxleDiameter, xaxis_motor), h=lookup(NemaFrontAxleLength, xaxis_motor)+3*mm, orient=[0,1,0], align=[0,1,0]);

                // bearing for offloading force on motor shaft
                translate([0, -2.5*mm-xaxis_pulley[1]-.1, 0])
                scale(1.03)
                bearing(bearing_MR105, override_h=6*mm, orient=[0,1,0], align=[0,-1,0]);

                xaxis_motor_thread=ThreadM3;
                xaxis_motor_nut=MHexNutM3;
                for(x=[-1,1])
                for(z=[-1,1])
                translate([0,-xaxis_end_motor_offset[1],0])
                translate([x*screw_dist/2, -(xaxis_beltpath_width/2+3*mm), z*screw_dist/2])
                {
                    screw_cut(xaxis_motor_nut, h=100, with_nut=false, orient=[0,1,0], align=[0,1,0]);
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
                    cylindera(h=xaxis_end_wz+1, d=zaxis_nut[2]*1.5, align=[0,0,1]);

                    for(i=[-1,1])
                        translate([i*13.5, 0, 0])
                            cylindera(h=5, r=1.6, align=[0,0,1]);
                }
            }
        }
    }

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

module xaxis_end_beltpath(height=xaxis_beltpath_height, width=xaxis_beltpath_width, length = 1000)
{
    diag = pythag_hyp(width,width)/2;

    hull()
    for(z=[-1,1])
    translate([0,0,z*height/2])
    translate([-diag/2,0,0])
    translate([diag/2,0,0])
    rotate([z*-45,0,0])
    cubea([length, diag, diag]);
}

module xaxis_end_idlerholder(height=xaxis_beltpath_height, width=xaxis_beltpath_width, length=10, beltpath_index=0)
{
    diag = pythag_hyp(width, width)/2;
    width = 20*mm;

    difference()
    {
        union()
        {
            /*translate([10*mm, 0,0])*/
            rcubea([width, xaxis_idler_pulley[0]+8*mm, xaxis_rod_distance+xaxis_rod_d*2], align=[1,0,0]);
        }

        for(z=[-1,1])
        {
            translate([0,0,z*(xaxis_rod_distance/2)])
            {
                // x smooth rods
                translate([width/2, 0,0])
                cylindera(h=width/2,d=xaxis_rod_d, orient=[1,0,0], align=[1,0,0]);

                screw_cut(nut=MHexNutM4, h=100, orient=[1,0,0], align=[1,0,0]);

                translate([width/2-1*mm, 0,0])
                hull()
                {
                    rotate([90,0,0])
                    translate([0,0,-1])
                    screw_nut(MHexNutM4, tolerance=1.15, orient=[1,0,0], align=[-1,0,0]);

                    translate([0,-10,0])
                    rotate([90,0,0])
                    screw_nut(MHexNutM4, tolerance=1.15, orient=[1,0,0], align=[-1,0,0]);
                }

            }
        }

        translate([0,0,-xaxis_beltpath_z_offsets[max(0,beltpath_index)]])
        {
            translate([width/2,0,0])
                pulley(xaxis_idler_pulley, orient=[0,1,0]);

            translate([width/2,0,0])
                cylindera(d=lookup(ThreadSize, ThreadM5), h=100, orient=[0,1,0]);

            xaxis_end_beltpath();
        }
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
            translate([-main_width/2-zrod_offset+xaxis_end_motor_offset[0], xaxis_zaxis_distance_y, z])
            belt_path(main_width+2*(zrod_offset)+xaxis_end_motor_offset[0], 6, xaxis_pulley_inner_d, orient=[1,0,0], align=[1,0,0]);
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
                cylindera(h=xaxis_rod_l,d=xaxis_rod_d+.1, orient=[1,0,0]);

        for(x=[-1,1])
        {
            translate([x*(main_width/2), 0, 0])
            {
                translate([0, xaxis_zaxis_distance_y, 0])
                translate([x*zmotor_mount_rod_offset_x, 0, 0])
                mirror([max(0,x),0,0])
                xaxis_end(with_motor=true, beltpath_index=max(0,x), show_nut=true, show_motor=true, show_nut=true);

                translate([x*110, 0, 0])
                xaxis_end_idlerholder();
            }
        }
    }

}

if(false)
{
    translate([0, xaxis_zaxis_distance_y, 0])
    {
        for(x=[-1,1])
        translate([x*55,0,xaxis_end_wz/2])
        mirror([max(0,x),0,0])
        xaxis_end(with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false);

        for(x=[-1,1])
        translate([0,0,xaxis_end_wz/2])
        translate([x*45,25,0])
        translate([x*105,0,0])
        mirror([max(0,x),0,0])
        rotate([0,-90,0])
        xaxis_end_idlerholder(beltpath_index=max(0,x));
    }
}
