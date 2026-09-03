// v2 chassis printability: the part in its print orientation --
// STANDING on the rear (+y) edge, which part_tooldock2_chassis_left()
// exports (x'=x, y'=z, z'=plate_y1-y). All rear faces are coplanar at
// tooldock2_rear_y1, so the former support field (wing deck underside,
// neck sweep, backer ceiling) is now vertical wall and the droop load
// path prints in-plane. Nothing on the part needs support.
//
// Measured on the export (overhang_stl.py, 45-degree rule): the only
// real internal bridge is the leadscrew slot's flat ceiling (~20x10,
// open at the mouth; sag lands in 5mm of diametral clearance). The
// shell cavity has NO exposed ceiling: the z-nut collar island covers
// its whole front band and carries a designed-in 45-degree teardrop
// foot. Remaining down-faces are the magnet-pocket arcs (standard
// horizontal holes) and the sub-1.5mm curl where the rzb edge rolls
// meet the bed -- both self-managing.
//
// Zones (toggles below):
//  BLUE  slot ceiling bridge, no support, hidden inside the plate
//  GREEN self-managing: z-nut screw bores + head pockets and the
//        retention magnet pockets print as horizontal holes; the
//        dovetail grooves are horizontal channels whose upper flanks
//        overhang at exactly 45; the collar teardrop region too
//
// Slicer: NO supports; brim advised -- 81 tall on ~11 cm2 of
// rear-edge contact.
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

show_part    = true;
show_bed     = true;
show_bridges = true;   // BLUE + GREEN
show_labels  = true;

$show_vit = true;

// map a design-space box into the print frame of the standing export
module pbox(a, b)
{
    translate([a[0], a[2], tooldock_plate_y1 - b[1]])
    cube([b[0]-a[0], b[2]-a[2], b[1]-a[1]]);
}

if(show_part)
    part_tooldock2_chassis_left();

if(show_bed)
    color([0.4, 0.42, 0.45])
    translate([0, -119, -1.2])
    cube([84, 80, 1.2]);

if(show_bridges)
{
    // BLUE: the slot's +y tangent wall = the tunnel's flat ceiling
    color([0.15, 0.3, 0.9], 0.35)
    pbox([tooldock_plate_x0 - 2,
          -xaxis_zaxis_distance_y + tooldock_slot_screw_w/2 - 2,
          tooldock_plate_z0 - 1.5],
         [tooldock_znut_screw_x,
          -xaxis_zaxis_distance_y + tooldock_slot_screw_w/2,
          tooldock_plate_z1 + 0.2]);

    // GREEN: horizontal bores/pockets, dovetail channels, teardrop
    color([0.1, 0.7, 0.25], 0.35)
    {
        for(sy=tooldock_znut_screw_y)
        pbox([tooldock_znut_screw_x - 4, sy - 4,
              tooldock_plate_z0 - 0.5],
             [tooldock_znut_screw_x + 4, sy + 4,
              tooldock_plate_z1 + 0.5]);

        for(my=tooldock_mag_y)
        pbox([tooldock_backer_x1 - 3.6, my - 3.6,
              tooldock_mag_z - 3.6],
             [tooldock_backer_x1 + 0.3, my + 3.6,
              tooldock_mag_z + 3.6]);

        for(cy=tooldock2_dt_cy)
        pbox([tooldock_backer_x1 - tooldock2_dt_depth - 0.3,
              cy - tooldock2_dt_w/2 - tooldock2_dt_under - 0.3,
              tooldock2_dt_z0 - 0.3],
             [tooldock_backer_x1 + 0.3,
              cy + tooldock2_dt_w/2 + tooldock2_dt_under + 0.3,
              tooldock_rim_z + 0.3]);

        pbox([tooldock_znut_screw_x - 13.4,
              -xaxis_zaxis_distance_y + 13.4,
              tooldock_plate_z0 - 1],
             [tooldock_znut_screw_x + 13.4,
              -xaxis_zaxis_distance_y + 26.9,
              tooldock_plate_z1 - tooldock2_cskin + 0.5]);
    }
}

if(show_labels)
    color([0.15, 0.15, 0.15])
    {
        translate([2, -99, 0]) linear_extrude(0.8)
        text("STANDING PRINT: no supports", size=3.4);
        translate([2, -104, 0]) linear_extrude(0.8)
        text("BLUE: slot ceiling bridge (hidden)", size=3.4);
        translate([2, -109, 0]) linear_extrude(0.8)
        text("GREEN: horiz holes + dovetail channels", size=3.4);
        translate([2, -114, 0]) linear_extrude(0.8)
        text("brim: 81 tall, ~11cm2 contact", size=3.4);
    }
