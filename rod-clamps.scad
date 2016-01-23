include <thing_libutils/attach.scad>
include <thing_libutils/shapes.scad>
include <config.scad>

mount_rod_clamp_conn_rod = [[0,0,0],[1,0,0]];

module mount_rod_clamp_half(rod_d=10, screw_dist=undef, width=4, thick=undef, base_thick=undef, thread=ThreadM4, orient=[0,0,1])
{
    thick_=thick==undef?rod_d:thick;
    outer_d= rod_d+thick_*2;
    thread_dia=lookup(ThreadSize, thread);
    screw_dist_=screw_dist==undef?outer_d+thread_dia+thick_:screw_dist;
    base_thick_=base_thick==undef?thick_*1.5:base_thick;

    orient(orient)
    difference()
    {
        clamp_tolerance = 0.5*mm;
        union()
        {
            // cylinder around rod
            cylindera(d=outer_d, h=width, orient=[0,0,1], align=[0,0,0]);

            // base
            cubea([base_thick_, screw_dist_+thread_dia*2.5, width], align=[1,0,0]);
        }

        // cut bottom of cylinder
        cubea([outer_d/2+.1, screw_dist_+thread_dia*2.5+.1, width+1], align=[-1,0,0], extrasize=[clamp_tolerance,0,0], extrasize_align=[1,0,0]);

        // cut clamp screw holes
        for(i=[-1,1])
        translate([0, i*screw_dist_/2, 0])
        {
            cylindera(d=thread_dia, h=base_thick_*3, orient=[1,0,0]);
        }

        // cut zrod
        cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=[0,0,1]);
    }
}

module mount_rod_clamp_full(rod_d=10, screw_dist=undef, width=4, thick=undef, base_thick=undef, thread=ThreadM4, orient=[0,0,1])
{
    thick_=thick==undef?rod_d:thick;
    outer_d= rod_d+thick_*2;
    thread_dia=lookup(ThreadSize, thread);
    screw_dist_=screw_dist==undef?outer_d+thread_dia*2+thick_:screw_dist;
    base_thick_=base_thick==undef?thick_*1.5:base_thick;

    orient(orient)
    difference()
    {
        clamp_tolerance = 0.5*mm;
        base_cut = -rod_d/2 + clamp_tolerance;
        union()
        {
            // cylinder around rod
            cylindera(d=outer_d, h=width, orient=[0,0,1], align=[0,0,0]);

            // base
            translate([base_cut,0,0])
            cubea([base_thick_, screw_dist_+thread_dia*2.5, width], align=[1,0,0]);
        }

        // cut bottom of cylinder
        translate([base_cut,0,0])
            cubea([outer_d/2+.1, outer_d+.1, width+1], align=[-1,0,0]);

        // cut clamp screw holes
        for(i=[-1,1])
        translate([0, i*screw_dist_/2, 0])
        {
            cylindera(d=thread_dia, h=base_thick_*3, orient=[1,0,0]);
        }

        // cut zrod
        cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=[0,0,1]);
    }
}

/*translate([20,0,0])*/
/*mount_rod_clamp_half(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5);*/
/*mount_rod_clamp_full(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5);*/


