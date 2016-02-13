use <thing_libutils/bearing.scad>
include <thing_libutils/attach.scad>
include <config.scad>

yaxis_carriage_bearing_mount_bottom_thick = 3;
yaxis_carriage_bearing_mount_conn_bottom = [[0,0,0], [0,0,1]];
yaxis_carriage_bearing_mount_conn_bearing = [[0,0,yaxis_carriage_bearing_mount_bottom_thick+yaxis_bearing[1]/2], [0,0,1]];

module yaxis_carriage_bearing_mount(show_bearing=false, show_zips=false)
{
    // x distance of holes
    screw_dx=28;
    // y distance of holes
    screw_dy=21;

    carriage_plate_thread=ThreadM4;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2;
    depth = max(yaxis_bearing[1], screw_dx+carriage_plate_thread_d*2);
    /*height = yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick;*/
    height = 5+yaxis_carriage_bearing_mount_bottom_thick;

    difference()
    {
        union()
        {
            rcubea ([width, depth, height], align=[0,0,1]);
        }

        translate ([+screw_dx/2, +screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([+screw_dx/2, -screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, +screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, -screw_dy/2, -1]) cylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);

        translate([0,0,yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick])
        bearing_mount_holes(yaxis_bearing, orient=[0,1,0], ziptie_dist=5, show_zips=show_zips);
    }

    %if(show_bearing)
    {
        translate([0,0,yaxis_bearing[1]/2+yaxis_carriage_bearing_mount_bottom_thick])
        bearing(yaxis_bearing, orient=[0,1,0]);
    }
}

/*c1=[[0,0,0],[0,0,1]];*/
/*attach(c1,yaxis_carriage_bearing_mount_conn_bottom)*/
/*{*/
    /*yaxis_carriage_bearing_mount();*/
    /*#connector(yaxis_carriage_bearing_mount_conn_bottom);*/
/*}*/
