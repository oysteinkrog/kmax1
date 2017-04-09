include <y-idler.h>

use <thing_libutils/screws.scad>

module yaxis_idler(part)
{
    tighten_screw_dia_outer = yaxis_idler_mount_tightscrew_dia*4;
    mount_screw_dist = (yidler_w/2+yaxis_idler_mount_thread_dia*3)*1.3;

    if(part==U)
    {
        difference()
        {
            yaxis_idler(part="pos");
            yaxis_idler(part="neg");
        }
        yaxis_idler(part="vit");
    }
    else if(part=="pos")
    {
        // front plate
        tx(-extrusion_size/2)
        rcubea(
            size=[yaxis_idler_mount_thickness, yidler_mount_width, extrusion_size], 
            align=-X,
            extrasize=Z*yaxis_idler_mount_thickness,
            extrasize_align=Z
            );

        // top mount plate
        translate([-yaxis_idler_mount_thickness,0,extrusion_size/2])
        rcubea(
            size=[extrusion_size, yidler_mount_width, yaxis_idler_mount_thickness],
            align=Z,
            extrasize=[yaxis_idler_mount_thickness,0,0],
            extrasize_align=X
            );

        intersection()
        {
            tz(extrusion_size/2)
            cubea([100, yidler_mount_width, 100], align=Z);

            hull()
            {
                for(y=[-1,1])
                ty(y*yaxis_idler_tightscrew_dist)
                tx(-yaxis_idler_mount_thickness)
                tz(extrusion_size/2)
                {
                    translate([yaxis_idler_mount_thickness/2,0,yaxis_belt_path_offset_z])
                    rcylindera(
                        h=extrusion_size+yaxis_idler_mount_thickness,
                        d=tighten_screw_dia_outer,
                        align=N,
                        orient=X
                        );
                    rcubea(
                        size=[extrusion_size, mount_screw_dist-yaxis_idler_mount_tightscrew_dia*3, yaxis_idler_mount_thickness],
                        align=Z,
                        extrasize=[yaxis_idler_mount_thickness,0,0],
                        extrasize_align=X
                        );
                }
            }

        }

    }
    else if(part=="neg")
    {
        // top/vertical mount screws (to extrusion)
        translate([0,0,extrusion_size/2+yaxis_idler_mount_thickness])
        for(y=[-1,0,1])
        ty(y*mount_screw_dist/2)
        screw_cut(nut=extrusion_nut, head_embed=false, h=yaxis_idler_mount_thickness+5*mm, with_nut=false, orient=-Z, align=-Z);

        // mount screws for pulley block
        for(y=[-1,1])
        translate([
            -extrusion_size/2-yaxis_idler_mount_thickness,
            y*yaxis_idler_tightscrew_dist,
            extrusion_size/2+yaxis_belt_path_offset_z])
        screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=false, h=extrusion_size+yaxis_idler_mount_thickness+10*mm, with_nut=false, orient=X, align=X);

        // front/horizontal mount screws (to extrusion)
        tx(-extrusion_size/2)
        tx(-yaxis_idler_mount_thickness)
        for(y=[-1,1])
        ty(y*(yaxis_idler_mount_thread_dia*2.5))
        screw_cut(yaxis_idler_mount_tightscrew_hexnut, h=yaxis_idler_mount_thickness+5*mm, with_nut=false, orient=X, align=X); 
    }
}

module yaxis_idler_pulleyblock(part, show_pulley=false)
{
    h = yaxis_idler_pulley_h + 3*mm*2;
    if(part==U)
    {
        difference()
        {
            yaxis_idler_pulleyblock(part="pos");
            yaxis_idler_pulleyblock(part="neg");
        }
        %yaxis_idler_pulleyblock(part="vit");
    }
    else if(part=="pos")
    {
        rcubea([yaxis_idler_pulleyblock_supportsize, 2*yaxis_idler_pulleyblock_supportsize, h],
            align=N,
            extrasize=[yaxis_idler_pulley_tight_len,0,0], 
            extrasize_align=[-1,0,0]
            );
    }
    else if(part=="neg")
    {
        // pulley cutout
        tx(-3*mm)
        cubea(
            size=[yaxis_idler_pulley_outer_d, yaxis_idler_pulley_outer_d*3, yaxis_idler_pulley_h+0.5],
            align=N,
            extrasize=[20*mm,0,0], extrasize_align=X
            );

        // pulley screw
        tz(h/2)
        screw_cut(yaxis_idler_pulley_nut, h=h+5*mm, orient=[0,0,-1], align=[0,0,-1]);

        cylindera(d=yaxis_idler_pulley_thread_dia, h=h*2, orient=Z, align=N);

        for(y=[-1,1])
        translate([
            -yaxis_idler_pulleyblock_supportsize/2-yaxis_idler_pulley_tight_len,
            y*yaxis_idler_tightscrew_dist, 
            0
        ])
        screw_cut(yaxis_idler_mount_tightscrew_hexnut, head_embed=true, nut_offset=5*mm, h=yaxis_idler_pulley_tight_len, orient=X, align=X); 
    }
    else if(part=="vit")
    {
        pulley(pulley_2GT_20T_idler);
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
