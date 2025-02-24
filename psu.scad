include <psu.h>

use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;

module psu_a(align=N, detailed_model=true)
{
    if(detailed_model)
    {
        size_align([psu_a_w,psu_a_d,psu_a_h], align)
            translate([-24.5,105,-25])
            rotate([0,0,90])
            import("stl/ledpowersupply.stl");
    }
    else
    {
        size_align([psu_a_w,psu_a_d,psu_a_h], align)
        difference()
        {
            cubea([psu_a_w,psu_a_d,psu_a_h]);

            // screw holes, sides
            for(x=[-1,1])
                for(y=[-1,1])
                    for(z=[-1,1])
                        translate([x*(psu_a_w/2+1), y*(psu_a_screw_dist_y/2), z*psu_a_screw_side_dist_z/2])
                            rcylindera(d=psu_a_screw_thread_dia, h=0.5*cm, orient=X, align=[-x,0,0]);

            // screw holes, bottom
            for(x=[-1,1])
                for(y=[-1,1])
                    translate([x*(psu_a_screw_bottom_dist_x/2), y*(psu_a_screw_dist_y/2), -psu_a_h/2-1])
                        rcylindera(d=psu_a_screw_thread_dia, h=1*cm, orient=Z, align=Z);
        }
    }
}


module psu_a_extrusion_bracket_side()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_a_screw_bottom_dist_x/2), 0, -psu_a_h/2])
                    rcylindera(d=psu_a_screw_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(y=[-1,1])
                translate([psu_a_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_a_h/2])
                    rcylindera(d=extrusion_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_a_screw_bottom_dist_x/2), 0, -psu_a_h/2+1])
                rcylindera(d=psu_a_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(y=[-1,1])
            translate([psu_a_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_a_h/2+1])
                rcylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

module psu_a_extrusion_bracket_back()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_a_screw_bottom_dist_x/2), 0, -psu_a_h/2])
                    rcylindera(d=psu_a_screw_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(x=[-1,1])
                translate([x*psu_a_screw_bottom_dist_x/2, -psu_a_screw_dist_y/2+psu_a_d/2+extrusion_size/2, -psu_a_h/2])
                    rcylindera(d=extrusion_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_a_screw_bottom_dist_x/2), 0, -psu_a_h/2+1])
                cylindera(d=psu_a_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(x=[-1,1])
            translate([x*psu_a_screw_bottom_dist_x/2, -psu_a_screw_dist_y/2+psu_a_d/2+extrusion_size/2, -psu_a_h/2+1])
                cylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

module psu_b(align=N)
{
    {
        size_align([psu_b_w,psu_b_d,psu_b_h], align)
        difference()
        {
            rcubea([psu_b_w,psu_b_d,psu_b_h]);

            // screw holes, sides
            /*for(x=[-1,1])*/
                /*for(y=[-1,1])*/
                    /*for(z=[-1,1])*/
                        /*translate([x*(psu_b_w/2+1), y*(psu_b_screw_dist_y/2), z*psu_b_screw_side_dist_z/2])*/
                            /*cylindera(d=psu_b_screw_thread_dia, h=0.5*cm, orient=X, align=[-x,0,0]);*/

            // screw holes, bottom
            for(x=[-1,1])
                for(y=[-1,1])
                    translate([x*(psu_b_screw_bottom_dist_x/2), psu_b_screw_offset_y+y*(psu_b_screw_dist_y/2), -psu_b_h/2-1])
                        cylindera(d=psu_b_screw_thread_dia, h=1*cm, orient=Z, align=Z);
        }
    }
}

module psu_b_extrusion_bracket_side()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_b_screw_bottom_dist_x/2), 0, -psu_b_h/2])
                    rcylindera(d=psu_b_screw_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(y=[-1,1])
                translate([psu_b_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_b_h/2])
                    rcylindera(d=extrusion_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_b_screw_bottom_dist_x/2), 0, -psu_b_h/2+1])
                cylindera(d=psu_b_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(y=[-1,1])
            translate([psu_b_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_b_h/2+1])
                cylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

module psu_b_extrusion_bracket_back()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_b_screw_bottom_dist_x/2), psu_b_screw_offset_y, -psu_b_h/2])
                    rcylindera(d=psu_b_screw_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(x=[-1,1])
                translate([x*psu_b_screw_bottom_dist_x/2, -psu_b_screw_dist_y/2+psu_b_d/2+extrusion_size/2, -psu_b_h/2])
                    rcylindera(d=extrusion_thread_dia*3, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_b_screw_bottom_dist_x/2), psu_b_screw_offset_y, -psu_b_h/2+1])
                cylindera(d=psu_b_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(x=[-1,1])
            translate([x*psu_b_screw_bottom_dist_x/2, -psu_b_screw_dist_y/2+psu_b_d/2+extrusion_size/2, -psu_b_h/2+1])
                cylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

module part_psu_a_extrusion_bracket_side()
{
    psu_a_extrusion_bracket_side();
}

module part_psu_a_extrusion_bracket_back()
{
    psu_a_extrusion_bracket_back();
}

module part_psu_b_extrusion_bracket_side()
{
    psu_b_extrusion_bracket_side();
}

module part_psu_b_extrusion_bracket_back()
{
    psu_b_extrusion_bracket_back();
}

/*psu_a();*/

/*translate([0, -psu_a_screw_dist_y/2, 0])*/
/*psu_a_extrusion_bracket_side();*/

/*translate([0, psu_a_screw_dist_y/2, 0])*/
/*psu_a_extrusion_bracket_back();*/

/*psu_b();*/

/*translate([0, psu_b_screw_offset_y-psu_b_screw_dist_y/2, 0])*/
/*psu_b_extrusion_bracket_side();*/

/*translate([0, psu_b_screw_dist_y/2, 0])*/
/*psu_b_extrusion_bracket_back();*/
