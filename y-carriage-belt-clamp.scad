include <y-carriage-belt-clamp.h>

module yaxis_belt_holder()
{
    difference()
    {
        union()
        {
            // base (screws etc)
            rcubea([yaxis_belt_mount_width_base,yaxis_belt_mount_depth_base,yaxis_belt_mount_base_thick], align=Z);

            // for belt attachment
            rcubea([yaxis_belt_mount_width_belt,yaxis_belt_mount_depth,yaxis_belt_mount_height], align=[0,0,-1]);
        }

        // for belt attachment
        rcubea([yaxis_belt_mount_width_base*2,yaxis_belt_mount_belt_gap,yaxis_belt_mount_height+1], align=[0,0,-1]);

        for(y=[-1,1])
        translate([0,y*yaxis_belt_mounthole_dist/2,-1])
        cylindera(d=yaxis_belt_mounthole_thread_dia,yaxis_belt_mount_base_thick*2, align=Z, orient=Z);
    }
}

module part_y_carriage_belt_holder()
{
    conn = [N,Z];
    attach(conn, yaxis_belt_mount_conn)
    {
        yaxis_belt_holder();
    }
}
