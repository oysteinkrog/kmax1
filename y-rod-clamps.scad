use <rod-clamps.scad>
include <rod-clamps.h>

include <config.scad>

module part_y_rod_clamp()
{
    mount_rod_clamp_full(rod_d=zaxis_rod_d, thick=4, width=extrusion_size, thread=extrusion_mount_thread, align=Z+X, orient=-Z);
}
