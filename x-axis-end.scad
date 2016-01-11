include <MCAD/motors.scad>
include <MCAD/stepper.scad>

include <config.scad>
include <thing_libutils/misc.scad>
include <thing_libutils/bearing.scad>

motor_mount_wall_thick = xaxis_pulley[1]+1*mm-xaxis_pulley[0]/2;
xaxis_end_motorsize = lookup(NemaSideSize,xaxis_motor);
xaxis_end_motor_offset=[xaxis_end_motorsize/2+9*mm,motor_mount_wall_thick,0];

    xaxis_end_wz = xaxis_rod_distance+xaxis_bearing[2]+5*mm;
module xaxis_end_body(with_motor, nut_top=false)
{
    x_side = with_motor?1:-1;
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    wy = xaxis_bearing[1]*2+xaxis_zaxis_distance_y;

    /*%cuberounda([wx_, xaxis_rod_d*2, xaxis_end_wz], rounding_radius=3, align=[with_motor?1:-1,0,0]);*/

    if(with_motor)
    translate(xaxis_end_motor_offset)
    translate([0,1*mm,0])
    cuberounda([xaxis_end_motorsize, motor_mount_wall_thick, xaxis_end_motorsize], rounding_radius=3, align=[0,-1,0]);

    // nut mount
    mirror([0,0,nut_top?1:0])
    translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
    {
        union()
        {
            fncylindera(h=zaxis_nut[4], d=zaxis_nut[1], align=[0,0,1]);

            // lead screw
            // ensure some support for the leadscrew cutout all the way to the top
            fncylindera(h=xaxis_end_wz, d=zaxis_nut[2]*2, align=[0,0,1]);
        }
    }

    // x axis rod holders
    for(z=[-1,1])
    translate([0,0,z*(xaxis_rod_distance/2)])
        fncylindera(h=wx_,d=xaxis_rod_d*2, orient=[1,0,0], align=[x_side,0,0]);


    // support around z axis bearings
    translate([0, -xaxis_zaxis_distance_y, 0])
    {
        difference()
        {
            sizey= zaxis_bearing[1]*2;
            fncylindera(h=xaxis_end_wz,d=sizey, orient=[0,0,1], align=[0,0,0]);
            translate([0,0,.1])
            cubea([sizey/2+.1, sizey+.2, xaxis_end_wz+.4], orient=[0,0,1], align=[-x_side,0,0]);
        }
    }
}

module xaxis_end(with_motor=false, show_motor=false, nut_top=false, show_nut=false, show_rods=false)
{
    x_side = with_motor?1:-1;
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    wy = xaxis_bearing[1]*2+xaxis_zaxis_distance_y;
    xaxis_end_wz = xaxis_rod_distance+xaxis_bearing[2]+5*mm;
    difference()
    {
        extrasize = with_motor?0*mm:0*mm;
        extrasize_align = with_motor?-1:1;

        hull()
        {
            xaxis_end_body(with_motor, nut_top);

            // projection against z, ensure easy print
            translate([0,0,-xaxis_end_wz/2])
                linear_extrude(1)
                projection(cut=false)
                xaxis_end_body(with_motor);
        }

        xaxis_end_beltpath();

        // z smooth bearing mounts
        for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
                translate([0, -xaxis_zaxis_distance_y, 0])
                bearing_mount_holes(
                        zaxis_bearing,
                        ziptie_type,
                        ziptie_bearing_distance,
                        orient=[0,0,1],
                        show_zips=false
                );

        // x smooth rods
        for(z=[-1,1])
            translate([0,0,z*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

        if(with_motor)
        {
            screw_dist = lookup(NemaDistanceBetweenMountingHoles, xaxis_motor);

            // axle
            translate(xaxis_end_motor_offset)
            {
                translate([0, .1, 0])
                translate([0,1,0])
                fncylindera(d=1.1*lookup(NemaRoundExtrusionDiameter, xaxis_motor), h=motor_mount_wall_thick, orient=[0,1,0], align=[0,1,0]);

                // motor axle
                translate([0, .1, 0])
                fncylindera(d=1.1*lookup(NemaAxleDiameter, xaxis_motor), h=lookup(NemaFrontAxleLength, xaxis_motor), orient=[0,1,0], align=[0,1,0]);

                // bearing for offloading force on motor shaft
                translate([0, -xaxis_pulley[1]-1*mm+.1, 0])
                scale(1.03)
                bearing(bearing_MR105, orient=[0,1,0], align=[0,-1,0]);

                xaxis_motor_thread=ThreadM3;
                for(x=[-1,1])
                for(z=[-1,1])
                translate([x*screw_dist/2, .1, z*screw_dist/2])
                {
                    // screw
                    translate([0,1,0])
                    fncylindera(d=lookup(ThreadSize, xaxis_motor_thread), h=wy+motor_mount_wall_thick, orient=[0,1,0], align=[0,1,0]);

                    // screw head
                    translate([0,-motor_mount_wall_thick,0])
                        fncylindera(d=lookup(ThreadSize, xaxis_motor_thread)*1.9, h=wy+motor_mount_wall_thick, orient=[0,1,0], align=[0,1,0]);
                }
            }

        }

        // nut mount
        mirror([0,0,nut_top?1:0])
        translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2])
        {
            union()
            {
                translate([0,0,-.1])
                {
                    // nut
                    fncylindera(h=nut_h+1, d=zaxis_nut[0]*1.05, align=[0,0,1]);

                    // lead screw
                    translate([0,0,-.1])
                    fncylindera(h=xaxis_end_wz+1, d=zaxis_nut[2]*1.5, align=[0,0,1]);

                    for(i=[-1,1])
                        translate([i*13.5, 0, 0])
                            fncylindera(h=5, r=1.6, align=[0,0,1]);
                }
            }
        }
    }

    if(with_motor && show_motor)
    {
        translate(xaxis_end_motor_offset)
        {
            /*translate([0,-motor_mount_wall_thick,0])*/
            /*translate([0,-5,0])*/
            translate([0,-1,0])
            /*translate([0,-xaxis_pulley[0]/2,0])*/
            pulley(xaxis_pulley, flip=false, orient=[0,1,0], align=[0,-1,0]);


            motor(xaxis_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
        }
    }

    %if(show_nut)
    {
        mirror([0,0,nut_top?1:0])
        translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -xaxis_end_wz/2-zaxis_nut[3]])
        xaxis_end_znut();
    }


    %if(show_rods)
    {
        for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
            translate([0, -xaxis_zaxis_distance_y, 0])
            fncylindera(d=zaxis_rod_d, h=zaxis_rod_l, orient=[0,0,1]);
    }
}

xaxis_end_beltpath_height = xaxis_pulley_inner_d+5*mm;
xaxis_end_beltpath_width = max(belt_width+3*mm, xaxis_pulley[0]+3*mm);

module xaxis_end_beltpath(xaxis_end_beltpath_length=1000)
{
    diag = pythag_hyp(xaxis_end_beltpath_width,xaxis_end_beltpath_width)/2;

    hull()
    for(z=[-1,1])
    translate([0,0,z*xaxis_end_beltpath_height/2])
    translate([-diag/2,0,0])
    translate([diag/2,0,0])
    rotate([z*-45,0,0])
    cubea([xaxis_end_beltpath_length, diag, diag]);
}

module xaxis_end_idlerholder(xaxis_end_beltpath_length=10)
{
    diag = pythag_hyp(xaxis_end_beltpath_width,xaxis_end_beltpath_width)/2;

    difference()
    {
        union()
        {
            cubea([10*mm, xaxis_end_beltpath_width/sqrt(2), xaxis_rod_distance], align=[1,0,0]);

            translate([10*mm, 0,0])
                cubea([15*mm, xaxis_idler_pulley[0]+8*mm, xaxis_rod_distance+xaxis_rod_d*2], align=[1,0,0]);
        }

        // x smooth rods
        for(z=[-1,1])
            translate([0,0,z*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

        translate([20,0,0])
            pulley(xaxis_idler_pulley, orient=[0,1,0]);

        translate([10*mm+15*mm/2,0,0])
        fncylindera(d=lookup(ThreadSize, ThreadM5), h=100, orient=[0,1,0]);

        xaxis_end_beltpath();
    }
}

module xaxis_end_znut()
{
    difference()
    {
        union()
        {
            fncylindera(d=zaxis_nut[1], h=zaxis_nut[3], orient=[0,0,1], align=[0,0,1]);
            fncylindera(d=zaxis_nut[0], h=zaxis_nut[4], orient=[0,0,1], align=[0,0,1]);
        }
        translate([0,0,-.1])
            fncylindera(d=zaxis_nut[2], h=zaxis_nut[4]+.2, orient=[0,0,1], align=[0,0,1]);
    }
}


/*debug=false;*/
/*[>debug=true;<]*/
/*if(debug)*/
/*{*/
    /*// x smooth rods*/
    /*for(z=[-1,1])*/
        /*translate([0,0,z*(xaxis_rod_distance/2)])*/
            /*%fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);*/

    /*xaxis_end(with_motor=true, show_motor=true, nut_top=false, show_nut=true, show_rods=true);*/

    /*translate([150,0,0])*/
    /*{*/
        /*xaxis_end(with_motor=false, show_motor=true, nut_top=false, show_nut=true, show_rods=true);*/
        /*xaxis_end_idlerholder();*/
    /*}*/
/*}*/

/*print=false;*/
/*if(print)*/
/*{*/
    /*translate([0,0,xaxis_end_wz/2])*/
    /*xaxis_end(with_motor=true, show_motor=false, show_nut=false);*/

    /*translate([100,0,xaxis_end_wz/2])*/
    /*xaxis_end(with_motor=false, show_motor=false, show_nut=false);*/

    /*translate([50,30,25])*/
        /*rotate([0,90,0])*/
        /*xaxis_end_idlerholder();*/
/*}*/
