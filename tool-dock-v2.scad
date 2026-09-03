include <tool-dock-v2.h>
include <thing_libutils/system.scad>
include <thing_libutils/materials.scad>

use <thing_libutils/shapes.scad>
use <thing_libutils/transforms.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/misc.scad>

// v1 helpers and the frozen bucket geometry (shell, cavity style,
// dovetail profile) are reused from tool-dock.scad; nothing there is
// modified. See tool-dock-v2.h for what v2 changes and why.
use <tool-dock.scad>

// -- 3D rounding helpers -------------------------------------------------
// tooldock_rbox rounds in plan only; these roll the horizontal rims
// too. Faces that mate, weld, print on the bed, or belong to the
// frozen v1 envelope keep their flat variant (rz/rzb = 0).

// vertical corner post: radius r spanning z0..z1, top/bottom rim
// rolled over by rz/rzb -- a true roundover (rotate_extrude of a
// rounded 2D profile), not a chamfer
module tooldock2_post(r, z0, z1, rz=0, rzb=0)
{
    h = z1 - z0;
    // rz <= r/2: the roundover circle must not cross the rotation
    // axis (rotate_extrude rejects it, silently dropping the post)
    assert(h >= 2*rz && h >= 2*rzb && rz <= r/2 && rzb <= r/2);
    translate([0, 0, z0])
    rotate_extrude(convexity=4)
    hull()
    {
        square([e, h]);
        if(rz > 0)  translate([r - rz, h - rz]) circle(r=rz);
        else        translate([0, h - e]) square([r, e]);
        if(rzb > 0) translate([r - rzb, rzb]) circle(r=rzb);
        else        square([r, e]);
    }
}

// tooldock_rbox with rolled top/bottom rims
module tooldock2_rbox3(from, to, r, rz=0, rzb=0)
{
    assert(2*r <= to[0] - from[0] + 0.001
        && 2*r <= to[1] - from[1] + 0.001);
    hull()
    for(x=[from[0] + r, to[0] - r], y=[from[1] + r, to[1] - r])
    translate([x, y, 0])
    tooldock2_post(r=r, z0=from[2], z1=to[2], rz=rz, rzb=rzb);
}

// the neck's shoulder bar (see the .h)
module tooldock2_neck_shoulder()
{
    hull()
    for(x=[tooldock2_riser_x0 + tooldock2_shoulder_r,
           tooldock_plate_x1 - tooldock2_shoulder_r],
        y=[tooldock_keepout_y1 + tooldock2_shoulder_r,
           tooldock_plate_y1 - tooldock2_shoulder_r])
    translate([x, y, tooldock2_shoulder_z])
    sphere(r=tooldock2_shoulder_r);
}

// -- drop-in dovetail mount ----------------------------------------------
// Two vertical dovetails (see the .h mount section). Groove and rib are
// z-extrusions of ONE plan-view profile -- the groove polygon -- so the
// mating geometry has a single source of truth; the rib is that polygon
// offset inward by the clearance.

// plan-view groove profile centred on y=0: mouth at the backer face,
// flanks widening inboard at dt_angle. The mouth side is carried
// `over` past the face along the same flank lines, so offsets of this
// polygon keep the flank geometry exact; `wide` opens the mouth in y
// (the funnel).
module tooldock2_dt_profile(over, wide=0)
{
    xf = tooldock_backer_x1;
    hw = tooldock2_dt_w/2 + wide;
    d = tooldock2_dt_depth;
    u = tooldock2_dt_under;
    t = tan(tooldock2_dt_angle);
    polygon([[xf + over, -(hw - over*t)], [xf - d, -hw - u],
             [xf - d, hw + u], [xf + over, hw - over*t]]);
}

// groove: floor at dt_z0, open through the backer top; the mouth
// funnels dt_flare per side in y over the top dt_flare_h (y only:
// x is guided by the wall on the backer face, and widening into the
// backer would thin its web)
module tooldock2_dt_groove(cy)
{
    z0 = tooldock2_dt_z0;
    zt = tooldock_rim_z;
    translate([0, cy, 0])
    {
        translate([0, 0, z0])
        linear_extrude(height=zt - z0 + 1)
        tooldock2_dt_profile(0.5);

        hull()
        {
            translate([0, 0, zt - tooldock2_dt_flare_h])
            linear_extrude(height=0.01)
            tooldock2_dt_profile(0.5);

            translate([0, 0, zt + 0.02])
            linear_extrude(height=0.01)
            tooldock2_dt_profile(0.5, tooldock2_dt_flare);
        }
    }
}

// rib on the wall's inboard face: the groove profile shrunk by the
// clearance, rooted 0.45 into the wall, bottom tapered 45 degrees
// over dt_nose (print-safe and the drop-in lead)
module tooldock2_dt_rib(cy)
{
    z0 = tooldock2_dt_z0;
    z1 = tooldock2_dt_z1;
    n = tooldock2_dt_nose;
    c = tooldock2_dt_clr;
    translate([0, cy, 0])
    {
        translate([0, 0, z0 + n])
        linear_extrude(height=z1 - z0 - n)
        offset(delta=-c)
        tooldock2_dt_profile(1.0);

        hull()
        {
            translate([0, 0, z0 + n])
            linear_extrude(height=0.01)
            offset(delta=-c)
            tooldock2_dt_profile(1.0);

            translate([0, 0, z0])
            linear_extrude(height=0.01)
            offset(delta=-c - n)
            tooldock2_dt_profile(1.0 + n);
        }
    }
}

// -- chassis -----------------------------------------------------------
// The clamp plate (shelled, solid z-nut collar) plus ONE pairwise
// hull chain running plate weld -> shoulder -> wing landing -> wing
// -> backer cove, so every transition is a swept blend rather than a
// stacked step. Every limit is a v1 envelope constant; see the .h.
module tooldock2_chassis(part)
{
    px0 = tooldock_plate_x0;
    px1 = tooldock_plate_x1;
    pz0 = tooldock_plate_z0;
    pz1 = tooldock_plate_z1;
    kx  = tooldock_keepout_x0;
    ky  = tooldock_keepout_y1;
    kz  = tooldock_keepout_z0;

    if(part==U)
    {
        difference()
        {
            tooldock2_chassis(part="pos");
            tooldock2_chassis(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock2_chassis(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    difference()
    {
        union()
        {
            // clamp plate as an L by construction: the back band runs
            // the full width, the front band stops at the keep-out
            // boundary; the missing corner is where the parked cowl
            // lives
            tooldock2_rbox3([px0, ky, pz0],
                            [px1, tooldock_plate_y1, pz1],
                            r=tooldock_plate_r, rzb=2);
            tooldock2_rbox3([px0, tooldock_plate_y0, pz0],
                            [kx, tooldock_plate_y1, pz1],
                            r=tooldock_plate_r, rzb=2);

            // cheek: full-height web on the inboard strip (see the
            // .h); welds past the plate's rim roll so the roll dies
            // into it instead of leaving a proud lip
            tooldock_rbox([tooldock2_riser_x0, tooldock_plate_y0,
                           tooldock2_wing_top],
                          [kx, tooldock_plate_y1, pz0 + 2.05],
                          r=1.5);

            // the chassis spine as one pairwise hull chain (each
            // station hulled to the next; stations shared between
            // consecutive pairs). Plate weld -> rounded shoulder ->
            // wing-plane landing -> wing upper band -> full wing ->
            // cove. See the .h for the neck stations' constraints.
            hull_pairwise()
            {
                // plate weld, reaching past the plate's rim roll
                tooldock_rbox([tooldock2_riser_x0, ky, pz0 + 0.05],
                              [px1, tooldock_plate_y1, pz0 + 2.05],
                              r=4);

                // rounded shoulder bar (see the .h)
                tooldock2_neck_shoulder();

                // wing-plane landing: TOP FLUSH with the wing top, so
                // the blend into the wing stays in plan and nothing
                // rises over the bucket rim outboard of x 54.19
                tooldock_rbox([tooldock2_riser_x0, tooldock_plate_y0,
                               tooldock2_wing_top - 0.5],
                              [px1, tooldock_plate_y1,
                               tooldock2_wing_top], r=4);

                // wing, upper band: the wing's plan at reduced depth,
                // floored 1.1 above the z-motor addon's base disc
                // (top -70.57), so the landing skirt sweeping onto it
                // cannot reach the disc
                hull()
                {
                    translate([tooldock2_wing_x0
                                   + tooldock2_wing_r_front,
                               tooldock_backer_y0
                                   + tooldock2_wing_r_front, 0])
                    tooldock2_post(r=tooldock2_wing_r_front,
                                   z0=-69.5, z1=tooldock2_wing_top,
                                   rz=2);
                    translate([tooldock2_wing_x0
                                   + tooldock2_wing_r_rear,
                               tooldock2_rear_y1
                                   - tooldock2_wing_r_rear, 0])
                    tooldock2_post(r=tooldock2_wing_r_rear,
                                   z0=-69.5, z1=tooldock2_wing_top,
                                   rz=2);
                    tooldock_box([tooldock2_wing_x0 + 20,
                                  tooldock_backer_y0, -69.5],
                                 [tooldock_backer_x0 + 0.1,
                                  tooldock2_rear_y1,
                                  tooldock2_wing_top]);
                }

                // wing, full depth: one flat plate spanning the full
                // backer length, top flush with the backer top (both
                // at the rim); rounded plan corners inboard, faces
                // flush with the backer envelope outboard
                hull()
                {
                    translate([tooldock2_wing_x0
                                   + tooldock2_wing_r_front,
                               tooldock_backer_y0
                                   + tooldock2_wing_r_front, 0])
                    tooldock2_post(r=tooldock2_wing_r_front,
                                   z0=tooldock2_wing_z0,
                                   z1=tooldock2_wing_top, rz=2, rzb=2);
                    translate([tooldock2_wing_x0
                                   + tooldock2_wing_r_rear,
                               tooldock2_rear_y1
                                   - tooldock2_wing_r_rear, 0])
                    tooldock2_post(r=tooldock2_wing_r_rear,
                                   z0=tooldock2_wing_z0,
                                   z1=tooldock2_wing_top, rz=2, rzb=2);
                    tooldock_box([tooldock2_wing_x0 + 20,
                                  tooldock_backer_y0,
                                  tooldock2_wing_z0],
                                 [tooldock_backer_x0 + 0.1,
                                  tooldock2_rear_y1,
                                  tooldock2_wing_top]);
                }

                // cove stations: the 45-degree gusset filleting the
                // wing into the backer -- past the motor plate
                // (x > 56.19), 18 above the rail-band floor, rounded
                // ends tapering into the backer faces
                tooldock_rbox([tooldock_backer_x0 - 6,
                               tooldock_backer_y0,
                               tooldock2_wing_z0 - 0.01],
                              [tooldock_backer_x0 + 0.1,
                               tooldock2_rear_y1,
                               tooldock2_wing_z0 + 0.5], r=2.5);
                tooldock_rbox([tooldock_backer_x0 - 0.5,
                               tooldock_backer_y0,
                               tooldock2_wing_z0 - 6],
                              [tooldock_backer_x0 + 0.1,
                               tooldock2_rear_y1,
                               tooldock2_wing_z0 + 0.5], r=0.25);
            }

            // backer -- FROZEN v1 envelope except the rear face,
            // pulled to the common stand plane (see tooldock2_rear_y1)
            tooldock_rbox([tooldock_backer_x0, tooldock_backer_y0,
                           tooldock_backer_z0],
                          [tooldock_backer_x1, tooldock2_rear_y1,
                           tooldock_rim_z], r=1);
        }

        // plate shell cells, open at the underside (= the print top),
        // MINUS the load-path islands that stay solid: the z-nut
        // collar (flange bearing ring + both screw bosses) and two
        // radial ribs. The back-band cell stops short of the riser so
        // the plate stays solid over the whole riser footprint (the
        // load path into the wing).
        difference()
        {
            union()
            {
                hull()
                {
                    tooldock_rbox([px0 + tooldock2_cwall,
                                   ky + tooldock2_cwall,
                                   pz1 - tooldock2_cskin],
                                  [tooldock2_wing_x0 - tooldock2_cwall,
                                   tooldock_plate_y1 - tooldock2_cwall,
                                   pz1 - tooldock2_cskin + 0.5], r=4);
                    tooldock_rbox([px0 + tooldock2_cwall + 1.2,
                                   ky + tooldock2_cwall + 1.2,
                                   pz0 - 1],
                                  [tooldock2_wing_x0 - tooldock2_cwall
                                       - 1.2,
                                   tooldock_plate_y1 - tooldock2_cwall
                                       - 1.2,
                                   pz0], r=3);
                }
                hull()
                {
                    tooldock_rbox([px0 + tooldock2_cwall,
                                   tooldock_plate_y0 + tooldock2_cwall,
                                   pz1 - tooldock2_cskin],
                                  [kx - tooldock2_cwall,
                                   tooldock_plate_y1 - tooldock2_cwall,
                                   pz1 - tooldock2_cskin + 0.5], r=4);
                    tooldock_rbox([px0 + tooldock2_cwall + 1.2,
                                   tooldock_plate_y0 + tooldock2_cwall
                                       + 1.2,
                                   pz0 - 1],
                                  [kx - tooldock2_cwall - 1.2,
                                   tooldock_plate_y1 - tooldock2_cwall
                                       - 1.2,
                                   pz0], r=3);
                }
            }
            // z-nut collar island (full plate depth under the skin).
            // Teardrop foot on the +y side: standing on the rear edge
            // the collar prints as a horizontal cylinder over the
            // shell cavity, so the under-arc gets 45-degree walls to
            // an apex instead of an unsupported belly. The prism may
            // poke past the cavity -- it only subtracts from the
            // cavity shape, so the excess is a no-op.
            translate([0, 0, pz0 - 0.1])
            linear_extrude(height=tooldock_plate_t - tooldock2_cskin
                                  + 0.2, convexity=4)
            {
                cx = tooldock_znut_screw_x;
                cy = -xaxis_zaxis_distance_y;
                td = tooldock2_collar_r * sqrt(2)/2;
                translate([cx, cy]) circle(r=tooldock2_collar_r, $fn=64);
                polygon([[cx - td, cy + td],
                         [cx + td, cy + td],
                         [cx, cy + 2*td]]);
            }
            // radial ribs: collar -> inboard-back wall, collar -> front
            tooldock_box([tooldock_znut_screw_x, -21, pz0 - 0.1],
                         [px1 - 2, -18, pz1 - tooldock2_cskin + 0.1]);
            tooldock_box([tooldock_znut_screw_x - 1.5,
                          tooldock_plate_y0 + 2,
                          pz0 - 0.1],
                         [tooldock_znut_screw_x + 1.5,
                          -xaxis_zaxis_distance_y,
                          pz1 - tooldock2_cskin + 0.1]);
        }

        // drop-in dovetail grooves in the backer face (see the .h)
        for(cy=tooldock2_dt_cy)
        tooldock2_dt_groove(cy);

        // z-bearing flange rebate along the plate's inboard top edge
        // (see the .h); a vertical step on the standing print
        tooldock_box([px0 - 1, tooldock_plate_y0 - 1,
                      tooldock2_zbrg_rebate_z],
                     [tooldock2_zbrg_rebate_x1, tooldock_plate_y1 + 1,
                      pz1 + 1]);

        // retention magnet pockets in the backer face -- FROZEN v1
        for(my=tooldock_mag_y)
        translate([tooldock_backer_x1 + e, my, tooldock_mag_z])
        rotate(-90*Y)
        cylinder(d=tooldock_mag_d, h=tooldock_mag_h + e, $fn=32);
    }
    else if(part=="neg")
    {
        // slide-in slot around the leadscrew, open to the outboard
        // edge, cut through the plate's full depth
        hull()
        for(sx=[tooldock_znut_screw_x, tooldock_plate_x0-2*mm])
        translate([sx, -xaxis_zaxis_distance_y, pz0 - 1.5])
        cylindera(d=tooldock_slot_screw_w,
                  h=tooldock_plate_t + 1.5 + e, align=Z);

        // z-nut clamp screws, reused with 9mm extra length; heads bear
        // under the plate
        for(sy=tooldock_znut_screw_y)
        translate([tooldock_znut_screw_x, sy, tooldock_plate_z0-e])
        screw_cut(thread=zaxis_nut[6], head="socket", with_nut=false,
                  h=28*mm, orient=Z, align=Z);
    }
    else if(part=="vit")
    {
        for(sy=tooldock_znut_screw_y)
        translate([tooldock_znut_screw_x, sy, tooldock_plate_z0])
        screw(thread=zaxis_nut[6], head="socket", h=28*mm, with_nut=false,
              orient=Z, align=Z);
    }
}

// -- towers ------------------------------------------------------------
// One hard-seat tower: rounded column from the floor, flat seat with the
// locating boss and the clamp magnet on top. No channels, no bores, no
// traps; the only up-facing precision surface is the seat, which lives
// under the carrier bar's eaves. Boss/magnet offsets are per-tower
// (mirrored about the bar center; see the .h).
module tooldock2_tower(i)
{
    cx  = tooldock2_tower_cx[i];
    sx0 = cx - tooldock2_seat_l/2;
    sx1 = cx + tooldock2_seat_l/2;
    sy0 = tooldock2_seat_y0;
    sy1 = sy0 + tooldock2_seat_w;
    st  = tooldock2_seat_top;

    // column lofted from a flared rounded foot to the seat slab
    hull()
    {
        tooldock_rbox([sx0, sy0, st - 3], [sx1, sy1, st], r=2.5);
        tooldock_rbox([sx0 - 2, sy0 - 2, tooldock_floor_z - 1],
                      [sx1 + 2, sy1 + 2, tooldock_floor_z + 2], r=4);
    }

    // locating boss with a chamfered tip for blind re-seating
    translate([cx + tooldock2_boss_dx[i], tooldock_bar_y, st - e])
    {
        cylinder(d=tooldock2_boss_d, h=tooldock2_boss_h - 0.8 + e,
                 $fn=28);
        tz(tooldock2_boss_h - 0.8)
        cylinder(d1=tooldock2_boss_d, d2=tooldock2_boss_d - 1.2,
                 h=0.8, $fn=28);
    }
}

// seat magnet pocket, opens up on the seat face (glue from above with
// the carrier off)
module tooldock2_tower_neg(i)
{
    translate([tooldock2_tower_cx[i] + tooldock2_mag_dx[i],
               tooldock_bar_y,
               tooldock2_seat_top - tooldock2_mag_h])
    cylinder(d=tooldock2_mag_d, h=tooldock2_mag_h + e, $fn=32);
}

// -- pad towers --------------------------------------------------------
// The same hard-seat idea turned 90 degrees for the pad carrier: two
// short towers along y under the park point, boss toward the cup and
// clamp magnet away from it. The base flare is pulled in 1 on the +x
// side to stay clear of the purge fall line.
module tooldock2_padtower(i)
{
    cx  = tooldock2_pfoot_cx;
    cy  = tooldock2_pfoot_cy[i];
    sx0 = cx - tooldock2_pseat_w/2;
    sx1 = cx + tooldock2_pseat_w/2;
    sy0 = cy - tooldock2_pseat_l/2;
    sy1 = cy + tooldock2_pseat_l/2;
    st  = tooldock2_pseat_top;

    hull()
    {
        tooldock_rbox([sx0, sy0, st - 3], [sx1, sy1, st], r=2.5);
        tooldock_rbox([sx0 - 2, sy0 - 2, tooldock_floor_z - 1],
                      [sx1 + 1, sy1 + 2, tooldock_floor_z + 2], r=4);
    }

    translate([cx + tooldock2_pboss_dx, cy + tooldock2_pboss_dy[i],
               st - e])
    {
        cylinder(d=tooldock2_boss_d, h=tooldock2_boss_h - 0.8 + e,
                 $fn=28);
        tz(tooldock2_boss_h - 0.8)
        cylinder(d1=tooldock2_boss_d, d2=tooldock2_boss_d - 1.2,
                 h=0.8, $fn=28);
    }
}

module tooldock2_padtower_neg(i)
{
    translate([tooldock2_pfoot_cx,
               tooldock2_pfoot_cy[i] + tooldock2_pmag_dy[i],
               tooldock2_pseat_top - tooldock2_mag_h])
    cylinder(d=tooldock2_mag_d, h=tooldock2_mag_h + e, $fn=32);
}

// -- bucket ------------------------------------------------------------
// The tub itself is the FROZEN v1 shell: mount magnet bosses and
// finger tab are reproduced from the v1 parameters via the v1 helper
// modules; the v1 dovetail rib is replaced by two vertical drop-in
// dovetail ribs (see the .h mount section). The interior changes: v1's
// yokes/jacks are
// replaced by the wiper hard-seat towers, and v1's press-in pad pocket
// and pedestal are replaced by a through-window in the wall's top band
// (the pad carrier's closed cup stands in it) plus two pad-carrier
// towers (the pad is now a separate cast-RTV tray).
module tooldock2_bucket(part)
{
    x0 = tooldock_bucket_x0;
    y0 = tooldock_bucket_y0;
    rim = tooldock_rim_z;
    w = tooldock_wall;

    if(part==U)
    {
        difference()
        {
            tooldock2_bucket(part="pos");
            tooldock2_bucket(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock2_bucket(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    union()
    {
        // drafted shell minus cavity -- v1 shell, v2 cavity (the only
        // cavity change is the bar-end relief band, retuned to the v2
        // bar envelope)
        difference()
        {
            tooldock_bucket_shell();
            tooldock2_bucket_cavity();
        }

        // drop-in dovetail ribs on the wall's inboard face (see the .h)
        for(cy=tooldock2_dt_cy)
        tooldock2_dt_rib(cy);

        // hard-seat towers, trimmed to the shell like the v1 yokes were
        intersection()
        {
            for(i=[0,1])
            tooldock2_tower(i);

            tooldock_bucket_shell();
        }

        // pad-carrier hard-seat towers, inboard of the wall recess
        intersection()
        {
            for(i=[0,1])
            tooldock2_padtower(i);

            tooldock_bucket_shell();
        }

        // mount magnet bosses with floor buttresses -- FROZEN v1
        intersection()
        {
            for(my=tooldock_mag_y)
            hull()
            {
                translate([x0 + 0.5, my, tooldock_mag_z])
                rotate(90*Y)
                cylinder(d=9.5*mm, h=w + 1.6, $fn=32);

                tooldock_box([x0, my - 7, tooldock_floor_z - 1],
                             [x0 + w + 2.1, my + 7,
                              tooldock_floor_z + 2]);
            }

            tooldock_bucket_shell();
        }

        // finger tab -- FROZEN v1
        hull()
        {
            tooldock_box([tooldock_park.x + 6, y0 - 3, rim - 3],
                         [tooldock_park.x + 26, y0 + 2, rim]);
            tooldock_box([tooldock_park.x + 9, y0 - e, rim - 9],
                         [tooldock_park.x + 23, y0 + 2, rim]);
        }
    }
    else if(part=="neg")
    {
        // seat magnet pockets
        for(i=[0,1])
        tooldock2_tower_neg(i);

        for(i=[0,1])
        tooldock2_padtower_neg(i);

        // mount magnet pockets in the outboard face -- FROZEN v1
        for(my=tooldock_mag_y)
        translate([x0 - e, my, tooldock_mag_z])
        rotate(90*Y)
        cylinder(d=tooldock_mag_d, h=tooldock_mag_h + e, $fn=32);

        // through-window in the wall's top band for the pad cup: the
        // cup's outboard wall stands in it (see the .h pad section)
        tooldock_box([tooldock_bucket_x0 - 1,
                      tooldock2_pcav_y0 - tooldock2_pcup_wall
                          - tooldock2_pwin_clr,
                      tooldock2_pwin_z0],
                     [tooldock_bucket_x0 + tooldock_wall + 0.5,
                      tooldock2_pcav_y1 + tooldock2_pcup_wall
                          + tooldock2_pwin_clr,
                      tooldock_rim_z + 20]);
    }
    else if(part=="vit")
    {
        // clamp magnets in the wiper seats
        color([0.4, 0.4, 0.45])
        for(i=[0,1])
        translate([tooldock2_tower_cx[i] + tooldock2_mag_dx[i],
                   tooldock_bar_y,
                   tooldock2_seat_top - 3])
        cylinder(d=6*mm, h=3*mm, $fn=32);

        // nominal shim stack on each wiper seat
        color([0.9, 0.6, 0.2])
        for(i=[0,1])
        translate([tooldock2_tower_cx[i] + tooldock2_boss_dx[i],
                   tooldock_bar_y,
                   tooldock2_seat_top])
        difference()
        {
            cylinder(d=8.5*mm, h=tooldock2_stack_nom, $fn=32);
            tz(-e) cylinder(d=tooldock2_shim_id,
                            h=tooldock2_stack_nom + 2*e, $fn=32);
        }

        // clamp magnets and nominal shim stacks on the pad seats
        color([0.4, 0.4, 0.45])
        for(i=[0,1])
        translate([tooldock2_pfoot_cx,
                   tooldock2_pfoot_cy[i] + tooldock2_pmag_dy[i],
                   tooldock2_pseat_top - 3])
        cylinder(d=6*mm, h=3*mm, $fn=32);

        color([0.9, 0.6, 0.2])
        for(i=[0,1])
        translate([tooldock2_pfoot_cx + tooldock2_pboss_dx,
                   tooldock2_pfoot_cy[i] + tooldock2_pboss_dy[i],
                   tooldock2_pseat_top])
        difference()
        {
            cylinder(d=8.5*mm, h=tooldock2_stack_nom, $fn=32);
            tz(-e) cylinder(d=tooldock2_shim_id,
                            h=tooldock2_stack_nom + 2*e, $fn=32);
        }
    }
}

// v1 cavity with the bar-end relief retuned to the v2 bar (wider bar,
// relief starts just above the seats). Shell-facing numbers unchanged.
module tooldock2_bucket_cavity()
{
    w = tooldock_wall;
    dr = tooldock_bucket_draft;
    cd = tooldock_cavity_draft;
    hull()
    {
        tooldock_rbox([tooldock_bucket_x0 + w, tooldock_bucket_y0 + w,
                       tooldock_rim_z - 2],
                      [tooldock_bucket_x1 - w, tooldock_bucket_y1 - w,
                       tooldock_rim_z + 20],
                      r=tooldock_bucket_r - 1.5);
        tooldock_rbox([tooldock_bucket_x0 + w,
                       tooldock_bucket_y0 + dr + w + cd,
                       tooldock_floor_z],
                      [tooldock_bucket_x1 - dr - w - cd,
                       tooldock_bucket_y1 - dr - w - cd,
                       tooldock_floor_z + 2],
                      r=tooldock_bucket_r - 1.5);
    }

    // vertical relief in the drafted inboard face for the bar end;
    // starts BELOW the seat plane so the bar clears the wall lean even
    // with the shim stack empty (bar bottom = seat top)
    tooldock_box([tooldock_bar_x1 - 6,
                  tooldock_bar_y - tooldock2_bar_w/2 - 0.8,
                  tooldock2_seat_top - 0.4],
                 [tooldock_bucket_x1 - w,
                  tooldock_bar_y + tooldock2_bar_w/2 + 0.8,
                  tooldock_rim_z + 20]);
}

// -- carrier -----------------------------------------------------------
// Plain bar: blade slot on top, boss pockets and magnet pockets in the
// underside. Modeled at NOMINAL height (shim stack = stack_nom); the
// real height is wherever the shims put it. The mirrored per-tower
// pocket pattern is 180-degree-rotation symmetric, so the same print
// serves the mirrored right-side dock (and flipping it on its own dock
// is harmless: slot and blade are centered).
module tooldock2_carrier(part)
{
    bx0 = tooldock_bar_x0;
    bx1 = tooldock_bar_x1;
    by0 = tooldock_bar_y - tooldock2_bar_w/2;
    by1 = tooldock_bar_y + tooldock2_bar_w/2;
    top = tooldock2_bar_top;
    bot = tooldock2_bar_bot;

    if(part==U)
    {
        difference()
        {
            tooldock2_carrier(part="pos");
            tooldock2_carrier(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock2_carrier(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    tooldock2_rbox3([bx0, by0, bot], [bx1, by1, top], r=2.5, rz=1);
    else if(part=="neg")
    {
        // wiper slot, friction fit, closed ends
        tooldock_box([tooldock_slot_x0,
                      tooldock_bar_y - tooldock_slot_w/2,
                      top - tooldock2_slot_depth],
                     [tooldock_slot_x1,
                      tooldock_bar_y + tooldock_slot_w/2,
                      top + e]);

        for(i=[0,1])
        {
            // locating boss pocket
            translate([tooldock2_tower_cx[i] + tooldock2_boss_dx[i],
                       tooldock_bar_y, bot - e])
            cylinder(d=tooldock2_pocket_d,
                     h=tooldock2_pocket_depth + e, $fn=28);

            // clamp magnet pocket
            translate([tooldock2_tower_cx[i] + tooldock2_mag_dx[i],
                       tooldock_bar_y, bot - e])
            cylinder(d=tooldock2_mag_d,
                     h=tooldock2_mag_h + e, $fn=32);
        }
    }
    else if(part=="vit")
    {
        // A1 silicone wiper blade seated in the slot
        color([0.72, 0.72, 0.75])
        translate([(tooldock_slot_x0+tooldock_slot_x1)/2, tooldock_bar_y,
                   top - tooldock2_slot_depth])
        cubea([tooldock_wiper_l, tooldock_wiper_t, tooldock_wiper_h],
              align=Z);
    }
}

// -- pad carrier -------------------------------------------------------
// The cast-RTV nozzle-block tray: a bar along y under the park point,
// the open-topped cup mid-span, a widened foot at each end riding the
// pad towers. The thin lip on the outboard side overhangs the bucket
// wall recess so the silicone keeps v1's margin around the nozzle
// contact patch. NOT flip-mountable by construction (see the .h); the
// right-side dock takes the mirrored print.
module tooldock2_padcarrier(part)
{
    x0  = tooldock2_pbar_x0;
    x1  = tooldock2_pfoot_x1;
    top = tooldock2_prim_top;
    bot = tooldock2_pbar_bot;
    cy0 = tooldock2_pcav_y0;
    cy1 = tooldock2_pcav_y1;
    w   = tooldock2_pcup_wall;

    if(part==U)
    {
        difference()
        {
            tooldock2_padcarrier(part="pos");
            tooldock2_padcarrier(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock2_padcarrier(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    union()
    {
        // bar as one pairwise hull chain: wide foot -> cup-width
        // mid section -> wide foot. The feet are widened so the
        // magnet pockets get full walls; each taper completes within
        // 5, ending 2.6 before the purge fall line, which keeps the
        // window at spine width. The 0.5 rim roll is the most the
        // 1.6 cup wall allows next to the cavity opening.
        hull_pairwise()
        {
            tooldock2_rbox3([x0, tooldock2_pbar_y0, bot],
                            [x1, tooldock2_pbar_y0 + tooldock2_pfoot_l,
                             top], r=2, rz=0.5);
            tooldock2_rbox3([x0, tooldock2_pbar_y0 + tooldock2_pfoot_l
                                 + 5, bot],
                            [tooldock2_pcup_x1,
                             tooldock2_pbar_y1 - tooldock2_pfoot_l - 5,
                             top], r=2, rz=0.5);
            tooldock2_rbox3([x0, tooldock2_pbar_y1 - tooldock2_pfoot_l,
                             bot],
                            [x1, tooldock2_pbar_y1, top], r=2, rz=0.5);
        }

        // cup body standing in the bucket wall's window: carries the
        // cup's outboard wall (0.95) and the 1.0 cavity floor out to it
        tooldock2_rbox3([tooldock2_pcup_x0, cy0 - w,
                         tooldock2_plip_bot],
                        [x0 + 0.1, cy1 + w, top], r=0.8, rz=0.4);
    }
    else if(part=="neg")
    {
        // cast cavity: all four walls undercut (wider at the bottom)
        // so the cured RTV keys in
        hull()
        {
            tooldock_box([tooldock2_pcav_x0 + 0.8,
                          tooldock2_pcav_y0 + 0.8,
                          top - 0.5],
                         [tooldock2_pcav_x1 - 0.8,
                          tooldock2_pcav_y1 - 0.8,
                          top + e]);
            tooldock_box([tooldock2_pcav_x0,
                          tooldock2_pcav_y0,
                          tooldock2_pcav_floor],
                         [tooldock2_pcav_x1,
                          tooldock2_pcav_y1,
                          tooldock2_pcav_floor + 0.5]);
        }

        // floor key dimples, kept over the bar body (the cup floor
        // out over the wall window is only 1.0 thick)
        for(ky=[tooldock2_pcav_y0 + 3, tooldock2_pcav_y1 - 3])
        translate([tooldock_park.x + 2.5, ky,
                   tooldock2_pcav_floor - 1.2])
        cylinder(d=4*mm, h=1.2 + e, $fn=24);

        // boss and clamp magnet pockets in the feet undersides
        for(i=[0,1])
        {
            translate([tooldock2_pfoot_cx + tooldock2_pboss_dx,
                       tooldock2_pfoot_cy[i] + tooldock2_pboss_dy[i],
                       bot - e])
            cylinder(d=tooldock2_pocket_d,
                     h=tooldock2_pocket_depth + e, $fn=28);

            translate([tooldock2_pfoot_cx,
                       tooldock2_pfoot_cy[i] + tooldock2_pmag_dy[i],
                       bot - e])
            cylinder(d=tooldock2_mag_d,
                     h=tooldock2_mag_h + e, $fn=32);
        }
    }
    else if(part=="vit")
    {
        // the cast pad at nominal thickness, tooled proud of the rim
        color([0.8, 0.15, 0.1])
        tooldock_box([tooldock2_pcav_x0, cy0, tooldock2_pcav_floor],
                     [tooldock2_pcav_x1, cy1,
                      tooldock2_pcav_floor + tooldock2_pcast_t]);
    }
}

// one shim washer; thickness is identified by its diameter
module tooldock2_shim(i)
{
    difference()
    {
        cylinder(d=tooldock2_shim_od[i], h=tooldock2_shim_t[i], $fn=48);
        tz(-e)
        cylinder(d=tooldock2_shim_id, h=tooldock2_shim_t[i] + 2*e,
                 $fn=32);
    }
}

// full v2 dock in the x-end frame
module tool_dock2(beltpath_index=0)
{
    side = beltpath_index==0 ? -1 : 1;
    xend_x = main_width/2 + zmotor_mount_rod_offset_x;

    echo(str("tool dock v2 ", side==-1?"left":"right",
        ": park nozzle X=",
        side==-1 ? tooldock_park.x-xend_x : xend_x-tooldock_park.x,
        "  purge X=",
        side==-1 ? tooldock2_purge_x-xend_x : xend_x-tooldock2_purge_x,
        "  purge window=", tooldock2_purge_window, "mm",
        "  engagement range=",
        tooldock_engage_nom - tooldock2_stack_nom, "..",
        tooldock_engage_nom
            + (tooldock2_stack_max - tooldock2_stack_nom), "mm",
        "  (shims; nominal stack ", tooldock2_stack_nom,
        ")  trim blade to ", tooldock_wiper_l, "mm",
        "  cast pad ", tooldock2_pcast_t, " nominal, tool it ~2.5 proud"));

    tooldock2_chassis();
    tooldock2_bucket();
    tooldock2_carrier();
    tooldock2_padcarrier();
}

// -- printed parts --
// chassis prints STANDING on its rear faces (+y edge; they all share
// one plane, see tooldock2_rear_y1): the wing deck, neck sweep,
// nut-trap ledge and dovetail groove all become vertical, so no
// support field -- only the shell cells bridge their ceilings and the
// screw bores/magnet pockets print as horizontal holes. Layers stack
// along y, which puts the whole droop load path (plate z, wing x,
// backer z) in-plane. bucket prints floor down, no
// supports (tower columns and the wall recess are self-standing).
// carrier prints on its front face (slot and pockets sideways). pad
// carrier prints feet down as modeled: pocket ceilings bridge as small
// discs and the cup lip is a 1.7mm bridge ledge -- self-supporting.
// shims print flat; print the 0.2 at 0.1 layers.
// hardware per side: 2x M3x25 (chassis clamp), 14x d6x3 magnets
// (3 pairs bucket<->backer at unequal spacing, 2 pairs wiper seat<->bar,
// 2 pairs pad seat<->tray; glue the chassis/seat magnets first, let
// them orient each mate before gluing), 1x trimmed A1 blade, RTV
// silicone cast into the pad tray (tool ~2.5 proud, cure, shim to
// squish), printed shim washers per seat: 2x 0.2, 2x 0.4, 1x 0.8
// covers the whole range in 0.2 steps -- four seats per side.

module part_tooldock2_chassis_left()
{
    tz(tooldock_plate_y1)
    rotate([-90,0,0])
    tooldock2_chassis();
}

module part_tooldock2_chassis_right()
{
    tz(tooldock_plate_y1)
    rotate([-90,0,0])
    mirror([1,0,0])
    tooldock2_chassis();
}

module part_tooldock2_bucket_left()
{
    tz(-tooldock_bucket_z0)
    tooldock2_bucket();
}

module part_tooldock2_bucket_right()
{
    tz(-tooldock_bucket_z0)
    mirror([1,0,0])
    tooldock2_bucket();
}

// same part both sides (the mirrored pocket pattern is rotation
// symmetric); print two
module part_tooldock2_carrier()
{
    ty(tooldock2_bar_top)
    tz(tooldock2_bar_w/2 - tooldock_bar_y)
    rotate(90*X)
    tooldock2_carrier();
}

// printed UPSIDE DOWN: the bar top and the cup rim are one flat plane
// (the bed face), the undercut cavity walls then lean only ~9 degrees,
// the 7-wide cavity floor bridges, and the cup body that stands in the
// bucket wall's window -- a 2.65 cantilever off the bar that cannot be
// gusseted, the wall sits under it at full shim drop -- prints as a
// top face. The right part is the left one turned 180 degrees about z
// (verified congruent), so one STL serves both docks; both wrappers
// are kept for the harness.
module part_tooldock2_padcarrier_left()
{
    tz(tooldock2_prim_top)
    rotate([0, 180, 0])
    tooldock2_padcarrier();
}

module part_tooldock2_padcarrier_right()
{
    tz(tooldock2_prim_top)
    rotate([0, 180, 0])
    mirror([1,0,0])
    tooldock2_padcarrier();
}

// one full shim set (two seats' worth): 2x 0.2, 2x 0.4, 1x 0.8 each --
// sizes identify thicknesses. Four seats per side: print two sets per
// side.
module part_tooldock2_shims()
{
    counts = [2, 2, 1];
    for(i=[0:2], n=[0:counts[i]-1])
    translate([i*12, n*12, 0])
    for(tw=[0,1])
    translate([0, tw*36, 0])
    tooldock2_shim(i);
}
