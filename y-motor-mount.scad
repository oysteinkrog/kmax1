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
        cubea([width, depth, height], align=-Z);

        cylindera(h=bearing_h*2, d=bearing_d*rod_fit_tolerance, orient=Z, align=-Z, extra_h=.1, extra_align=Z);

        // cutout for belt path
        cylindera(d=bearing_d, h=height*2, orient=Z, align=-Z);
        t([depth/2, 0, -bearing_h])
        cubea([depth, ymotor_round_d, height-bearing_h+1], align=-Z);

        // cut out motor mount holes etc
        screw_dist = lookup(NemaDistanceBetweenMountingHoles, yaxis_motor);
        for(x=[-1,1])
        for(y=[-1,1])
        translate([x*screw_dist/2, y*screw_dist/2, 1])
        screw_cut(nut=extrusion_nut, head="button", h=12*mm, orient=Z, align=-Z);
    }

    // debug bearing
    %cylindera(h=bearing_h, d=bearing_d*rod_fit_tolerance, align=-Z, orient=Z);
}

module yaxis_motor_mount(part)
{
    width = ymotor_w+ymotor_mount_thickness;
    depth = ymotor_w+ymotor_mount_thickness*2;
    height = ymotor_mount_thickness_h;
    ymotor_round_d = lookup(NemaRoundExtrusionDiameter, yaxis_motor);

    motor_pos =
        + Z * yaxis_motor_offset_z
        + Z * extrusion_size/2
        + X * ymotor_mount_thickness
        + X * ymotor_w/2;


    if(part==U)
    {
        difference()
        {
            yaxis_motor_mount(part="pos");
            yaxis_motor_mount(part="neg");
        }
        if($show_vit)
        yaxis_motor_mount(part="vit");
    }
    else if(part=="pos")
    {
        // top plate
        material(Mat_Plastic)
        union()
        {
            t(motor_pos)
            motor_mount(part=part, model=yaxis_motor, size=NemaMedium, thickness=ymotor_mount_thickness_h, extra_size=[ymotor_mount_thickness, ymotor_mount_thickness*2]);

            tz(yaxis_motor_offset_z)
            {
                // reinforcement plate between motor and extrusion
                tz(extrusion_size/2)
                rcubea([ymotor_mount_thickness, ymotor_w+ymotor_mount_thickness*2, ymotor_h], align=X-Z, extra_size=[0,0,ymotor_mount_thickness_h], extra_align=Z);

                // side triangles
                tz(extrusion_size/2)
                for(y=[-1,1])
                ty(y*((ymotor_w/2)+ymotor_mount_thickness/2))
                {
                    tx(ymotor_mount_thickness)
                    triangle(
                            ymotor_w+ymotor_mount_thickness/2,
                            main_lower_dist_z+extrusion_size+yaxis_motor_offset_z,
                            depth=ymotor_mount_thickness,
                            align=X-Z,
                            orient=X
                            );

                    rcubea([ymotor_mount_thickness, ymotor_mount_thickness, ymotor_mount_h], align=X-Z);
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
        t(motor_pos)
        motor_mount(part=part, model=yaxis_motor, size=NemaMedium, thickness=ymotor_mount_thickness_h, extra_size=[ymotor_mount_thickness, ymotor_mount_thickness*2]);

        // cutout for belt path
        t(motor_pos)
        {
            cylindera(d=ymotor_round_d+1*mm, h=ymotor_mount_thickness_h+1, orient=Z, align=Z, extra_h=1, extra_align=-Z);
            cubea([depth/2, ymotor_round_d+1*mm, ymotor_mount_thickness_h+1], align=X+Z, extra_size=1*Z, extra_align=-Z);
        }

        // cutout for motor cables
        tz(-20*mm)
        cubea([ymotor_mount_thickness*3, 20*mm, ymotor_h], align=-Z);

        // top mount plate screws
        tx(ymotor_mount_thickness)
        for(y=[-1,1])
        ty(y*(ymotor_w/2+ymotor_mount_thread_dia*3))
        screw_cut(nut=extrusion_nut, head="button", h=ymotor_mount_thickness*3, align=-X, orient=-X);

        // bottom mount plate screw
        tx(ymotor_mount_thickness)
        tz(-main_lower_dist_z)
        for(y=[0])
        ty(y*(ymotor_w/2+ymotor_mount_thread_dia*3))
        screw_cut(nut=extrusion_nut, head="button", h=ymotor_mount_thickness*3, align=-X, orient=-X);
    }
    else if(part=="vit")
    {
        t(motor_pos)
        {
            motor_mount(part=part, model=yaxis_motor, size=NemaMedium, thickness=ymotor_mount_thickness_h, extra_size=[ymotor_mount_thickness, ymotor_mount_thickness*2]);

            tz(7*mm)
            rotate(180*X)
            pulley(pulley_2GT_20T);
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
