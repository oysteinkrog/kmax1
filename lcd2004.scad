include <thing_libutils/system.scad>
include <thing_libutils/units.scad>

include <config.scad>

use <thing_libutils/linear-extrusion.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/transforms.scad>

// wall thickness
lcd2004_wall_thick=4;
lcd2004_width=151+2*lcd2004_wall_thick;
lcd2004_depth=63.5+2*lcd2004_wall_thick;
mount_lcd2004_mount_angle=45;

module mount_lcd2004_parts(
    eps=[0.1,0.1,0], // gap for cavities
    part=undef,
    height=16*mm,
    align, orient, roll, extra_roll, extra_roll_orient
    )
{

    size_align(size=[lcd2004_width,lcd2004_depth,height], align=align, orient=orient, orient_ref=Z, roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    if(part==undef)
    {
        difference()
        {
            mount_lcd2004_parts(lcd2004_wall_thick=lcd2004_wall_thick, eps=eps, part="pos", height=height);
            mount_lcd2004_parts(lcd2004_wall_thick=lcd2004_wall_thick, eps=eps, part="neg", height=height);
        }
    }
    else if(part=="pos")
    {
        translate([-lcd2004_width/2,-lcd2004_depth/2,-height/2])
        rcubea(size=[lcd2004_width,lcd2004_depth,height], rounding_radius=3, align=[1,1,1]);
    }
    else if(part=="neg")
    mirror(Y)
    translate([-lcd2004_width/2,-lcd2004_depth/2,-height/2])
    translate([lcd2004_wall_thick,lcd2004_wall_thick,0])
    {
        // LCD cutout
        translate([14.5,10,-2])
        cubea([97,40,19], align=[1,1,1]);

        // LCD PCB
        translate([14,-0.25,4])
        cubea([98.5,60.5,9+10], align=[1,1,1]);

        // Main PCB
        translate([0,7.75,8]) 
        cubea([151,56,5+22], align=[1,1,1]);

        // Switch axis
        translate([137,35,-2]) 
        cylindera(r=8/2, h=19, align=Z);

        // buzzer
        translate([130+13.5/2,8+39+12.5/2,-2]) 
        cylindera(r=12.5/2, h=19, align=Z);

        // reset switch
        translate([137,16,-2]) 
        cylindera(r=2, h=19, align=Z);

        // buzzer/switch/reset
        translate([116,8,2]) 
        cubea([29,55.5,10], align=[1,1,1]);

        // buzzer/switch/reset
        translate([118,18,2]) 
        cubea([33,35.5,10], align=[1,1,1]);

        // buzzer/switch/reset
        translate([0,18,2]) 
        cubea([11,35.5,10], align=[1,1,1]);

        // SD slot
        translate([-lcd2004_wall_thick-1,17,9]) 
        cubea([lcd2004_wall_thick+2,27,10], align=[1,1,1]);

        // Screw hole for PCB
        translate([0+2.9,8+2.5,3]) 
        cylindera(r=2.5/2, h=6, align=Z);

        // Screw hole for PCB
        translate([151-2.7,8+2.5,3]) 
        cylindera(r=2.5/2, h=6, align=Z);

        // Screw hole for PCB
        translate([0+2.9,8+55.5-2.5,3]) 
        cylindera(r=2.5/2, h=6, align=Z);

        // Screw hole for PCB
        translate([151-2.7,8+55.5-2.5,3]) 
        cylindera(r=2.5/2, h=6, align=Z);

        // LCD pin header
        translate([14.5+8,60-5,2])
        cubea([42,8.5,9], align=[1,1,1]);

        // Anti-Warping
        translate([50,-lcd2004_wall_thick/2,2])
        cubea([2,55.5+8+lcd2004_wall_thick,11], align=[1,1,1]);

        // Anti-Warping
        translate([90,-lcd2004_wall_thick/2,2])
        cubea([2,55.5+8+lcd2004_wall_thick,11], align=[1,1,1]);
    }
}

module gantry_lower()
{
    color(color_extrusion)
    for(z=[-1,1])
    {
        translate([0,0,z*-main_lower_dist_z/2])
        {
            for(y=[-1,1])
            translate([0, y*(main_depth/2), 0])
            {
                if($preview_mode)
                {
                    cubea([main_width, extrusion_size, extrusion_size], align=[0,y,-1]);
                }
                else
                {
                    linear_extrusion(h=main_width, align=[0,y,-1], orient=X);
                }
            }

            for(x=[-1,1])
            translate([x*(main_width/2), 0, 0])
            {
                if($preview_mode)
                {
                    cubea([extrusion_size, main_depth, extrusion_size], align=[-x,0,-1]);
                }
                else
                {
                    linear_extrusion(h=main_depth, align=[-x,0,-1], orient=Y);
                }
            }
        }
    }
}

lcd2004_mount_thickness = 5*mm;
module lcd2004_extrusion_conn(part, orient=Z, align=N)
{
    s = [extrusion_size, extrusion_size, lcd2004_mount_thickness];
    size_align(size=s, orient=orient, orient_ref=Z, align=align)
    if(part==undef)
    {
        difference()
        {
            lcd2004_extrusion_conn(part="pos");
            lcd2004_extrusion_conn(part="neg");
        }
    }
    else if(part=="pos")
    {
        rcubea(size=s, rounding_radius=3);
    }
    else if(part=="neg")
    {
        translate([0,0,-lcd2004_mount_thickness/2])
        screw_cut(nut=extrusion_nut, with_nut=true, nut_cut_h=30, with_head=true, head_cut_h=30, length=12*mm, align=Z, orient=Z);
    }
}

lcd2004_offset = [0, -34.2*mm,-5*mm];

module mount_lcd2004(part, show_gantry=false)
{
    if(part==undef)
    {
        difference()
        {
            mount_lcd2004(part="pos", show_gantry=show_gantry);
            mount_lcd2004(part="neg", show_gantry=show_gantry);
        }
    }
    else if(part == "pos")
    {
        hull()
        {
            for(x=[-1,1])
            translate([x*(lcd2004_width/2+extrusion_size),0,0])
            {
                translate([0,0,main_lower_dist_z/2-extrusion_size])
                lcd2004_extrusion_conn(part=part, orient=Z, align=[-x,0,-1]);
            }

            for(x=[-1,1])
            translate([x*(lcd2004_width/2+extrusion_size),0,0])
            {
                translate([0,0,-main_lower_dist_z/2])
                lcd2004_extrusion_conn(part=part, orient=[0,0,-1], align=[-x,0,1]);
            }

            translate(lcd2004_offset)
            rotate([-mount_lcd2004_mount_angle,0,0])
            mount_lcd2004_parts(part=part, orient=Y, align=Y);

        }
        if(show_gantry)
        {
            translate([0,main_depth/2,0])
            translate([0,extrusion_size/2,0])
            gantry_lower();
        }

    }
    else if(part == "neg")
    {
        for(x=[-1,1])
        translate([x*(lcd2004_width/2+extrusion_size),0,0])
        {
            translate([0,0,main_lower_dist_z/2-extrusion_size])
            lcd2004_extrusion_conn(part=part, orient=Z, align=[-x,0,-1]);

            translate([0,0,-main_lower_dist_z/2])
            {
                lcd2004_extrusion_conn(part=part, orient=[0,0,-1], align=[-x,0,1]);
            }
        }

        translate([0,10*mm,-extrusion_size/2])
        /*#rcubea([lcd2004_width+30*mm, extrusion_size+.2, main_lower_dist_z-extrusion_size-lcd2004_mount_thickness*2]);*/
        rcubea([1000, extrusion_size+.2, main_lower_dist_z-extrusion_size-lcd2004_mount_thickness*2]);

        /*translate([0,0,-extrusion_size/2])*/
        /*rcubea([lcd2004_width, extrusion_size+.2, main_lower_dist_z-extrusion_size-lcd2004_mount_thickness*1]);*/


        translate(lcd2004_offset)
        rotate([-mount_lcd2004_mount_angle,0,0])
        {
            mount_lcd2004_parts(part=part, orient=Y, align=Y);

            translate([0,1000+5,0])
            rotate([90,0,0])
            linear_extrude(height=1000)
            projection(cut=false)
            rotate([-90,0,0])
            mount_lcd2004_parts(part=part, orient=Y, align=Y);
        }

        translate(lcd2004_offset)
        translate([0,27,-13])
        translate([0,1000,0])
        rotate([90,0,0])
        linear_extrude(height=1000)
        projection(cut=false)
        rotate([-90,0,0])
        mount_lcd2004_parts(part=part, orient=Y, align=Y);

        translate([0,main_depth/2,0])
        translate([0,extrusion_size/2,0])
        gantry_lower();
    }

}

module part_lcd2004_mount()
{
    rotate([90+mount_lcd2004_mount_angle,0,0])
    translate(-lcd2004_offset)
    mount_lcd2004();
}

/*if(false)*/
{
    mount_lcd2004(show_gantry=true);
}
