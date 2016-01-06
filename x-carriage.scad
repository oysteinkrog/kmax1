use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;
use <bearings.scad>

include <config.scad>


xaxis_carriage_bearing_distance = 8;
xaxis_carriage_padding = 2;
xaxis_carriage_mount_distance = 23;
xaxis_carriage_mount_offset_z = 0;
xaxis_carriage_teeth_height=xaxis_belt_width*1.5;
xaxis_carriage_mount_screws = ThreadM4;

xaxis_carriage_conn = [[0, -xaxis_bearing[1]/2 - xaxis_carriage_bearing_offset_z,0], [0,0,0]];

module x_carriage_base()
{
    bottom_width = xaxis_bearing[2] + 2*xaxis_carriage_padding;
    top_width = xaxis_bearing[2]*2 + xaxis_carriage_bearing_distance + 2*xaxis_carriage_padding;
    thickness = xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z;

    difference()
    {
        union()
        {
            hull()
            {
                // top bearings
                translate([0,0,xaxis_rod_distance/2])
                    cubea([top_width, thickness, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

                /*#cubea([top_width,xaxis_carriage_bearing_offset_z,xaxis_rod_distance/2], align=[0,1,0]);*/

                // bottom bearing
                translate([0,0,-xaxis_rod_distance/2])
                    cubea([bottom_width, thickness, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2], align=[0,1,0]);

            }

            translate([0,xaxis_carriage_beltpath_offset,0])
            {
                difference()
                {
                    translate([0,0,xaxis_pulley_inner_d/2])
                        cubea([50, xaxis_carriage_teeth_height, 10], align=[0,0,-1]);
                }
            }
        }

        translate([0,xaxis_carriage_beltpath_offset+.1,0])
        {
            // Cut clearing space for the belt
            translate([0,0,-xaxis_pulley_inner_d/2])
                cubea([500,xaxis_carriage_teeth_height,5], align=[0,0,0], extrasize=[0,0,4], extrasize_align=[0,0,1]);

            belt_thickness=1.5;
            for(i=[-1,1])
                translate([i*30,0,0])
                    cubea([15,xaxis_carriage_teeth_height,15-belt_thickness], align=[0,0,0]);

            // Cut in the middle for belt
            cubea([7,xaxis_carriage_teeth_height+.1,15], align=[0,0,0]);

            translate([0,0,xaxis_pulley_inner_d/2])
            {
                // Belt slit
                cubea([500,xaxis_carriage_teeth_height,belt_thickness], align=[0,0,0]);

                // Teeth cuts
                teeth = 50;
                teeth_height = 2;
                translate([-belt_tooth_distance/2*teeth-.5,0,0])
                for(i=[0:teeth])
                {
                    translate([i*belt_tooth_distance,0,0])
                        cubea([belt_tooth_distance*belt_tooth_ratio,xaxis_carriage_teeth_height,teeth_height], align=[0,0,-1]);
                }
            }

            for(i=[-1,1])
            translate([i*50,0,0])
            %fncylindera(d=xaxis_pulley_inner_d, h=xaxis_belt_width*1.2, orient=[0,1,0], align=[0,0,0]);
        }


    }
}

module x_carriage_holes()
{
    for(i=[-1,1])
    translate([i*(xaxis_bearing[2]/2+xaxis_carriage_bearing_distance/2),0,0])
    translate([0, xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_z, xaxis_rod_distance/2])
    bearing_mount_holes(xaxis_bearing, orient=[1,0,0]);

    translate([0, xaxis_bearing[1]/2+xaxis_carriage_bearing_offset_z, -xaxis_rod_distance/2])
    bearing_mount_holes(xaxis_bearing, orient=[1,0,0]);

    // Extruder mounting holes
    translate([0,0,xaxis_carriage_mount_offset_z])
    for(j=[-1,1])
    for(i=[-1,1])
    {
        translate([i*xaxis_carriage_mount_distance/2,0,j*xaxis_carriage_mount_distance/2])
        {
            screw_dia = lookup(ThreadSize, xaxis_carriage_mount_screws);
            fncylindera(d=screw_dia, h=100, orient=[0,1,0]);
        }
    }
}

// Final part
module x_carriage(show_bearings=true)
{
    difference()
    {
        x_carriage_base();
        x_carriage_holes();
    }

    %if(show_bearings)
    {
        for(j=[-1,1])
        translate([0,xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z,0])
        translate([j*(xaxis_carriage_bearing_distance+xaxis_bearing[2])/2,0,0])
        translate([0, 0, xaxis_rod_distance/2])
                bearing(xaxis_bearing, orient=[1,0,0]);

        translate([0,xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z,0])
        translate([0, 0, -xaxis_rod_distance/2])
            bearing(xaxis_bearing, orient=[1,0,0]);
    }
}

/*x_carriage();*/
