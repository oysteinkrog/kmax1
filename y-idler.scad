include <y-idler.h>

use <thing_libutils/screws.scad>

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
                tighten_screw_dia_outer = yaxis_idler_mount_tightscrew_dia*4;
                mount_screw_dist = (yidler_w/2+yaxis_idler_mount_thread_dia*3)*1.3;
                union()
                {
                    translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
                    {
                        cubea(
                                size=[extrusion_size, yidler_mount_width, yaxis_idler_mount_thickness],
                                align=Z,
                                extrasize=[yaxis_idler_mount_thickness,0,0],
                                extrasize_align=X
                                );
                    }

                    difference()
                    {
                        hull()
                        {
                            for(y=[-1,1])
                            translate([0, y*yaxis_idler_tightscrew_dist, 0])
                            translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
                            {
                                translate([yaxis_idler_mount_thickness/2,0,yaxis_belt_path_offset_z])
                                cylindera(
                                        h=extrusion_size+yaxis_idler_mount_thickness,
                                        d=tighten_screw_dia_outer,
                                        align=N,
                                        orient=X
                                        );
                                cubea(
                                        size=[extrusion_size, mount_screw_dist-yaxis_idler_mount_tightscrew_dia*3, yaxis_idler_mount_thickness],
                                        align=Z,
                                        extrasize=[yaxis_idler_mount_thickness,0,0],
                                        extrasize_align=X
                                        );
                            }
                        }

                        translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
                        {
                            cubea(
                                size=[1000, 1000, 1000],
                                align=[0,0,-1]
                                );
                        }


                    }
                }

                // top/vertical mount screws (to extrusion)
                translate([0,0,extrusion_size/2+yaxis_idler_mount_thickness])
                {
                    for(i=[-1,0,1])
                    translate([0, i*mount_screw_dist/2, 0])
                    screw_cut(extrusion_nut, head_embed=false, h=extrusion_size+yaxis_idler_mount_thickness, with_nut=false, orient=[0,0,-1], align=[0,0,-1]);
                }


                // mount screws for pulley block
                for(y=[-1,1])
                translate([
                        -extrusion_size/2-yaxis_idler_mount_thickness,
                        y*yaxis_idler_tightscrew_dist,
                        extrusion_size/2+yaxis_belt_path_offset_z])
                    screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=true, h=extrusion_size+yaxis_idler_mount_thickness, with_nut=false, orient=X, align=X);

                translate([0,0,extrusion_size/2])
                cubea(size=[extrusion_size+1, yidler_mount_width, tighten_screw_dia_outer/2],
                        extrasize=[yaxis_idler_mount_thickness,0,0],
                        extrasize_align=X,
                        align=[-1,0,-1]);
            }

            translate([-extrusion_size/2,0,0])
            difference()
            {
                cubea([yaxis_idler_mount_thickness, yidler_mount_width, extrusion_size], align=[-1,0,0]);

                // front/horizontal mount screws (to extrusion)
                for(i=[-1,1])
                translate([0, i*(yaxis_idler_mount_thread_dia*2.5), 0])
                screw_cut(yaxis_idler_mount_tightscrew_hexnut, h=yaxis_idler_mount_thickness, with_nut=false, orient=[-1,0,0], align=[-1,0,0]); 
            }
        }
    }
}

module yaxis_idler_pulleyblock(show_pulley=false)
{
    if(show_pulley)
    {
        %pulley(pulley_2GT_20T_idler);
    }

    h = yaxis_idler_pulley_h + 3*mm*2;
    difference()
    {
        hull()
        {
            /*cylindera(d=yaxis_idler_pulley_inner_d*1.5, h=h, orient=Z, align=N);*/
            rcubea([yaxis_idler_pulleyblock_supportsize, 2*yaxis_idler_pulleyblock_supportsize, h],
                    align=N,
                    extrasize=[yaxis_idler_pulley_tight_len,0,0], 
                    extrasize_align=[-1,0,0]
                 );
            /*translate([-yaxis_idler_pulley_tight_len,0,0])*/
                /*cubea([yaxis_idler_pulley_inner_d, yaxis_idler_pulley_inner_d*1.5, h]);*/
        }

        // pulley cutout
        translate([-3*mm,0,0])
            cubea(
                    size=[yaxis_idler_pulley_outer_d, yaxis_idler_pulley_outer_d*3, yaxis_idler_pulley_h+0.5],
                    align=N,
                    extrasize=[20*mm,0,0], extrasize_align=X
                 );

        // pulley screw
        translate([0,0,h/2])
        {
            screw_cut(yaxis_idler_pulley_nut, h=h+5*mm, orient=[0,0,-1], align=[0,0,-1]);
        }

        cylindera(d=yaxis_idler_pulley_thread_dia, h=h*2, orient=Z, align=N);

        for(y=[-1,1])
        {
            translate([
                    -yaxis_idler_pulleyblock_supportsize/2-yaxis_idler_pulley_tight_len,
                    y*yaxis_idler_tightscrew_dist, 
                    0
            ])
            {
                screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=true, nut_offset=5*mm, h=yaxis_idler_pulley_tight_len, orient=X, align=X); 
            }
        }
    }

}

module part_y_idler()
{
    attach([N, [0,0,-1]], yaxis_idler_conn)
    {
        yaxis_idler();
    }
}


module part_y_idler_pulleyblock()
{
    attach([N, [0,0,-1]], yaxis_idler_pulleyblock_conn_print)
    {
        yaxis_idler_pulleyblock(show_pulley=false);
    }
}

/*yaxis_idler();*/
/*yaxis_idler_pulleyblock();*/

/*print_yaxis_idler();*/
/*print_yaxis_idler_pulleyblock();*/

/*attach([N,[-1,0,0]], yaxis_idler_conn)*/
/*{*/
    /*yaxis_idler();*/
    /*attach(yaxis_idler_conn_pulleyblock, yaxis_idler_pulleyblock_conn)*/
    /*{*/
        /*yaxis_idler_pulleyblock(show_pulley=true);*/
    /*}*/
/*}*/
