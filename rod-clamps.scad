include <thing_libutils/system.scad>
include <thing_libutils/attach.scad>
include <thing_libutils/shapes.scad>
include <thing_libutils/screws.scad>
include <config.scad>

mount_rod_clamp_conn_rod = [N,XAXIS];

module mount_rod_clamp_half(part, rod_d=10, screw_dist=undef, width=4, thick=undef, base_thick=undef, thread=ThreadM4, align, orient, align_obj = "rod")
{
    thick_=thick==undef?rod_d:thick;
    outer_d= rod_d+thick_*2;
    thread_dia=lookup(ThreadSize, thread);
    screw_dist_=screw_dist==undef?outer_d+thread_dia+thick_:screw_dist;
    base_thick_=base_thick==undef?thick_*1.2:base_thick;
    clamp_tolerance = 0.5*mm;

    pos_offset = align_obj == "mount" ? N : N;

    if(part==undef)
    {
        difference()
        {
            mount_rod_clamp_half(part="pos", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
            mount_rod_clamp_half(part="neg", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
        }
        if($show_vit)
        {
            %mount_rod_clamp_half(part="vit", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
        }
    }
    else if(part=="pos")
    {
        s=[outer_d, base_thick_, width];
        size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        {
            /*hull()*/
            {
                // cylinder around rod
                rcylindera(d=outer_d, h=width, orient=Z, align=N);

                // base
                rcubea([base_thick_, screw_dist_+thread_dia*2.5, width], align=X);
            }
        }
    }
    else if(part=="neg")
    {
        s=[outer_d, base_thick_, width];
        size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        {
            // cut bottom of cylinder
            cubea([outer_d/2+.1, screw_dist_+thread_dia*2.5+.1, width+1], align=[-1,0,0]);

            // cut clamp screw holes
            for(i=[-1,1])
            translate([0, i*screw_dist_/2, 0])
            {
                screw_cut(thread=thread, orient=-X);
            }

            // cut rod
            translate(-clamp_tolerance*X)
            cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=Z);
        }
    }
    else if(part=="vit")
    {
        s=[outer_d, base_thick_, width];
        size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        {
            translate(-clamp_tolerance*X)
            cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=Z);
        }
    }
}

module mount_rod_clamp_full(part, rod_d=10, screw_dist=undef, width=4, thick=undef, base_thick=undef, thread=ThreadM4, align, orient, align_obj = "rod")
{
    thick_=thick==undef?rod_d:thick;
    outer_d= rod_d+thick_*2;
    thread_dia=lookup(ThreadSize, thread);
    screw_dist_=screw_dist==undef?outer_d+thread_dia*2+thick_:screw_dist;
    base_thick_=base_thick==undef?thick_*1.2:base_thick;
    clamp_tolerance = 0.5*mm;

    pos_offset = align_obj == "mount" ? N : [-rod_d/2,0,0];

    s=[base_thick_, screw_dist_+thread_dia*2.5, width];
    if(part==undef)
    {
        difference()
        {
            mount_rod_clamp_full(part="pos", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
            mount_rod_clamp_full(part="neg", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
        }
        if($show_vit)
        {
            %mount_rod_clamp_full(part="vit", rod_d=rod_d, screw_dist=screw_dist, width=width, thick=thick, base_thick=base_thick, thread=thread, align=align, orient=orient, align_obj=align_obj);
        }
    }
    else if(part=="pos")
    {
        size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        {
            /*hull()*/
            {
                // cylinder around rod
                translate([rod_d/2,0,0])
                rcylindera(d=outer_d, h=width, orient=Z, align=N);

                // base
                /*translate([-rod_d/2,0,0])*/
                rcubea([base_thick_, screw_dist_+thread_dia*2.5, width], align=X);
            }
        }
    }
    else if(part=="neg")
    {
        size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        {
            // cut bottom of cylinder
            /*translate(-rod_d/2*X)*/
            cubea([outer_d/2, screw_dist_+thread_dia*2.5+.1, width+1], align=[-1,0,0]);

            // cut clamp screw holes
            for(i=[-1,1])
            translate([0, i*screw_dist_/2, 0])
            {
                screw_cut(thread=thread, orient=-X);
            }

            // cut rod
            translate([rod_d/2,0,0])
            translate(-clamp_tolerance*X)
            hull()
            {
                stack(axis=-X, dist=100)
                {
                    cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=Z);
                    cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=Z);
                }
            }
        }
    }
    else if(part=="vit")
    {
        %size_align(size=s, align=align, orient=orient, orient_ref=Z)
        translate(pos_offset)
        translate([rod_d/2,0,0])
        translate(-clamp_tolerance*X)
        cylindera(d=rod_d*rod_fit_tolerance, h=width*2, orient=Z);
    }
}

if(false)
{
    /*$show_vit=false;*/
    /*$preview_mode=false;*/
    stack(axis=Z, dist=50)
    {
        mount_rod_clamp_half(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5, align_obj="mount");
        mount_rod_clamp_full(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5, align_obj="mount");

        mount_rod_clamp_half(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5, align_obj="rod");
        mount_rod_clamp_full(rod_d=yaxis_rod_d,  width=extrusion_size, thick=4, thread=ThreadM5, align_obj="rod");
    }
}


