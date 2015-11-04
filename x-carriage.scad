use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/triangles.scad>
use <thing_libutils/linear-extrusion.scad>;
use <bearings.scad>

include <config.scad>


xaxis_carriage_bearing_distance = 6;
xaxis_carriage_padding = 3;
xaxis_carriage_mount_distance = 30;
xaxis_carriage_mount_offset_z = 15;
xaxis_carriage_teeth_height=xaxis_belt_width*1.5;
xaxis_carriage_conn = [[0, -xaxis_bearing[1]/2 - xaxis_carriage_bearing_offset_z, 0],[0,1,0]];

module horizontal_bearing_holes(bearing_type)
{
    translate([0,0,bearing_type[1]/2 + xaxis_carriage_bearing_offset_z])
    {
        // Main bearing cut
        difference()
        {
            fncylindera(h=bearing_type[2], d=bearing_type[1], orient=[1,0,0]);
        }

        difference()
        {
            union()
            {
                for(i=[-1,1])
                    translate(v=[i*bearing_type[3]/2,0,0])
                        fncylindera(h=ziptie_width, d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness, orient=[1,0,0]);
            }
            fncylindera(h=bearing_type[2], d=bearing_type[1]+ziptie_bearing_distance, orient=[1,0,0]);
        }

        // for linear rod
        fncylindera(d=xaxis_rod_d*1.5, h=100, orient=[1,0,0]);
    }
}


module x_carriage_base()
{
    bottom_width = xaxis_bearing[2] + 2*xaxis_carriage_padding;
    top_width = xaxis_bearing[2]*2 + xaxis_carriage_bearing_distance + 2*xaxis_carriage_padding;
    thickness = xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z;

    hull()
    {
        // top bearings
        translate([0,xaxis_rod_distance/2,0])
            cubea(size = [top_width, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2, thickness], align=[0,0,1]);

        cubea([top_width,xaxis_rod_distance/2,xaxis_carriage_bearing_offset_z], align=[0,0,1]);

        translate([0,0,xaxis_carriage_beltpath_offset])
            cubea([top_width,xaxis_rod_distance/2,xaxis_carriage_teeth_height], align=[0,0,0]);

        // bottom bearing
        translate([0,-xaxis_rod_distance/2,0]) 
            cubea(size = [bottom_width, xaxis_bearing[1]+xaxis_carriage_padding+ziptie_bearing_distance*2, thickness], align=[0,0,1]);

    }
}

module x_carriage_beltcut()
{
    translate([0,0,xaxis_carriage_beltpath_offset+.1])
    {
        // Cut in the middle for belt
        cubea([4.5,13,xaxis_carriage_teeth_height], align=[0,0,0]);

        // Cut clearing space for the belt
        translate([0,-xaxis_pulley_d/2,0]) cubea([500,10,xaxis_carriage_teeth_height], align=[0,0,0]);

        //xaxis pulleys
        /*translate([0,0,xaxis_carriage_beltpath_offset])*/
        for(i=[-1,1])
        translate([i*50,0,0])
            %fncylindera(d=xaxis_pulley_d, h=xaxis_belt_width*1.2, orient=[0,0,1], align=[0,0,0]);

        translate([0,xaxis_pulley_d/2,0])
        {
            // Belt slit
            cubea([500,1,xaxis_carriage_teeth_height], align=[0,1,0]);

            // Teeth cuts
            teeth = 50;
            teeth_height = 3;
            translate([-belt_tooth_distance/2*teeth-.5,0,0])
            for(i=[0:teeth])
            {
                translate([i*belt_tooth_distance,0,0])
                cubea([belt_tooth_distance*belt_tooth_ratio,teeth_height,xaxis_carriage_teeth_height], align=[0,-1,0]);
            }
        }
    }
}


module x_carriage_holes(bearing_type){

    for ( i = [-1,1] )
        translate([i*(bearing_type[2]/2+xaxis_bearing_distance/2),0,0])
            translate([0,xaxis_rod_distance/2,0]) 
            horizontal_bearing_holes(xaxis_bearing);


    translate([0,-xaxis_rod_distance/2,0]) 
        horizontal_bearing_holes(xaxis_bearing);

    // Extruder mounting holes
    translate([0,xaxis_carriage_mount_offset_z,0])
        for ( i = [-1,1] )
        {
            translate([i*xaxis_carriage_mount_distance/2,0,0])
            {
                fncylindera(r=1.7, h=100);
                /*fncylindera(r=3.3, h=20, fn=6, align=[0,0,1]);*/
            }
        }
}

// Final part
module x_carriage(show_bearings=true)
{
    difference()
    {
        x_carriage_base();
        x_carriage_beltcut();
        x_carriage_holes(xaxis_bearing);
    }

    %if(show_bearings)
    {
        for(j=[-1,1])
        translate([0,0,xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z])
        translate([j*(xaxis_bearing_distance+xaxis_bearing[2])/2,0,0])
        translate([0, xaxis_rod_distance/2, 0])
                bearing(xaxis_bearing, orient=[1,0,0]);

        translate([0,0,xaxis_bearing[1]/2 + xaxis_carriage_bearing_offset_z])
        translate([0, -xaxis_rod_distance/2, 0])
            bearing(xaxis_bearing, orient=[1,0,0]);
    }
}

x_carriage();
