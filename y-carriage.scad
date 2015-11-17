include <thing_libutils/attach.scad>
include <config.scad>

ycarriage_bearing_mount_bottom_thick = 3;
ycarriage_bearing_mount_conn_bottom = [[0,0,0], [0,0,1]];
ycarriage_bearing_mount_conn_bearing = [[0,0,ycarriage_bearing_mount_bottom_thick+yaxis_bearing[1]/2], [0,0,1]];

module ycarriage_bearing_mount(show_bearing=false, show_zips=false)
{
    // x distance of holes
    screw_dx=28;
    // y distance of holes
    screw_dy=21;

    carriage_plate_thread=ThreadM4;
    carriage_plate_thread_d=lookup(ThreadSize, carriage_plate_thread);

    width = screw_dx+carriage_plate_thread_d*2;
    depth = max(yaxis_bearing[1], screw_dx+carriage_plate_thread_d*2);
    /*height = yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick;*/
    height = 5+ycarriage_bearing_mount_bottom_thick;

    difference()
    {
        union()
        {
            cubea ([width, depth, height], align=[0,0,1]);
        }

        translate ([+screw_dx/2, +screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([+screw_dx/2, -screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, +screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);
        translate ([-screw_dx/2, -screw_dy/2, -1]) fncylindera(d=carriage_plate_thread_d, h=height+2, align=[0,0,1]);

        translate([0,0,yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick])
        bearing_mount_holes(yaxis_bearing, orient=[0,1,0], ziptie_dist=5, show_zips=show_zips);
    }

    %if(show_bearing)
    {
        translate([0,0,yaxis_bearing[1]/2+ycarriage_bearing_mount_bottom_thick])
        bearing(yaxis_bearing, orient=[0,1,0]);
    }
}

/*c1=[[0,0,0],[0,0,-1]];*/
/*attach(c1,ycarriage_bearing_mount_conn)*/
/*{*/
    /*ycarriage_bearing_mount();*/
    /*#connector(ycarriage_bearing_mount_conn);*/
/*}*/

