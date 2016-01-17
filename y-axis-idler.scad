use <thing_libutils/triangles.scad>
use <thing_libutils/metric-screw.scad>
include <thing_libutils/attach.scad>
include <config.scad>
include <pulley.scad>

yaxis_idler_conn = [[-extrusion_size/2, 0, 0], [-1,0,0]];

yidler_w = 2*yaxis_idler_pulley_inner_d;
yaxis_idler_mount_thread_dia = lookup(ThreadSize, extrusion_thread);

yaxis_idler_mount_tightscrew_dia = lookup(ThreadSize, ThreadM4);
yaxis_idler_mount_tightscrew_hexnut = MHexNutM4;
yaxis_idler_mount_tightscrew_hexnut_dia = lookup(MHexNutWidthMax, yaxis_idler_mount_tightscrew_hexnut);
yaxis_idler_mount_tightscrew_hexnut_thick = lookup(MHexNutThickness, yaxis_idler_mount_tightscrew_hexnut);

yidler_mount_width = yidler_w+yaxis_idler_mount_thickness*2 + yaxis_idler_mount_thread_dia*3.5*2;

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
                mount_screw_dist = (yidler_w/2+yaxis_idler_mount_thread_dia*3)*1.5;
                union()
                {
                    translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
                    {
                        cubea(
                                size=[extrusion_size, yidler_mount_width, yaxis_idler_mount_thickness],
                                align=[0,0,1],
                                extrasize=[yaxis_idler_mount_thickness,0,0],
                                extrasize_align=[1,0,0]
                                );
                    }

                    hull()
                    {
                        for(y=[-1,1])
                        translate([0, y*yaxis_idler_tightscrew_dist, 0])
                        translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
                        {
                            translate([yaxis_idler_mount_thickness/2,0,yaxis_belt_path_offset_z])
                            fncylindera(
                                    h=extrusion_size+yaxis_idler_mount_thickness,
                                    d=tighten_screw_dia_outer,
                                    align=[0,0,0],
                                    orient=[1,0,0]
                                    );
                            cubea(
                                    size=[extrusion_size, mount_screw_dist-yaxis_idler_mount_tightscrew_dia*3, yaxis_idler_mount_thickness],
                                    align=[0,0,1],
                                    extrasize=[yaxis_idler_mount_thickness,0,0],
                                    extrasize_align=[1,0,0]
                                    );
                        }
                    }
                }

                translate([0,0,extrusion_size/2+yaxis_idler_mount_thickness])
                {
                    for(i=[-1,0,1])
                    {
                        translate([0, i*mount_screw_dist/2, 0])
                        {
                            screw_cut(extrusion_nut, head_embed=false, h=extrusion_size+yaxis_idler_mount_thickness, with_nut=false, orient=[0,0,-1], align=[0,0,-1]);
                        }
                    }
                }


                for(y=[-1,1])
                    translate([
                            -extrusion_size/2-yaxis_idler_mount_thickness,
                            y*yaxis_idler_tightscrew_dist,
                            extrusion_size/2+yaxis_belt_path_offset_z])
                        screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=true, h=extrusion_size+yaxis_idler_mount_thickness, with_nut=false, orient=[1,0,0], align=[1,0,0]);

                translate([0,0,extrusion_size/2])
                cubea(size=[extrusion_size+1, yidler_mount_width, tighten_screw_dia_outer/2],
                        extrasize=[yaxis_idler_mount_thickness,0,0],
                        extrasize_align=[1,0,0],
                        align=[-1,0,-1]);
            }

            translate([-extrusion_size/2,0,0])
            difference()
            {
                cubea([yaxis_idler_mount_thickness, yidler_mount_width, extrusion_size], align=[-1,0,0]);

                for(i=[-1,1])
                    translate([0, i*(yidler_w/2+yaxis_idler_mount_thread_dia*3), 0])
                        screw_cut(yaxis_idler_mount_tightscrew_hexnut, h=yaxis_idler_mount_thickness, with_nut=false, orient=[-1,0,0], align=[-1,0,0]); 
            }
        }
    }
}

yaxis_idler_tightscrew_dist = 10*mm;
yaxis_idler_pulley_nut = MHexNutM5;
yaxis_idler_pulley_thread = ThreadM5;
yaxis_idler_pulley_thread_dia = lookup(ThreadSize, yaxis_idler_pulley_thread);
yaxis_idler_pulleyblock_supportsize = yaxis_idler_pulley_outer_d*1.2;
yaxis_idler_pulleyblock_wallthick = 5*mm;
yaxis_idler_pulleyblock_lenfrompulley = yaxis_idler_pulleyblock_supportsize/2 + yaxis_idler_pulley_tight_len;

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
            /*fncylindera(d=yaxis_idler_pulley_inner_d*1.5, h=h, orient=[0,0,1], align=[0,0,0]);*/
            cuberounda([yaxis_idler_pulleyblock_supportsize, 2*yaxis_idler_pulleyblock_supportsize, h],
                    align=[0,0,0],
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
                    align=[0,0,0],
                    extrasize=[20*mm,0,0], extrasize_align=[1,0,0]
                 );

        // pulley screw
        translate([0,0,h/2])
        {
            screw_cut(yaxis_idler_pulley_nut, h=h+5*mm, orient=[0,0,-1], align=[0,0,-1]);
        }

        fncylindera(d=yaxis_idler_pulley_thread_dia, h=h*2, orient=[0,0,1], align=[0,0,0]);

        for(y=[-1,1])
        {
            translate([
                    -yaxis_idler_pulleyblock_supportsize/2-yaxis_idler_pulley_tight_len,
                    y*yaxis_idler_tightscrew_dist, 
                    0
            ])
            {
                screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=true, nut_offset=5*mm, h=yaxis_idler_pulley_tight_len, orient=[1,0,0], align=[1,0,0]); 
            }
        }
    }

}

// the pulley block mounting point (mounting point in pulley block frame)
yaxis_idler_pulleyblock_conn = [[-yaxis_idler_pulleyblock_lenfrompulley, 0, 0], [-1,0,0]];

yaxis_idler_pulleyblock_conn_print = [[-yaxis_idler_pulleyblock_lenfrompulley, yaxis_idler_pulleyblock_supportsize/2, 0], [0,1,0]];

// the idler pulley block mounting point (mounting point in idler frame)
yaxis_idler_conn_pulleyblock = [[extrusion_size/2+yaxis_idler_mount_thickness, 0, extrusion_size/2+yaxis_belt_path_offset_z], [1,0,0]];

module print_yaxis_idler()
{
    attach([[0,0,0], [0,0,-1]], yaxis_idler_conn)
    {
        yaxis_idler();
    }
}


module print_yaxis_idler_pulleyblock()
{
    attach([[0,0,0], [0,0,-1]], yaxis_idler_pulleyblock_conn_print)
    {
        yaxis_idler_pulleyblock(show_pulley=false);
    }
}

/*yaxis_idler();*/
/*yaxis_idler_pulleyblock();*/

/*print_yaxis_idler();*/
/*print_yaxis_idler_pulleyblock();*/

/*attach([[0,0,0],[-1,0,0]], yaxis_idler_conn)*/
/*{*/
    /*yaxis_idler();*/
    /*attach(yaxis_idler_conn_pulleyblock, yaxis_idler_pulleyblock_conn)*/
    /*{*/
        /*yaxis_idler_pulleyblock(show_pulley=true);*/
    /*}*/
/*}*/
