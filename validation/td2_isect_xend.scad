// x-end clearance probe: the v2 chassis vs its own x-end WITH vitamins
// (z linear bearing, z-nut, motor) in the shared local frame.
// mode=0: intersection (must be EMPTY). mode=1: x-end + vitamins only.
// mode=2: both bodies, for viewing. mode=3: whatever of the x-end (with
// vitamins) lies below its bottom face near the plate -- the bbox tells
// what protrudes. mode=4: echo the numbers.
include <../config.scad>
include <../x-carriage.h>
use <../x-end.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

mode = 0;

// NOTE: xaxis_end() draws its vitamins with the % background modifier,
// which CGAL ignores -- so the "vit" part is called explicitly here to
// make the bearing, nut, rods and motor solid for the probe.
module xend_full()
{
    $show_vit = true;
    xaxis_end(with_motor=true, beltpath_index=0, show_motor=true,
              show_nut=true, show_bearings=true, show_rods=true);
    xaxis_end(part="vit", with_motor=true, beltpath_index=0,
              show_motor=true, show_nut=true, show_bearings=true,
              show_rods=true);
}
module chassis() { $show_vit = false; tooldock2_chassis(); }

if(mode==0)
intersection() { xend_full(); chassis(); }
else if(mode==1) xend_full();
else if(mode==2) { xend_full(); color([0.85,0.65,0.35]) chassis(); }
else if(mode==3)
intersection()
{
    xend_full();
    translate([-30, -60, -xaxis_end_wz/2 - 12]) cube([60, 80, 11.99]);
}
else if(mode==4)
echo(wz=xaxis_end_wz, xzd=xaxis_zaxis_distance_y,
     plate_z=[tooldock_plate_z0, tooldock_plate_z1],
     plate_x=[tooldock_plate_x0, tooldock_plate_x1],
     plate_y=[tooldock_plate_y0, tooldock_plate_y1]);
