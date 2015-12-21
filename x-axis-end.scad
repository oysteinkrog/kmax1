/*include <config.scad>*/

module xaxis_end(with_motor=false, show_motor=true)
{
    wx = xaxis_bearing[1]*2.5;
    wy = 10*mm;
    wz = xaxis_rod_distance+xaxis_bearing[2]+5*mm;

    difference()
    {
        extrasize = with_motor?0*mm:0*mm;
        extrasize_align = with_motor?-1:1;

        union()
        {
            cubea([wx, wy, wz], align=[0,-1,0]);

            cubea([wx, wy, wz], align=[0,1,0], extrasize=[extrasize,xaxis_rod_d/2,0], extrasize_align=[extrasize_align,-1,0]);
        }

        cubea([wx+.1,belt_width+5*mm, xaxis_pulley_d+10*mm], extrasize=[extrasize,0,0], extrasize_align=[extrasize_align,0,0]);

        for(z=[-1,1])
            translate([0,0,z*xaxis_rod_distance/2])
                translate([0, -xaxis_zaxis_distance_y, 0])
                bearing_mount_holes(zaxis_bearing, orient=[0,0,1], show_zips=false);

        if(with_motor)
        {
            translate([0,wy+.1,0])
            rotate([90,0,0])
            linear_extrude(2*wy+.2)
            stepper_motor_mount(17, slide_distance=0, mochup=false);
        }
    }

    if(with_motor && show_motor)
    {
        translate([0,wy,0])
        motor(xaxis_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);
    }

    /*translate([x*zmotor_mount_rod_offset_x, 0, 0])*/
    /*fncylindera(h=xaxis_rod_distance+xaxis_bearing[2], d=zaxis_nut[1], align=[0,0,0]);*/


    x = with_motor?1:-1;
    nut_h = 10*mm;
    translate([x*zaxis_rod_screw_distance_x, -xaxis_zaxis_distance_y, -wz/2])
    {
        difference()
        {
            union()
            {
                fncylindera(h=nut_h, d=zaxis_nut[1], align=[0,0,1]);
                translate([-1*x*zaxis_nut[1]/2,0,0])
                {
                    cubea([10,zaxis_nut[1]/2,nut_h],align=[x,-1,1]);
                    cubea([zaxis_nut[1]/2,zaxis_nut[1]/2,nut_h],align=[x,-1,1]);
                }
            }
            union()
            {
                fncylindera(h=10+1, d=zaxis_nut[0], center= false);
                for(i=[-1,1])
                translate([i*13.5, 0, -1]) fncylindera(h=5, r=1.6);
            }
        }
    }
}
