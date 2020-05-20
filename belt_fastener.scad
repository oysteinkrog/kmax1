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
    tighten_range=10*mm;
    belt_hook_dia=4*mm;
    belt_hook_offset=tighten_range+5*mm;

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
            if($show_vit)
            belt_fastener("vit", belt=belt, belt_width=belt_width, belt_dist=belt_dist, width=width, with_tensioner=with_tensioner, align=align, orient=orient);
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
                for(i=[-1,1])
                tz(belt_t2/4)
                {
                    tx(-tighten_range)
                    cubea(size=[1000, belt_width+.5, belt_t2], align=-X, extra_size=1000*Y, extra_align=Y);

                    tx(belt_hook_offset+belt_hook_dia/2)
                    cubea(size=[1000, belt_width+.5, belt_t2], align=X, extra_size=1000*Y, extra_align=Y);
                }

                /*translate([0,0,angle_screw_dia/2])*/
                {
                    hull()
                    for(i=[-1,1])
                    tx(i*tighten_range)
                    cylindera(d=angle_screw_dia+belt_t2, h=belt_width+.1, extra_h=1000, extra_align=Y, orient=Y);

                    // belt loop fasten
                    tx(belt_hook_offset)
                    difference()
                    {
                        cylindera(d=belt_hook_dia+belt_t2+.25*mm, h=belt_width+.1, extra_h=1000, extra_align=Y, orient=Y);
                        cylindera(d=belt_hook_dia, h=belt_width+.3, extra_h=1000, extra_align=Y, orient=Y);
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
                        translate(-25*mm*X)
                        {
                            cylindera(d=angle_screw_dia+.3*mm, h=1000, orient=X, align=X);

                            nut_trap_cut(
                                nut=tension_screw_nut,
                                screw_l=20*mm,
                                screw_offset=5*mm,
                                cut_screw=true,
                                cut_screw_close=true,
                                orient=X,
                                trap_axis=Y);
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
                material(Mat_Steel)
                translate(-belt_dist/2*Z)
                translate(-belt_width*Y)
                translate(-angle_screw_dia/2*Y)
                {
                    cylindera(d=angle_screw_dia+.2*mm, h=20*mm, orient=X, align=X);
                    tx(-angle_screw_dia/2)
                    cylindera(d=angle_screw_dia+.2*mm, h=11*mm, orient=Y, align=Y+X);
                }
            }
        }
    }
}

if(false)
{
    for(z=xaxis_beltpath_z_offsets)
    {
        tz(z)
        {
            ty(xaxis_carriage_beltpath_offset_y)
            tx(-main_width/2)
            rx(90)
            belt_path(main_width, xaxis_belt_width, xaxis_pulley_inner_d, orient=X, align=X);

            /*proj_extrude_axis(axis=-Y)*/
            ty(xaxis_carriage_beltpath_offset_y)
            mirror([0,0,sign(z)>1?1:0])
            mirror([sign(z)<1?1:0,0,0])
            belt_fastener();
        }
    }
}
