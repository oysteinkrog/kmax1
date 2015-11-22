include <thing_libutils/attach.scad>
include <config.scad>

yaxis_belt_mount_base_thick = 6;

yaxis_belt_mounthole_dist = 41;
yaxis_belt_mounthole_thread = ThreadM3;
yaxis_belt_mounthole_thread_dia = lookup(ThreadSize, yaxis_belt_mounthole_thread);

yaxis_belt_mount_width_belt = yaxis_pulley_d/2;
yaxis_belt_mount_width_base = yaxis_belt_mounthole_thread_dia*3;
yaxis_belt_mount_height = 15;
yaxis_belt_mount_depth = 33;
yaxis_belt_mount_depth_base = yaxis_belt_mounthole_dist+yaxis_belt_mounthole_thread_dia*3;

yaxis_belt_mount_belt_gap = 5*mm;

yaxis_belt_mount_conn=[[0,0,yaxis_belt_mount_base_thick],[0,0,1]];

module yaxis_belt_holder()
{
    difference()
    {
        union()
        {
            // base (screws etc)
            cubea([yaxis_belt_mount_width_base,yaxis_belt_mount_depth_base,yaxis_belt_mount_base_thick], align=[0,0,1]);

            // for belt attachment
            cubea([yaxis_belt_mount_width_belt,yaxis_belt_mount_depth,yaxis_belt_mount_height], align=[0,0,-1]);
        }

        // for belt attachment
        cubea([yaxis_belt_mount_width_base*2,yaxis_belt_mount_belt_gap,yaxis_belt_mount_height+1], align=[0,0,-1]);

        for(y=[-1,1])
        translate([0,y*yaxis_belt_mounthole_dist/2,-1])
        fncylindera(d=yaxis_belt_mounthole_thread_dia,yaxis_belt_mount_base_thick*2, align=[0,0,1], orient=[0,0,1]);
    }
}

/*conn = [[0,0,0],[0,0,1]];*/
/*attach(conn, yaxis_belt_mount_conn)*/
/*{*/
    /*#connector(yaxis_belt_mount_conn);*/
    /*yaxis_belt_holder();*/
/*}*/
