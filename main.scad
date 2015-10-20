include <thing_libutils/metric-thread.scad>;
include <thing_libutils/metric-hexnut.scad>;
use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;

include <MCAD/stepper.scad>
include <MCAD/motors.scad>

include <config.scad>
include <extruder-direct.scad>

xaxis_pos_z = 150*mm;

main();

module main()
{
    color(extrusion_color)
    gantry_lower();

    color(extrusion_color)
    translate([0,0,-main_lower_dist_z])
    gantry_lower();

    color(extrusion_color)
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
    translate([i*(main_width/2 + lookup(NemaSideSize,zaxis_motor)/2), 0, zaxis_motor_offset_z])
    {
        mirror([i==-1?1:0,0,0])
        {
            zmotor_mount();

            attach([[0,0,0],[0,0,0]],zmotor_mount_conn_motor)
            {
                // z motor/leadscrews
                motor(zaxis_motor, NemaMedium, dualAxis=false, orientation=[0,180,0]);
            }
        }

        // z smooth rods
        translate([i*zaxis_rod_screw_distance_x/2+zmotor_mount_motor_offset,0,0])
        {
            fncylindera(h=zaxis_rod_l,d=zaxis_rod_d,align=[0,0,1]);

            translate([0,0,xaxis_pos_z-zaxis_motor_offset_z])
                fncylindera(h=zaxis_bearing[2], d=zaxis_bearing[1], align=[0,0,0]);
        }
    }
}

zmotor_mount_motor_offset=5;
zmotor_mount_conn_motor=[[-zmotor_mount_motor_offset, 0, 0],[0,1,0]];

module zmotor_mount()
{
    motor_w = lookup(NemaSideSize,zaxis_motor);

    mount_thickness = 5;
    mount_thickness_h = 8;
    mount_thread_dia = lookup(ThreadSize, extrusion_thread);
    mount_width = motor_w+mount_thickness*2 + mount_thread_dia*8;
    mount_h = main_lower_dist_z+extrusion_size+zaxis_motor_offset_z;

    // side triangles
    translate([-motor_w/2, 0, 0])
    for(i=[-1,1])
    {
        translate([mount_thickness, i*((motor_w/2)+mount_thickness/2), 0])
        rotate([90,90,0])
        Right_Angled_Triangle(a=motor_w-mount_thickness+zmotor_mount_motor_offset, b=main_lower_dist_z+extrusion_size+zaxis_motor_offset_z, height=mount_thickness, centerXYZ=[0,0,1]);

        translate([0, i*((motor_w/2)+mount_thickness/2), 0])
        cubea([mount_thickness, mount_thickness, mount_h], align=[1,0,-1]);
    }

    // top mount plate
    difference()
    {
        translate([-motor_w/2,0,-extrusion_size-zaxis_motor_offset_z])
            cubea([mount_thickness, mount_width, extrusion_size], align=[1,0,1]);

        for(i=[-1,1])
            translate([-motor_w/2,i*(motor_w/2+mount_thread_dia*3),-extrusion_size])
                rotate([0,90,0])
                    fncylindera(h=mount_thickness*3,d=mount_thread_dia);
    }

    // bottom mount plate
    difference()
    {
        translate([-motor_w/2,0,-main_lower_dist_z-extrusion_size-zaxis_motor_offset_z])
            cubea([mount_thickness, mount_width, extrusion_size], align=[1,0,1]);

        for(i=[-1,1])
            translate([-motor_w/2,i*(motor_w/2+mount_thread_dia*3),-extrusion_size-main_lower_dist_z])
                rotate([0,90,0])
                fncylindera(h=mount_thickness*3,d=mount_thread_dia);
    }

/*#    cubea([motor_w+mount_thickness,motor_w+mount_thickness,zaxis_motor_offset_z], align=[0,0,-1]);*/

    // top plate
    difference()
    {
        cubea([motor_w, motor_w+mount_thickness*2, mount_thickness_h], align=[0,0,1], extrasize=[5,0,0], extrasize_align=[1,0,0]);

        translate([zmotor_mount_motor_offset,0,-1])
        linear_extrude(mount_thickness_h+2)
        stepper_motor_mount(17, slide_distance=0, mochup=false);
    }
}

module gantry_upper()
{
    for(i=[-1,1])
    translate([i*(main_width/2), 0])
    linear_extrusion(h=main_height, align=[-i,0,1], orient=[0,0,1]);

    translate([0, 0, main_height])
    linear_extrusion(h=main_upper_width, align=[0,0,1], orient=[1,0,0]);
}

module gantry_lower()
{
    for(i=[-1,1])
    translate([0,  i*(main_depth/2), 0]) 
    linear_extrusion(h=main_width, align=[0,i,-1], orient=[1,0,0]);

    for(i=[-1,1])
    translate([i*(main_width/2), 0, 0])
    linear_extrusion(h=main_depth, align=[-i,0,-1], orient=[0,1,0]);
}
