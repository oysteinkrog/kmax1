include <MCAD/motors.scad>
include <MCAD/stepper.scad>

include <config.scad>
include <thing_libutils/misc.scad>

motor_mount_wall_thick = 10*mm;
wz = xaxis_rod_distance+xaxis_bearing[2]+5*mm;
wy = xaxis_bearing[1]*2+xaxis_zaxis_distance_y;
xaxis_end_motorsize = lookup(NemaSideSize,xaxis_motor);
xaxis_end_motor_offset=[xaxis_end_motorsize/2+9*mm,0,0];

module xaxis_end(with_motor=false, show_motor=false, show_nut=false)
{
    x_side = with_motor?1:-1;
    nut_h = zaxis_nut[4];
    wx = zaxis_bearing[1]/2+zaxis_nut[1];
    wx_ = with_motor? xaxis_end_motorsize+xaxis_end_motor_offset[0] - xaxis_end_motorsize/2 : wx;
    difference()
    {
        extrasize = with_motor?0*mm:0*mm;
        extrasize_align = with_motor?-1:1;

        union()
        {
            cubea([wx_, xaxis_rod_d*2, wz], align=[with_motor?1:-1,0,0]);

            translate([0,-xaxis_zaxis_distance_y,0])
            cubea([wx_, zaxis_bearing[1]*2, wz], align=[with_motor?1:-1,0,0]);

            if(with_motor)
            {
                translate(xaxis_end_motor_offset)
                cubea([xaxis_end_motorsize, motor_mount_wall_thick, wz], align=[0,1,0]);
            }
            // nut mount
            translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -wz/2])
            {
                union()
                {
                    fncylindera(h=wz, d=zaxis_nut[1], align=[0,0,1]);
                    translate([-1*x_side*zaxis_nut[1]/2,0,0])
                    {
                        cubea([zaxis_nut[1]/2,zaxis_nut[1],wz],align=[x_side,0,1]);
                        cubea([zaxis_nut[1],zaxis_nut[1]/2,wz],align=[x_side,1,1]);
                    }
                }
            }
        }

        beltpath_height = xaxis_pulley_inner_d+5*mm;
        beltpath_width = max(belt_width+3*mm, xaxis_pulley[0]+3*mm);

        // belt path
        beltpath_length = 1000;
        cubea([beltpath_length,beltpath_width, beltpath_height]);

        diag = pythag_hyp(beltpath_width,beltpath_width)/2;

        for(z=[-1,1])
        translate([0,0,z*beltpath_height/2])
        translate([-diag/2,0,0])
        translate([diag/2,0,0])
        rotate([z*-45,0,0])
        cubea([beltpath_length, diag, diag]);

        for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
                translate([0, -xaxis_zaxis_distance_y, 0])
                bearing_mount_holes(zaxis_bearing, orient=[0,0,1], show_zips=false);


        // x smooth rods
        for(z=[-1,1])
            translate([0,0,z*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

        if(with_motor)
        {
            screw_dist = lookup(NemaDistanceBetweenMountingHoles, xaxis_motor);

            for(x=[-1,1])
            for(z=[-1,1])
            translate([x*screw_dist/2, 0, z*screw_dist/2])
            translate(xaxis_end_motor_offset)
            translate([0,motor_mount_wall_thick+.1,0])
            fncylindera(d=lookup(NemaMountingHoleDiameter, xaxis_motor), h=wy, orient=[0,1,0], align=[0,1,0]);

            translate([0,-motor_mount_wall_thick,0])
            for(x=[-1,1])
            for(z=[-1,1])
            translate([x*screw_dist/2, 0, z*screw_dist/2])
            translate(xaxis_end_motor_offset)
            translate([0,motor_mount_wall_thick+.1,0])
            fncylindera(d=lookup(NemaMountingHoleDiameter, xaxis_motor)*1.9, h=wy, orient=[0,1,0], align=[0,1,0]);
        }

        // nut mount
        translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -wz/2])
        {
            union()
            {
                translate([0,0,-.1])
                {
                    fncylindera(h=nut_h+1, d=zaxis_nut[0]*1.05, align=[0,0,1]);

                    fncylindera(h=wz+1, d=zaxis_nut[2]*1.2, align=[0,0,1]);

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
            pulley(pulley_2GT_20T, align, orient=[0,1,0]);

        translate([0,motor_mount_wall_thick+.1,0])
        translate(xaxis_end_motor_offset)
        motor(xaxis_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
    }

    %if(show_nut)
    {
        translate([x_side*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -wz/2-zaxis_nut[3]])
        xaxis_end_znut();
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


debug=false;
if(debug)
{
    // x smooth rods
    for(z=[-1,1])
        translate([0,0,z*(xaxis_rod_distance/2)])
            %fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);

    xaxis_end(with_motor=true, show_motor=true, show_nut=true);

    translate([150,0,0])
        xaxis_end(with_motor=false, show_motor=true, show_nut=true);
}

xaxis_end(with_motor=true, show_motor=false, show_nut=false);
translate([100,-10,0])
xaxis_end(with_motor=false, show_motor=false, show_nut=false);
