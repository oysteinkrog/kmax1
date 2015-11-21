use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
include <thing_libutils/metric-thread.scad>;
include <thing_libutils/metric-hexnut.scad>;

include <config.scad>

psu_w=11.5*cm;
psu_d=21.5*cm;
psu_h=5*cm;
psu_screw_side_dist_z = 2.5*cm;
psu_screw_dist_y = 15*cm;
psu_screw_bottom_dist_x = 5*cm;

psu_screw_thread = ThreadM4;
psu_screw_thread_dia = lookup(ThreadSize, psu_screw_thread);

psu_mount_bottom_height = 5*mm;


module psu(align=[0,0,0], detailed_model=true)
{
    if(detailed_model)
    {
        size_align([psu_w,psu_d,psu_h], align)
            translate([-24.5,105,-25])
            rotate([0,0,90])
            import("stl/ledpowersupply.stl");
    }
    else
    {
        size_align([psu_w,psu_d,psu_h], align)
        difference()
        {
            cubea([psu_w,psu_d,psu_h]);

            // screw holes, sides
            for(x=[-1,1])
                for(y=[-1,1])
                    for(z=[-1,1])
                        translate([x*(psu_w/2+1), y*(psu_screw_dist_y/2), z*psu_screw_side_dist_z/2])
                            fncylindera(d=psu_screw_thread_dia, h=0.5*cm, orient=[1,0,0], align=[-x,0,0]);

            // screw holes, bottom
            for(x=[-1,1])
                for(y=[-1,1])
                    translate([x*(psu_screw_bottom_dist_x/2), y*(psu_screw_dist_y/2), -psu_h/2-1])
                        fncylindera(d=psu_screw_thread_dia, h=1*cm, orient=[0,0,1], align=[0,0,1]);
        }
    }
}


module psu_extrusion_bracket_side()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_screw_bottom_dist_x/2), 0, -psu_h/2])
                    fncylindera(d=psu_screw_thread_dia*4, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(y=[-1,1])
                translate([psu_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_h/2])
                    fncylindera(d=extrusion_thread_dia*4, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_screw_bottom_dist_x/2), 0, -psu_h/2+1])
                fncylindera(d=psu_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(y=[-1,1])
            translate([psu_w/2+extrusion_size/2, y*extrusion_side_screw_dist/2, -psu_h/2+1])
                fncylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

module psu_extrusion_bracket_back()
{
    extrusion_side_screw_dist = 3*cm;
    difference()
    {
        hull()
        {
            for(x=[-1,1])
                translate([x*(psu_screw_bottom_dist_x/2), 0, -psu_h/2])
                    fncylindera(d=psu_screw_thread_dia*4, h=psu_mount_bottom_height, align=[0,0,-1]);

            for(x=[-1,1])
                translate([x*psu_screw_bottom_dist_x/2, -psu_screw_dist_y/2+psu_d/2+extrusion_size/2, -psu_h/2])
                    fncylindera(d=extrusion_thread_dia*4, h=psu_mount_bottom_height, align=[0,0,-1]);
        }

        for(x=[-1,1])
            translate([x*(psu_screw_bottom_dist_x/2), 0, -psu_h/2+1])
                fncylindera(d=psu_screw_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);

        for(x=[-1,1])
            translate([x*psu_screw_bottom_dist_x/2, -psu_screw_dist_y/2+psu_d/2+extrusion_size/2, -psu_h/2+1])
                fncylindera(d=extrusion_thread_dia, h=psu_mount_bottom_height*2, align=[0,0,-1]);
    }
}

/*psu();*/

/*translate([0, -psu_screw_dist_y/2, 0])*/
/*psu_extrusion_bracket_side();*/

/*translate([0, psu_screw_dist_y/2, 0])*/
/*psu_extrusion_bracket_back();*/
