include <config.scad>;
include <thing_libutils/system.scad>;
include <thing_libutils/thread-data.scad>;
include <thing_libutils/nut-data.scad>;
use <thing_libutils/screws.scad>
use <thing_libutils/timing-belts.scad>


module belt_fastener(part, belt, belt_width, belt_dist, width=55*mm, thick, with_tensioner=true)
{
    belt_t2 = belt_t2_thickness(belt) + .2*mm;
    tension_screw_nut = NutHexM3;
    tension_screw_thread = ThreadM3;
    tension_screw_dia = lookup(ThreadSize, tension_screw_thread);
    angle_screw_thread = ThreadM4;
    angle_screw_dia = 3.25*mm;
    height = belt_t2*8;

    if(part==undef)
    {
        difference()
        {
            belt_fastener("pos", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, thick=thick, with_tensioner=with_tensioner);
            belt_fastener("neg", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, thick=thick, with_tensioner=with_tensioner);
        }
    }
    else if(part=="pos")
    {
        rcubea([width, belt_width, height], extrasize=[0,angle_screw_dia+3*mm,0], extrasize_align=-Y);
    }
    else if(part=="neg")
    {
        translate(-belt_dist*Z)
        {
            if(with_tensioner)
            {
                translate([0,0,belt_t2/4])
                cubea(size=[1000, belt_width+.1, belt_t2], extrasize=1000*Y, extrasize_align=Y);

                /*translate([0,0,angle_screw_dia/2])*/
                {
                    hull()
                    {
                        for(i=[-1,1])
                        translate(i*11*mm*X)
                        cylindera(d=angle_screw_dia+belt_t2, h=belt_width+.1, orient=Y);
                    }

                    hull()
                    {
                        /*translate(*8*mm*X)*/
                        for(i=[-1,1])
                        translate(i*10*mm*X)
                        translate(-belt_width*Y)
                        cylindera(d=angle_screw_dia+.2, h=10000, orient=Y, align=Y);
                    }

                    translate([0,-belt_width,0])
                    {
                        // cut for angle screw
                        translate(-1*2*mm*Y)
                        translate(-1*11*mm*X)
                        cylindera(d=angle_screw_dia+.2*mm, h=1000, orient=X, align=X);

                        translate(-1*11*mm*X)
                        nut_trap_cut(nut=tension_screw_nut, orient=-X, trap_axis=Y);

                        // cut for tension screw
                        translate(-1*25*mm*X)
                        /*translate(-width/2*X)*/
                        screw_cut(nut=tension_screw_nut, h=25*mm, with_head=true, head_embed=true, with_nut=false, orient=X, align=X);
                    }
                }

            }
            else
            {
                cubea([1000, belt_width+3*mm, belt_t2*1.8], extrasize=[0,0,1*mm], extrasize_align=Z);
            }

            translate(belt_dist*Z)
            cubea([1000, belt_width+3*mm, belt_t2*2]);
        }
    }
    else if(part=="vit")
    {
        translate(-belt_dist/2*Z)
        if(with_tensioner)
        {
            // 90 angle metal screw
            translate([0,0,angle_screw_dia/2])
            {
                translate([0,-angle_screw_dia/2,0])
                cylindera(d=angle_screw_dia+.2*mm, h=25*mm, orient=X, align=X);
                cylindera(d=angle_screw_dia+.2*mm, h=5*mm, orient=Y, align=Y+X);

                /*translate([0,-belt_width,0])*/
                /*{*/
                    /*translate(-1*11*mm*X)*/
                    /*#screw(thread=tension_screw_thread, orient=X, align=-X);*/
                /*}*/
            }
        }
    }
}

if(false)
{
    belt_fastener();
}
