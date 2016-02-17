include <config.scad>
include <thing_libutils/metric-screw.scad>

module gantry_lower_connector()
{
    thick = gantry_connector_thickness;
    width = extrusion_size+thick;
    depth = extrusion_size*2;
    height = main_lower_dist_z+extrusion_size;
    translate([thick,0,0])
    difference()
    {
        union()
        {
            // top/bottom
            for(z=[-1,1])
            translate([0,0,z*height/2])
            rcubea([width,extrusion_size*2,thick], align=[-1,0,z], extrasize=[0,thick,0], extrasize_align=[0,-1,0]);

            // side
            rcubea([thick,depth,height+thick], align=[-1,0,0], extrasize=[0,thick,0], extrasize_align=[0,-1,0]);

            // front
            translate([0,-depth/2,0])
            rcubea([width,thick,height+thick], align=[-1,-1,0]);

        }

        // side nuts
        for(z=[-1,1])
        translate([0,extrusion_size/2,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_nut, h=thick+.1, with_nut=false, orient=[-1,0,0], align=[-1,0,0]);

        // side end nuts
        for(z=[-1,1])
        translate([0,-extrusion_size/2,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_end_nut, h=thick+.1, with_nut=false, orient=[-1,0,0], align=[-1,0,0]);

        // front nuts
        for(z=[-1,1])
        translate([-width/2-thick,-extrusion_size-thick,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_nut, h=thick+.1, with_nut=false, orient=[0,1,0], align=[0,1,0]);
    }
}

/*gantry_lower_connector();*/
