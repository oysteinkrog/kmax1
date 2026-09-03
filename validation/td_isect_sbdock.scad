// parked SB toolhead (imports are solid) vs x-end + dock. Zero-volume
// residue tolerated; any voluminous cluster is a real collision.
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../thing_libutils/attach.scad>
use <../thing_libutils/transforms.scad>
use <../x-end.scad>
use <../x-carriage.scad>
use <../tool-dock.scad>
include <../tool-dock.h>

intersection()
{
    union()
    {
        $show_vit=false;
        tx(-(main_width/2 - extrusion_size - x_carriage_w/2 + 20))  // axis_range_x[0]
        attach(xaxis_carriage_conn, [[0,-xaxis_zaxis_distance_y,0],N])
        {
            x_carriage_withmounts(side=0, with_sensormount=true);
            x_carriage_extruder(side=0);
        }
    }
    union()
    {
        $show_vit=false;
        translate([-(main_width/2), 0, 0])
        translate([0, xaxis_zaxis_distance_y, 0])
        translate([-zmotor_mount_rod_offset_x, 0, 0])
        {
            xaxis_end(with_motor=true, beltpath_index=0, show_motor=false,
                      show_nut=false);
            tool_dock(beltpath_index=0);
        }
    }
}
