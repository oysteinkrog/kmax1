include <config.scad>
include <thing_libutils/screws.scad>
include <thing_libutils/materials.scad>

module gantry_lower_connector()
{
    thick = gantry_connector_thickness;
    width = extrusion_size+thick;
    depth = extrusion_size*2;
    height = main_lower_dist_z+extrusion_size;
    translate([thick,0,0])
    difference()
    {
        material(Mat_Plastic)
        union()
        {
            // top/bottom
            for(z=[-1,1])
            translate([0,0,z*height/2])
            rcubea([width,extrusion_size*2,thick], align=[-1,0,z], extra_size=[0,thick,0], extra_align=[0,-1,0]);

            // side
            rcubea([thick,depth,height+thick], align=[-1,0,0], extra_size=[0,thick,0], extra_align=[0,-1,0]);

            // front
            translate([0,-depth/2,0])
            rcubea([width,thick,height+thick], align=[-1,-1,0]);

        }

        // side nuts
        for(z=[-1,1])
        translate([0,extrusion_size/2,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_nut, head="button", h=thick+.1, with_nut=false, orient=[-1,0,0], align=[-1,0,0]);

        // side end nuts
        for(z=[-1,1])
        translate([0,-extrusion_size/2,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_end_nut, head="button", h=thick+.1, with_nut=false, orient=[-1,0,0], align=[-1,0,0]);

        // front nuts
        for(z=[-1,1])
        translate([-width/2-thick/2,-extrusion_size-thick,z*main_lower_dist_z/2])
        screw_cut(nut=extrusion_nut, head="button", h=thick+.1, with_nut=false, orient=Y, align=Y);
    }
}

module part_gantry_lower_connector()
{
    /*rotate([0,90,0])*/
    rotate([90,0,0])
    gantry_lower_connector();
}

/*gantry_lower_connector();*/
