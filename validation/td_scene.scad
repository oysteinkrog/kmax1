// left x-end + parked toolhead + v2 dock, in the gantry frame (Z at min)
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../thing_libutils/attach.scad>
use <../thing_libutils/transforms.scad>
use <../x-end.scad>
use <../x-carriage.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

parkpos = -(main_width/2 - extrusion_size - x_carriage_w/2 + 20);

tx(parkpos)
attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],N])
{
    $show_vit=true;

    x_carriage_withmounts(side=0, with_sensormount=true);
    x_carriage_extruder(side=0);
}

translate([-(main_width/2), 0, 0])
translate([0, xaxis_zaxis_distance_y, 0])
translate([-zmotor_mount_rod_offset_x, 0, 0])
{
    xaxis_end(with_motor=true, beltpath_index=0, show_motor=true,
              show_nut=true);

    $show_vit = true;
    tool_dock2(beltpath_index=0);
}
