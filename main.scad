use <thing_libutils/utils-shapes.scad>;
use <thing_libutils/utils-misc.scad>;
use <thing_libutils/utils-attach.scad>;
include <MCAD/stepper.scad>
include <MCAD/motors.scad>

include <config.scad>
include <extruder-direct.scad>

xaxis_pos_z = 150*mm;

main();

module main()
{
    gantry_lower();
    translate([0,0,-main_lower_dist_z])
    gantry_lower();

    for(i=[-1,1])
    translate([0,i*(main_upper_dist_y/2),0])
    gantry_upper();

    // x axis
    translate([0,0,xaxis_pos_z])
    {
        attach([[0,0,0],[0,0,0]],extruder_conn_xcarriage)
            extruder();

        // x smooth rods
        for(i=[-1,1])
            translate([0,xaxis_zaxis_distance_y,i*(xaxis_rod_distance/2)])
                rotate([0,90,0])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d);
    }

    // y smooth rods
    for(i=[-1,1])
    translate([i*(yaxis_rod_distance/2),0,0])
    {
        rotate([90,0,0])
            fncylindera(h=yaxis_rod_l,d=yaxis_rod_d, align=[0,1,0]);
    }

    translate([0,0,yaxis_rod_d])
        cubea(ycarriage_size, align=[0,0,1]);

    // z axis
    for(i=[-1,1])
    translate([i*(main_width/2 + lookup(NemaSideSize,zaxis_motor)/2),0,zaxis_motor_offset_z])
    {
        // z motor/leadscrews
        motor(zaxis_motor, NemaMedium, dualAxis=false, orientation=[0,180,0]);

        // z smooth rods
        translate([i*zaxis_rod_screw_distance_x/2,0,0])
        {
            fncylindera(h=zaxis_rod_l,d=zaxis_rod_d,align=[0,0,1]);

            translate([0,0,xaxis_pos_z-zaxis_motor_offset_z])
                fncylindera(h=zaxis_bearing[2], d=zaxis_bearing[1], align=[0,0,0]);
        }
    }

}

module extrusion(h, w, l) {
    rotate([90, 0, 90]) {
        translate([2.5, 2.5, 0]) cube([h - 5, w - 5, l]);
        translate([0, 0, 0.1]) cube([h, w, l - 0.2]);
    }
}

module gantry_upper()
{
    for(i=[-1,1])
    translate([i*(main_width/2), 0]) 
    rotate([0,0,90])
    cubea([extrusion_size,extrusion_size,main_height], align=[0,i,1]);

    translate([0, 0, main_height]) 
    cubea([main_upper_width,extrusion_size,extrusion_size], align=[0,0,1]);
}

module gantry_lower()
{
    for(i=[-1,1])
    translate([0,  i*(main_depth/2), 0]) 
    cubea([main_width,extrusion_size,extrusion_size], align=[0,i,-1]);

    for(i=[-1,1])
    translate([i*(main_width/2), 0]) 
    rotate([0,0,90])
    cubea([main_depth,extrusion_size,extrusion_size], align=[0,i,-1]);
}
