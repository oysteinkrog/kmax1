include <belt_fastener.h>
use <thing_libutils/screws.scad>
use <thing_libutils/shapes.scad>
use <thing_libutils/timing-belts.scad>

module belt_fastener(part, belt=TimingBelt_GT2_2, belt_width=6*mm, belt_dist=pulley_2GT_20T[2], width=55*mm, with_tensioner=true, align=N, orient=X)
{
    belt_t2 = belt_t2_thickness(belt) + .2*mm;
    tension_screw_nut = NutHexM3;
    tension_screw_thread = ThreadM3;
    tension_screw_dia = lookup(ThreadSize, tension_screw_thread);
    angle_screw_thread = ThreadM4;
    angle_screw_dia = 3.25*mm;
    height = belt_dist + belt_t2 + angle_screw_dia + 3*mm;
    slide_width=20*mm;
    depth = belt_width + 10*mm;

    s= [width, depth, height];
    size_align(size=s, orient=orient, align=align, orient_ref=-X)
    {
        if(part==undef)
        {
            difference()
            {
                belt_fastener("pos", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, with_tensioner=with_tensioner, align=align, orient=orient);
                belt_fastener("neg", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, with_tensioner=with_tensioner, align=align, orient=orient);
            }
            %belt_fastener("vit", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, with_tensioner=with_tensioner, align=align, orient=orient);
        }
        else if(part=="pos")
        {
            hull()
            {
                translate(-belt_dist/2*Z)
                {
                    // support for belt path
                    rcubea([width, belt_width, belt_t2*2 + angle_screw_dia]);

                    translate(-belt_width*Y)
                    translate(-angle_screw_dia/2*Y)
                    rcubea([width, angle_screw_dia+2*mm, belt_t2*2 + angle_screw_dia]);
                }
            }
        }
        else if(part=="neg")
        {
            translate(-belt_dist/2*Z)
            if(with_tensioner)
            {
                translate([0,0,belt_t2/4])
                cubea(size=[1000, belt_width+.1, belt_t2], extra_size=1000*Y, extra_align=Y);

                /*translate([0,0,angle_screw_dia/2])*/
                {
                    hull()
                    {
                        for(i=[-1,1])
                        translate(i*11*mm*X)
                        cylindera(d=angle_screw_dia+belt_t2, h=belt_width+.1, extra_h=1000, extra_align=Y, orient=Y);
                    }

                    hull()
                    {
                        for(i=[-1,1])
                        translate(i*slide_width/2*X)
                        translate(-belt_width*Y)
                        translate(-angle_screw_dia*Y)
                        translate(-.1*Y)
                        cylindera(d=angle_screw_dia+.3*mm, h=1000, orient=Y, align=Y);
                    }

                    translate(-belt_width*Y)
                    {
                        // cut for angle screw
                        translate(-1*mm*Y)
                        translate(-12*mm*X)
                        {
                            cylindera(d=angle_screw_dia+.3*mm, h=1000, orient=X, align=X);
                            nut_trap_cut(nut=tension_screw_nut, screw_l=6*mm, cut_screw=true, orient=-X, trap_axis=Y);
                        }
                    }
                }

            }
            else
            {
                cubea([1000, belt_width+3*mm, belt_t2*1.8], extra_size=[0,1000,1*mm], extra_align=Y+Z);
            }

            translate(belt_dist/2*Z)
            cubea([1000, belt_width+3*mm, belt_t2*2], extra_size=1000*Y, extra_align=Y);
        }
        else if(part=="vit")
        {
            if(with_tensioner)
            {
                /*translate(-belt_dist/2*Z)*/
                /*translate(-belt_width*Y)*/
                /*translate(screw_offset_x*X)*/
                /*screw(nut=tension_screw_nut, h=25*mm, with_head=true, with_nut=false, head_embed=true, with_nut=false, orient=X, align=X);*/

                // 90 angle metal screw
                /*translate(screw_offset_x*X)*/
                translate(-belt_dist/2*Z)
                translate(-belt_width*Y)
                translate(-angle_screw_dia/2*Y)
                {
                    cylindera(d=angle_screw_dia+.2*mm, h=20*mm, orient=X, align=X);
                    cylindera(d=angle_screw_dia+.2*mm, h=11*mm, orient=Y, align=Y+X);
                }
            }
        }
    }
}

if(false)
{
    for(z=[-1,1])
    for(z=xaxis_beltpath_z_offsets)
    {
        translate([0, 0, z])
        {
            translate([0, xaxis_carriage_beltpath_offset_y, 0])
            translate([-main_width/2, 0, 0])
            rotate([90,0,0])
            belt_path(main_width, xaxis_belt_width, xaxis_pulley_inner_d, orient=X, align=X);

            proj_extrude_axis(axis=-Y)
            translate([0, xaxis_carriage_beltpath_offset_y, 0])
            mirror([0,0,sign(z)>1?1:0])
            /*mirror(X)*/
            belt_fastener();
        }
    }
}
