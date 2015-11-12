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

include <x-carriage.scad>

axis_pos_x = 0*mm;
axis_range_z=[85,380];
axis_pos_z = axis_range_z[1]*mm/2;

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
    translate([0,10,axis_pos_z])
    {
        translate([axis_pos_x,0,0])
        {
            // x carriage
            translate([0,xaxis_zaxis_distance_y,0])
            /*translate([0,-xaxis_bearing[1]/2,0])*/
            /*rotate([90,0,180])*/
            attach(xaxis_carriage_conn, [[0,0,0],[0,0,1]])
                x_carriage(show_bearings=true);

            attach([[-motor_offset_x-motorWidth(extruder_motor)/2+10, -1, -17], [0,0,0]], extruder_conn_xcarriage)
            {
                extruder();
            }
        }

        // x smooth rods
        for(i=[-1,1])
            translate([0,xaxis_zaxis_distance_y,i*(xaxis_rod_distance/2)])
                fncylindera(h=xaxis_rod_l,d=xaxis_rod_d, orient=[1,0,0]);
    }

    // y smooth rods
    translate([0,0,yaxis_bearing[0]/2])
    {
        for(i=[-1,1])
        translate([i*(yaxis_rod_distance/2), 0, 0])
        {
            fncylindera(h=yaxis_rod_l,d=yaxis_rod_d, orient=[0,1,0]);

            for(j=[-1,1])
                translate([0,j*(yaxis_rod_distance/2),0])
                    bearing(yaxis_bearing, orient=[0,1,0]);
        }

        translate([0,0,yaxis_bearing[1]/2])
        {
            // y axis plate
            cubea(ycarriage_size, align=[0,0,1]);
        }
    }

    // z axis
    for(i=[-1,1])
    {
        translate([i*(main_width/2),0,main_height])
        {
            mirror([i==-1?1:0,0,0])
            upper_gantry_zrod_connector();
        }


        translate([i*(main_width/2 + lookup(NemaSideSize,zaxis_motor)/2), 0, 0])
        {
            translate([0,0,zaxis_motor_offset_z])
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
            translate([i*(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,0])
            {
                translate([0,0,zaxis_motor_offset_z-50])
                    fncylindera(h=zaxis_rod_l,d=zaxis_rod_d, align=[0,0,1]);

                for(j=[-1,1])
                    translate([0,0,axis_pos_z-j*xaxis_rod_distance/2])
                        bearing(zaxis_bearing);

            }

            translate([i*zmotor_mount_motor_offset, 0, axis_pos_z-xaxis_rod_distance/2-10])
            {
                difference()
                {
                    fncylindera(h=10, d=zaxis_nut[1], align=[0,0,0]);
                    union()
                    {
                        fncylindera(h=10+1, d=zaxis_nut[0], center= false);
                        translate([0, 13.5, -1]) fncylindera(h=5, r=1.6);
                        translate([0, -13.5, -1]) fncylindera(h=5, r=1.6);
                    }
                }
            }
        }
    }
}

module upper_gantry_zrod_connector()
{
    upper_width_extra = main_upper_width-main_width;
    difference()
    {
        union()
        {
            hull()
            {
                // attach to z rod
                translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
                translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,0])
                {
                    cubea([gantry_connector_thickness,zaxis_rod_d*4,extrusion_size+gantry_connector_thickness], align=[-1,0,1]);
                }

                // connect upper gantry
                translate([upper_width_extra/2, 0, 0])
                    translate([0,0,extrusion_size/2])
                    cubea([gantry_connector_thickness,main_upper_dist_y+extrusion_size,extrusion_size], align=[1,0,0], extrasize=[0,0,gantry_connector_thickness], extrasize_align=[0,0,1]);
            }

            translate([upper_width_extra/2, 0, 0])
                translate([0,0,extrusion_size])
                cubea([extrusion_size*1.5,main_upper_dist_y+extrusion_size,gantry_connector_thickness], align=[-1,0,1]);

        }

        // cutout for z rod
        translate([lookup(NemaSideSize,zaxis_motor)/2, 0, 0])
        translate([(zaxis_rod_screw_distance_x+zmotor_mount_motor_offset),0,extrusion_size])
        fncylindera(d=zaxis_rod_d*1.01, h=extrusion_size*3, align=[0,0,0], orient=[0,0,1]);
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
                fncylindera(h=mount_thickness*3,d=mount_thread_dia, orient=[1,0,0]);
    }

    // bottom mount plate
    difference()
    {
        translate([-motor_w/2,0,-main_lower_dist_z-extrusion_size-zaxis_motor_offset_z])
            cubea([mount_thickness, mount_width, extrusion_size], align=[1,0,1]);

        for(i=[-1,1])
            translate([-motor_w/2,i*(motor_w/2+mount_thread_dia*3),-extrusion_size-main_lower_dist_z])
                fncylindera(h=mount_thickness*3,d=mount_thread_dia,align=[0,0,0], orient=[1,0,0]);
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


main();
