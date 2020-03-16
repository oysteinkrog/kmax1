use <rod-clamps.scad>
include <rod-clamps.h>

include <config.scad>

module part_z_rod_clamp()
{
    mount_rod_clamp_half(rod_d=yaxis_rod_d, thick=4, width=extrusion_size, thread=extrusion_mount_thread, align=Z+X, orient=-Z);
}
