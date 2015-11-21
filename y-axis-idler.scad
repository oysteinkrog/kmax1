use <thing_libutils/triangles.scad>
include <thing_libutils/attach.scad>
include <config.scad>

yaxis_idler_mount_conn = [[0,0,+extrusion_size/2+yaxis_idler_offset_z],[1,0,0]];
yaxis_idler_mount_conn_idler = [[+yaxis_idler_offset_x, 0,+extrusion_size/2+yaxis_idler_offset_z],[0,0,1]];

yidler_w = yaxis_pulley_d;
/*yidler_h = lookup(NemaLengthLong, yaxis_idler);*/
yaxis_idler_mount_thread_dia = lookup(ThreadSize, extrusion_thread);

/*yidler_mount_h = main_lower_dist_z+extrusion_size+yaxis_idler_offset_z;*/
yidler_mount_width = yidler_w+yaxis_idler_mount_thickness*2 + yaxis_idler_mount_thread_dia*8;

/*yaxis_idler_pulley_h = 17.5*mm;*/
/*yaxis_idler_mount_bearing_clamp_offset_z = yaxis_idler_pulley_h;*/

module yaxis_idler()
{
    difference()
    {
        // top plate
        union()
        {
            // top mount plate
            difference()
            {
                tighten_screw_dia_outer = yaxis_idler_mount_thread_dia*4;
                mount_screw_dist = (yidler_w/2+yaxis_idler_mount_thread_dia*3)*2;
                union()
                {
                    translate([0,0,extrusion_size/2])
                    {
                        cubea(
                                size=[extrusion_size, yidler_mount_width, yaxis_idler_mount_thickness],
                                extrasize=[yaxis_idler_mount_thickness*2,0,0],
                                extrasize_align=[0,0,0],
                                align=[-1,0,1]);
                    }

                    hull()
                    {
                        translate([-extrusion_size/2,0,extrusion_size/2])
                            translate([0,0,yaxis_belt_path_offset_z])
                            fncylindera(
                                    h=extrusion_size,
                                    d=tighten_screw_dia_outer,
                                    align=[0,0,0],
                                    orient=[1,0,0],
                                    extra_h=yaxis_idler_mount_thickness*2,
                                    extra_align=[0,0,0]
                                    );
                        translate([0,0,extrusion_size/2])
                        {
                            cubea(
                                    size=[extrusion_size, mount_screw_dist-yaxis_idler_mount_thread_dia*2, yaxis_idler_mount_thickness],
                                    extrasize=[yaxis_idler_mount_thickness*2,0,0],
                                    extrasize_align=[0,0,0],
                                    align=[-1,0,1]);
                        }
                    }
                }

                translate([-extrusion_size/2,0,extrusion_size/2])
                {
                    for(i=[-1,1])
                        translate([0, i*mount_screw_dist/2, 0])
                            fncylindera(h=yaxis_idler_mount_thickness*3,d=yaxis_idler_mount_thread_dia, orient=[0,0,1]);

                    // cutout tighten screw
                    translate([0,0,yaxis_belt_path_offset_z])
                    fncylindera(h=extrusion_size*3,d=yaxis_idler_mount_thread_dia, orient=[1,0,0]);

                    // cutout tighten screw
                    translate([-extrusion_size/2-yaxis_idler_mount_thickness-.1,0,yaxis_belt_path_offset_z])
                    fncylindera(h=extrusion_size,d=yaxis_idler_mount_thread_dia*2, orient=[1,0,0], align=[1,0,0]);
                }

                translate([0,0,extrusion_size/2])
                cubea(size=[extrusion_size+1, yidler_mount_width, tighten_screw_dia_outer/2],
                        extrasize=[yaxis_idler_mount_thickness,0,0],
                        extrasize_align=[1,0,0],
                        align=[-1,0,-1]);
            }

            translate([-extrusion_size,0,0])
            difference()
            {
                cubea([yaxis_idler_mount_thickness, yidler_mount_width, extrusion_size], align=[-1,0,0]);

                for(i=[-1,1])
                    translate([0, i*(yidler_w/2+yaxis_idler_mount_thread_dia*3), 0])
                        fncylindera(h=yaxis_idler_mount_thickness*3,d=yaxis_idler_mount_thread_dia, orient=[1,0,0]);
            }

            /*difference()*/
            /*{*/
                /*cubea([yaxis_idler_mount_thickness, yidler_mount_width, extrusion_size], align=[1,0,0]);*/

                /*for(i=[-1,1])*/
                    /*translate([0, i*(yidler_w/2+yaxis_idler_mount_thread_dia*3), 0])*/
                        /*fncylindera(h=yaxis_idler_mount_thickness*3,d=yaxis_idler_mount_thread_dia, orient=[1,0,0]);*/
            /*}*/

            /*// bottom mount plate*/
            /*translate([0,0,-main_lower_dist_z])*/
            /*{*/
                /*difference()*/
                /*{*/
                    /*cubea([yaxis_idler_mount_thickness, yidler_w, extrusion_size], align=[1,0,0]);*/

                    /*for(i=[0])*/
                        /*translate([0, i*(yidler_w/2+yaxis_idler_mount_thread_dia*3), 0])*/
                            /*fncylindera(h=yaxis_idler_mount_thickness*3,d=yaxis_idler_mount_thread_dia,align=[0,0,0], orient=[1,0,0]);*/
                /*}*/
            /*}*/

        }

    }
}

module yaxis_idler_pulleyblock(show_bearing=false)
{
    translate([yaxis_idler_pulley_offset_y,0,yaxis_belt_path_offset_z+yaxis_bearing[1]/2])
    {
        if(show_bearing)
        {
            %fncylindera(d=yaxis_pulley_d, h=yaxis_idler_pulley_h, orient=[0,0,1]);
        }

        yaxis_idler_pulley_thread = ThreadM5;
        yaxis_idler_pulley_thread_dia = lookup(ThreadSize, yaxis_idler_pulley_thread);

        h = yaxis_idler_pulley_h + 5*mm*2;
        difference()
        {
            hull()
            {
                fncylindera(d=yaxis_pulley_d*1.5, h=h, orient=[0,0,1], align=[0,0,0]);
                translate([-yaxis_idler_pulley_tight_len,0,0])
                    cubea([yaxis_pulley_d, yaxis_pulley_d*1.5, h]);
            }

            // pulley cutout
            translate([-3*mm,0,0])
            cubea(
            size=[yaxis_pulley_d, yaxis_pulley_d*3, yaxis_idler_pulley_h+0.5],
            align=[0,0,0],
            extrasize=[20*mm,0,0], extrasize_align=[1,0,0]
            );

            // pulley screw
            translate([0,0,yaxis_idler_pulley_h/2+1])
            {
                fncylindera(d=yaxis_idler_pulley_thread_dia, h=h*2, orient=[0,0,1], align=[0,0,z]);
            }

            fncylindera(d=yaxis_idler_pulley_thread_dia, h=h*2, orient=[0,0,1], align=[0,0,z]);
        }
    }

}

/*yaxis_idler();*/
/*yaxis_idler_pulleyblock(show_bearing=true);*/
