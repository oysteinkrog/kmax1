use <thing_libutils/shapes.scad>
use <thing_libutils/attach.scad>
use <thing_libutils/transforms.scad>
use <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>

include <y-motor-mount.h>

module yaxis_motor_mount_bearing_clamp(align=N)
{
    bearing_d = bearing_625[1];
    bearing_h = bearing_625[2];
    width=ymotor_w+ymotor_mount_thickness;
    depth=ymotor_w+ymotor_mount_thickness*2;
    height=yaxis_motor_mount_bearing_clamp_offset_z;

    /*size_align(size=[width,depth,height], align=align);*/
    difference()
    {
        cubea([width, depth, height], align=[0,0,-1]);

        ymotor_round_d = lookup(NemaRoundExtrusionDiameter, yaxis_motor);

        translate([0,0,.1])
            cylindera(h=bearing_h*2, d=bearing_d*rod_fit_tolerance, orient=Z, align=[0,0,-1]);

        // cutout for belt path
        cylindera(d=bearing_d, h=height*2, orient=Z, align=[0,0,-1]);
        translate([depth/2, 0, -bearing_h])
            cubea([depth, ymotor_round_d, height-bearing_h+1], align=[0,0,-1]);

        // cut out motor mount holes etc
        screw_dist = lookup(NemaDistanceBetweenMountingHoles, yaxis_motor);
        for(x=[-1,1])
        for(y=[-1,1])
        translate([x*screw_dist/2, y*screw_dist/2, 1])
        screw_cut(nut=extrusion_nut, h=12*mm, orient=Z, align=-Z);
    }

    // debug bearing
    %cylindera(h=bearing_h, d=bearing_d*rod_fit_tolerance, align=[0,0,-1], orient=Z);
}

module motor_mount_top(width, depth, height, belt_cutout=true, belt_cutout_orient=X, align=N)
{
    size_align(size=[width, depth, height], align=align);
    difference()
    {
        rcubea([width, depth, height], align=Z);

        ymotor_round_d = lookup(NemaRoundExtrusionDiameter, yaxis_motor);

        // cutout for belt path
        cylindera(d=ymotor_round_d, h=height*2, orient=Z, align=N);
        translate([0, 0,-1])
        cubea([depth/2, ymotor_round_d, height*2], align=[1,0,1]);

        // cut out motor mount holes etc
        translate([0,0,-1])
        linear_extrude(height+2)
        stepper_motor_mount(17, slide_distance=0, mochup=false);
    }
}

module yaxis_motor_mount(part)
{
    if(part==U)
    {
        difference()
        {
            yaxis_motor_mount(part="pos");
            yaxis_motor_mount(part="neg");
        }
        %yaxis_motor_mount(part="vit");
    }
    else if(part=="pos")
    {
        // top plate
        material(Mat_Plastic)
        union()
        {
            translate([0,0,yaxis_motor_offset_z])
            {
                // top plate
                tz(extrusion_size/2)
                tx(ymotor_mount_thickness)
                tx(ymotor_w/2)
                motor_mount_top(width=ymotor_w+ymotor_mount_thickness,
                    depth=ymotor_w+ymotor_mount_thickness*2,
                    height=ymotor_mount_thickness_h,
                    belt_cutout=true,
                    belt_cutout_orient=X);

                // reinforcement plate between motor and extrusion
                translate([0,0,extrusion_size/2])
                rcubea([ymotor_mount_thickness, ymotor_w+ymotor_mount_thickness*2, ymotor_h], align=[1,0,-1], extrasize=[0,0,ymotor_mount_thickness_h], extrasize_align=Z);

                // side triangles
                for(i=[-1,1])
                {
                    translate([ymotor_mount_thickness, i*((ymotor_w/2)+ymotor_mount_thickness/2), extrusion_size/2])
                        triangle(
                                ymotor_w+ymotor_mount_thickness/2,
                                main_lower_dist_z+extrusion_size+yaxis_motor_offset_z,
                                depth=ymotor_mount_thickness,
                                align=[1,0,-1],
                                orient=X
                                );

                    translate([0, i*((ymotor_w/2)+ymotor_mount_thickness/2), extrusion_size/2])
                    rcubea([ymotor_mount_thickness, ymotor_mount_thickness, ymotor_mount_h], align=[1,0,-1]);
                }
            }

            // top mount plate
            rcubea([ymotor_mount_thickness, ymotor_mount_width, extrusion_size], align=X);

            // bottom mount plate
            tz(-main_lower_dist_z)
            rcubea([ymotor_mount_thickness, ymotor_w+ymotor_mount_thickness*2, extrusion_size], align=X);

        }
    }
    else if(part=="neg")
    {
        // cutout for motor cables
        translate([0,0,-20*mm])
        cubea([ymotor_mount_thickness*3, 20*mm, ymotor_h], align=[0,0,-1]);

        // top mount plate screws
        tx(ymotor_mount_thickness)
        for(y=[-1,1])
        ty(y*(ymotor_w/2+ymotor_mount_thread_dia*3))
        screw_cut(nut=extrusion_nut, h=ymotor_mount_thickness*3, align=-X, orient=-X);

        // bottom mount plate screw
        tx(ymotor_mount_thickness)
        tz(-main_lower_dist_z)
        for(y=[0])
        ty(y*(ymotor_w/2+ymotor_mount_thread_dia*3))
        screw_cut(nut=extrusion_nut, h=ymotor_mount_thickness*3, align=-X, orient=-X);
    }
    else if(part=="vit")
    {
        attach(yaxis_motor_mount_conn_motor,[N,N])
        {
            motor(yaxis_motor, NemaMedium, dualAxis=false, orientation=[0,180,0]);

            tz(7*mm)
            rotate(180*X)
            %pulley(pulley_2GT_20T);
        }
    }
}

module part_y_motor_mount()
{
    attach(yaxis_motor_mount_conn_motor,[N,X])
    {
        yaxis_motor_mount();
    }
}

/*yaxis_motor_mount_bearing_clamp();*/
/*yaxis_motor_mount();*/
