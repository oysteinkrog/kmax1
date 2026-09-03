include <tool-dock.h>
include <thing_libutils/system.scad>
include <thing_libutils/materials.scad>

use <thing_libutils/shapes.scad>
use <thing_libutils/transforms.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/misc.scad>

use <x-end.scad>

// Wiper + purge bucket dock for the parked IDEX tools. Drawn in the x-end
// local frame and placed by main.scad inside the same mirror context as
// xaxis_end(), so one model serves both sides; see tool-dock.h for the
// frame conventions and all the clearance reasoning.
//
// Three printed parts per side (the carrier is the same part both sides):
//  - chassis: plate clamped under the z-nut flange by its two screws
//    (M3x16 -> M3x25), arm reaching inboard over the frame side rail,
//    backer wall with the dovetail rail and the retention magnets.
//  - bucket: rounded drafted tub, slides onto the rail from the machine
//    front; two magnet pairs hold it seated and a firm forward pull
//    releases it, no tools. Carries the two carrier yokes.
//  - carrier: blade holder bar, height-adjustable in the yokes with two
//    M3 clamp screws driven from the machine front.

// axis-aligned box between two corner points
module tooldock_box(from, to)
{
    translate([min(from.x,to.x), min(from.y,to.y), min(from.z,to.z)])
    cube([abs(to.x-from.x), abs(to.y-from.y), abs(to.z-from.z)]);
}

// slab with rounded vertical corners, between two corner points
module tooldock_rbox(from, to, r=3)
{
    x0 = min(from.x,to.x); x1 = max(from.x,to.x);
    y0 = min(from.y,to.y); y1 = max(from.y,to.y);
    z0 = min(from.z,to.z); z1 = max(from.z,to.z);
    hull()
    for(x=[x0+r, x1-r])
    for(y=[y0+r, y1-r])
    translate([x, y, z0])
    cylinder(r=r, h=z1-z0, $fn=32);
}

// dovetail profile extruded along y from y0..y1, centered on
// tooldock_rail_z at the plane x=xf, pointing -x when depth>0.
// h is the height at the opening plane; the undercut widens it inward.
module tooldock_dovetail(xf, y0, y1, h, depth)
{
    u = depth*tan(tooldock_rail_angle);
    translate([0, y1, 0])
    rotate(90*X)
    linear_extrude(height=y1-y0)
    polygon([
        [xf, tooldock_rail_z - h/2],
        [xf, tooldock_rail_z + h/2],
        [xf - depth, tooldock_rail_z + h/2 + u],
        [xf - depth, tooldock_rail_z - h/2 - u],
    ]);
}

module tooldock_chassis(part)
{
    px0 = tooldock_plate_x0;
    px1 = tooldock_plate_x1;
    bz0 = tooldock_backer_z0;

    if(part==U)
    {
        difference()
        {
            tooldock_chassis(part="pos");
            tooldock_chassis(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock_chassis(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    union()
    {
        difference()
        {
            union()
            {
                // clamp plate under the z-nut flange
                tooldock_rbox([px0, tooldock_plate_y0, tooldock_plate_z0],
                              [px1, tooldock_plate_y1, tooldock_plate_z1],
                              r=tooldock_plate_r);

                // block filling the space below the plate, still under
                // the x-end plan outline (the toolhead is never above it)
                hull()
                {
                    tooldock_rbox([tooldock_block_x0, tooldock_block_y0,
                                   tooldock_plate_z0 - 1],
                                  [px1, tooldock_block_y1,
                                   tooldock_plate_z0],
                                  r=3);
                    tooldock_rbox([tooldock_block_x0 + 3,
                                   tooldock_block_y0,
                                   tooldock_block_z0],
                                  [px1, tooldock_block_y1,
                                   tooldock_block_z0 + 1],
                                  r=3);
                }

                // arm: everything inboard of the x-end plan stays below
                // the sweep plane; it dives deeper once past the motor
                // mount plate and spreads sideways into the backer
                hull()
                {
                    tooldock_box([tooldock_arm_x0, tooldock_arm_y0,
                                  tooldock_arm_z0],
                                 [px1, tooldock_block_y1,
                                  tooldock_rim_z]);
                    tooldock_rbox([tooldock_backer_x0,
                                   tooldock_backer_y0, bz0],
                                  [tooldock_backer_x1,
                                   tooldock_backer_y1, tooldock_rim_z],
                                  r=1);
                }
            }

            // dovetail groove in the backer face, open at the front. The
            // last rail_wedge_l before the closed end tapers the height
            // (top flank only, bottom flank stays planar) so pushing the
            // bucket home wedges the rib tight: without this the 0.2mm
            // flank clearance is 0.75mm of pull-out play at 15 degrees
            union()
            {
                tooldock_dovetail(xf=tooldock_backer_x1 + e,
                                  y0=tooldock_backer_y0 - e,
                                  y1=tooldock_rail_y1
                                     - tooldock_rail_wedge_l,
                                  h=tooldock_rail_h,
                                  depth=tooldock_rail_depth + e);
                hull()
                {
                    tooldock_dovetail(xf=tooldock_backer_x1 + e,
                                      y0=tooldock_rail_y1
                                         - tooldock_rail_wedge_l,
                                      y1=tooldock_rail_y1
                                         - tooldock_rail_wedge_l + 0.2,
                                      h=tooldock_rail_h,
                                      depth=tooldock_rail_depth + e);
                    tz(-tooldock_rail_wedge/2)
                    tooldock_dovetail(xf=tooldock_backer_x1 + e,
                                      y0=tooldock_rail_y1 - 0.2,
                                      y1=tooldock_rail_y1,
                                      h=tooldock_rail_h
                                        - tooldock_rail_wedge,
                                      depth=tooldock_rail_depth + e);
                }
            }

            // retention magnet pockets in the backer face (glue magnets
            // in, attracting the pair in the bucket wall)
            for(my=tooldock_mag_y)
            translate([tooldock_backer_x1 + e, my, tooldock_mag_z])
            rotate(-90*Y)
            cylinder(d=tooldock_mag_d, h=tooldock_mag_h + e, $fn=32);

            // parked-toolhead keep-out at the plate front-inboard corner
            tooldock_box([tooldock_keepout_x0, -60,
                          tooldock_keepout_z0],
                         [tooldock_plate_x1 + e, tooldock_keepout_y1,
                          tooldock_plate_z1 + e]);

            // the arm hull edges must not dip below the z-motor mount
            // plate while still over it
            tooldock_box([tooldock_arm_x0 - 5, -100,
                          -120],
                         [tooldock_railband_x0 + 2, 100,
                          tooldock_arm_z0]);

            // and nothing except the plate may hang over the addon
            // adapter plate / tower base deeper than the block bottom
            tooldock_box([-10, -100, -120],
                         [tooldock_block_x0 + 3, 100,
                          tooldock_block_z0]);
        }

    }
    else if(part=="neg")
    {
        // slide-in slot around the leadscrew, open to the outboard edge
        hull()
        for(sx=[tooldock_znut_screw_x, tooldock_plate_x0-2*mm])
        translate([sx, -xaxis_zaxis_distance_y, tooldock_plate_z0-e])
        cylindera(d=tooldock_slot_screw_w, h=tooldock_plate_t+2*e,
                  align=Z);

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

module tooldock_bucket(part)
{
    x0 = tooldock_bucket_x0;
    x1 = tooldock_bucket_x1;
    y0 = tooldock_bucket_y0;
    y1 = tooldock_bucket_y1;
    z0 = tooldock_bucket_z0;
    rim = tooldock_rim_z;
    dr = tooldock_bucket_draft;
    w = tooldock_wall;
    cd = tooldock_cavity_draft;
    // rib front stays clear of the bucket's front-outboard roundover
    // (the wall face recedes there and would detach the rib again)
    rib_y0 = max(tooldock_backer_y0 + tooldock_rib_setback,
                 tooldock_bucket_y0 + tooldock_bucket_r + 1);
    rib_y1 = tooldock_rail_y1 - 0.4;
    rib_h = tooldock_rail_h - 2*tooldock_rail_clr;
    rib_d = tooldock_rail_depth - tooldock_rail_clr;

    if(part==U)
    {
        difference()
        {
            tooldock_bucket(part="pos");
            tooldock_bucket(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock_bucket(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    union()
    {
        // drafted shell: full section at the rim, inset at the floor;
        // the cavity is carved here (not in "neg") so the yokes standing
        // inside it survive. The outboard face stays vertical - it is
        // the slide interface.
        difference()
        {
            tooldock_bucket_shell();
            tooldock_bucket_cavity();
        }

        // dovetail rib on the outboard face; the chamfered nose eases the
        // rib into the backer groove (retention is by the magnets, the
        // wedge at the groove's closed end takes up the play). The base
        // plane sits e INSIDE the wall so the rib is fused to it; it
        // still crosses the rail_clr face gap into the groove.
        tooldock_dovetail(xf=x0 + e,
                          y0=rib_y0 + 1.5, y1=rib_y1,
                          h=rib_h, depth=rib_d + e);
        hull()
        {
            tooldock_dovetail(xf=x0 + e,
                              y0=rib_y0 + 1.5, y1=rib_y0 + 1.7,
                              h=rib_h, depth=rib_d + e);
            tooldock_dovetail(xf=x0 + e,
                              y0=rib_y0, y1=rib_y0 + 0.2,
                              h=rib_h, depth=0.2 + e);
        }

        // carrier yokes rising from the floor, trimmed to the shell so
        // their flared bases cannot poke through the drafted walls
        intersection()
        {
            for(cx=tooldock_tongue_cx)
            tooldock_yoke(cx);

            tooldock_bucket_shell();
        }

        // interior bosses backing the magnet pockets (the wall alone is
        // thinner than the magnets), each blended down to the floor as a
        // buttress; trimmed to the shell so the front boss cannot poke
        // through the drafted front wall
        intersection()
        {
            for(my=tooldock_mag_y)
            hull()
            {
                translate([x0 + 0.5, my, tooldock_mag_z])
                rotate(90*Y)
                cylinder(d=9.5*mm, h=w + 1.6, $fn=32);

                tooldock_box([x0, my - 7, tooldock_floor_z - 1],
                             [x0 + w + 2.1, my + 7, tooldock_floor_z + 2]);
            }

            tooldock_bucket_shell();
        }

        // finger tab on the front wall top for pulling the bucket out
        hull()
        {
            tooldock_box([tooldock_park.x + 6, y0 - 3, rim - 3],
                         [tooldock_park.x + 26, y0 + 2, rim]);
            tooldock_box([tooldock_park.x + 9, y0 - e, rim - 9],
                         [tooldock_park.x + 23, y0 + 2, rim]);
        }

        // nozzle-pad pedestal: a hulled buttress flowing out of the
        // outboard wall and floor, carrying the undercut pad pocket on
        // top. The flare keeps clear of the purge fall line inboard.
        intersection()
        {
            hull()
            {
                tooldock_rbox([tooldock_bucket_x0, tooldock_pedestal_y0,
                               tooldock_pad_lip_z - 8],
                              [tooldock_pedestal_x1, tooldock_pedestal_y1,
                               tooldock_pad_lip_z], r=2.5);
                tooldock_rbox([tooldock_bucket_x0,
                               tooldock_pedestal_y0 - 9,
                               tooldock_floor_z - 1],
                              [tooldock_pedestal_x1 + 2,
                               tooldock_pedestal_y1 + 9,
                               tooldock_floor_z + 2], r=6);
            }
            tooldock_bucket_shell();
        }
    }
    else if(part=="neg")
    {
        // yoke channels, clamp screws and nut traps
        for(cx=tooldock_tongue_cx)
        tooldock_yoke_neg(cx);

        // retention magnet pockets in the outboard face, mating the pair
        // in the chassis backer
        for(my=tooldock_mag_y)
        translate([x0 - e, my, tooldock_mag_z])
        rotate(90*Y)
        cylinder(d=tooldock_mag_d, h=tooldock_mag_h + e, $fn=32);

        // pad pocket: walls lean inward toward the lips so the silicone
        // pad squeezes past and locks under them
        hull()
        {
            tooldock_rbox([tooldock_pad_x0 + tooldock_pad_undercut,
                           tooldock_pad_y0 + tooldock_pad_undercut,
                           tooldock_pad_lip_z],
                          [tooldock_pad_x1 - tooldock_pad_undercut,
                           tooldock_pad_y1 - tooldock_pad_undercut,
                           tooldock_rim_z + 20], r=1);
            tooldock_rbox([tooldock_pad_x0 - 0.15,
                           tooldock_pad_y0 - 0.15,
                           tooldock_pad_floor],
                          [tooldock_pad_x1 + 0.15,
                           tooldock_pad_y1 + 0.15,
                           tooldock_pad_floor + 0.5], r=1);
        }

        // pry channel under the pad: rounded tunnel from in front of the
        // buttress to mid-pad; slide a flat tool in to lever the pad and
        // shims out
        hull()
        for(px=[tooldock_park.x - 1.2, tooldock_park.x + 1.2])
        translate([px, tooldock_pedestal_y0 - 12,
                   tooldock_pad_floor + 1.4])
        rotate(-90*X)
        cylinder(d=3.2*mm,
                 h=tooldock_park.y - tooldock_pedestal_y0 + 12 + e,
                 $fn=24);
    }
    else if(part=="vit")
    {
        // jack screws standing under the tongues (M3x12, nyloc at the
        // yoke root)
        for(cx=tooldock_tongue_cx)
        translate([cx, tooldock_tongue_y0 + tooldock_tongue_t/2,
                   tooldock_tongue_bot_nom])
        screw(thread=tooldock_jack_thread, head="socket", h=12*mm,
              with_nut=false, orient=-Z, align=-Z);

        // silicone nozzle-block pad seated in the pedestal pocket
        color([0.85, 0.85, 0.88])
        tooldock_rbox([tooldock_pad_x0, tooldock_pad_y0,
                       tooldock_pad_floor],
                      [tooldock_pad_x1, tooldock_pad_y1,
                       tooldock_pad_top], r=1);
    }
}

// bucket outer solid, drafted
module tooldock_bucket_shell()
{
    hull()
    {
        tooldock_rbox([tooldock_bucket_x0, tooldock_bucket_y0,
                       tooldock_rim_z - 2],
                      [tooldock_bucket_x1, tooldock_bucket_y1,
                       tooldock_rim_z], r=tooldock_bucket_r);
        tooldock_rbox([tooldock_bucket_x0,
                       tooldock_bucket_y0 + tooldock_bucket_draft,
                       tooldock_bucket_z0],
                      [tooldock_bucket_x1 - tooldock_bucket_draft,
                       tooldock_bucket_y1 - tooldock_bucket_draft,
                       tooldock_bucket_z0 + 2],
                      r=tooldock_bucket_r);
    }
}

// bucket cavity, drafted except the outboard face, which stays vertical
// so drips near the parked nozzle fall clear instead of running down a
// leaning wall
module tooldock_bucket_cavity()
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

    // local vertical relief in the drafted inboard face where the carrier
    // bar end rides: the draft leans 0.3..0.9mm into the bar's travel
    // envelope there. Starts just above the yoke tops so the yokes keep
    // their full section.
    tooldock_box([tooldock_bar_x1 - 6,
                  tooldock_bar_y - tooldock_bar_w/2 - 0.8,
                  tooldock_yoke_top + 0.2],
                 [tooldock_bucket_x1 - w,
                  tooldock_bar_y + tooldock_bar_w/2 + 0.8,
                  tooldock_rim_z + 20]);
}

// one yoke tower, positive part; sits on the floor with a flared base
module tooldock_yoke(cx)
{
    hull()
    {
        tooldock_rbox([cx - tooldock_yoke_l/2, tooldock_yoke_y0,
                       tooldock_floor_z - 1],
                      [cx + tooldock_yoke_l/2, tooldock_yoke_y1,
                       tooldock_yoke_top], r=2);
        tooldock_rbox([cx - tooldock_yoke_l/2 - 3, tooldock_yoke_y0 - 3,
                       tooldock_floor_z - 1],
                      [cx + tooldock_yoke_l/2 + 3, tooldock_yoke_y1 + 3,
                       tooldock_floor_z + 2], r=3);
    }
}

module tooldock_yoke_neg(cx)
{
    chan_l = tooldock_tongue_l + 0.6*mm;
    jack_y = tooldock_tongue_y0 + tooldock_tongue_t/2;  // screw axis

    // tongue channel, open at the top
    tooldock_box([cx - chan_l/2,
                  tooldock_tongue_y0 - 0.2,
                  tooldock_chan_bot],
                 [cx + chan_l/2,
                  tooldock_tongue_y0 + tooldock_tongue_t + 0.2,
                  tooldock_yoke_top + e]);

    // jack screw: recessed head in the bucket underside, bore up through
    // the nyloc trap at the yoke root, loose bore to the channel bottom
    translate([cx, jack_y, 0])
    {
        translate([0, 0, tooldock_bucket_z0 - e])
        cylinder(d=6.5*mm,
                 h=tooldock_jack_nut_z0 - 0.6 - tooldock_bucket_z0 + e,
                 $fn=24);
        translate([0, 0, tooldock_jack_nut_z0 - 1])
        cylinder(d=3.4*mm, h=tooldock_jack_nut_t + 2, $fn=24);
        translate([0, 0, tooldock_jack_nut_z0 + tooldock_jack_nut_t - e])
        cylinder(d=4.2*mm,
                 h=tooldock_chan_bot
                   - (tooldock_jack_nut_z0 + tooldock_jack_nut_t) + 2*e,
                 $fn=24);
    }

    // nyloc trap: side slot, slides in from the yoke back face
    translate([cx - tooldock_jack_nut_w/2, jack_y - 3.4,
               tooldock_jack_nut_z0])
    cubea([tooldock_jack_nut_w,
           tooldock_yoke_y1 - jack_y + 3.4 + e,
           tooldock_jack_nut_t], align=X+Y+Z);

    // magnet pocket in the front flank's channel face (glue; attracting
    // pair with the tongue magnet, constant-gap shear coupling). Offset
    // to the bottom of the adjustment travel so the tongue magnet is
    // never below it: the shear pull is downward everywhere in range,
    // pressing the carrier onto the screw tips instead of lifting it
    // off when adjusting below nominal
    translate([cx, tooldock_tongue_y0 - 0.2 + e,
               tooldock_jack_mag_z - tooldock_adj_travel/2])
    rotate(90*X)
    cylinder(d=tooldock_jack_mag_d, h=tooldock_jack_mag_h + 0.05,
             $fn=24);
}

module tooldock_carrier(part)
{
    bx0 = tooldock_bar_x0;
    bx1 = tooldock_bar_x1;
    by0 = tooldock_bar_y - tooldock_bar_w/2;
    by1 = tooldock_bar_y + tooldock_bar_w/2;
    top = tooldock_bar_top_max;   // modeled at the top of its travel
    bot = top - tooldock_bar_h;

    if(part==U)
    {
        difference()
        {
            tooldock_carrier(part="pos");
            tooldock_carrier(part="neg");
        }
        if(!is_undef($show_vit) && $show_vit)
        tooldock_carrier(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        // bar with rounded ends
        tooldock_rbox([bx0, by0, bot], [bx1, by1, top], r=2.5);

        // tongues at the ends, front faces flush with the bar front so
        // the part prints lying flat on that face. No root gusset: at the
        // bottom of the travel the bar sits only 0.5mm above the yoke
        // tops, so anything wider than the channel can never pass into it
        for(cx=tooldock_tongue_cx)
        tooldock_rbox([cx - tooldock_tongue_l/2, tooldock_tongue_y0,
                       bot - tooldock_tongue_h],
                      [cx + tooldock_tongue_l/2,
                       tooldock_tongue_y0 + tooldock_tongue_t,
                       bot + 1], r=1);
    }
    else if(part=="neg")
    {
        // wiper slot, friction fit, closed ends
        tooldock_box([tooldock_slot_x0,
                      tooldock_bar_y - tooldock_slot_w/2,
                      top - tooldock_wiper_slot_depth],
                     [tooldock_slot_x1,
                      tooldock_bar_y + tooldock_slot_w/2,
                      top + e]);

        // jack tip dimples in the tongue bottoms
        for(cx=tooldock_tongue_cx)
        translate([cx, tooldock_tongue_y0 + tooldock_tongue_t/2,
                   bot - tooldock_tongue_h - e])
        cylinder(d=3.8*mm, h=1.8*mm + e, $fn=24);

        // magnet pockets in the tongue front faces; placed so the magnet
        // sits at tooldock_jack_mag_z when the carrier is at nominal
        // engagement (the part is modeled at the top of its travel)
        for(cx=tooldock_tongue_cx)
        translate([cx, tooldock_tongue_y0 - e,
                   tooldock_jack_mag_z
                   + (bot - tooldock_tongue_h - tooldock_tongue_bot_nom)])
        rotate(-90*X)
        cylinder(d=tooldock_jack_mag_d, h=tooldock_jack_mag_h + 0.05,
                 $fn=24);
    }
    else if(part=="vit")
    {
        // A1 silicone wiper blade seated in the slot
        color([0.72, 0.72, 0.75])
        translate([(tooldock_slot_x0+tooldock_slot_x1)/2, tooldock_bar_y,
                   top - tooldock_wiper_slot_depth])
        cubea([tooldock_wiper_l, tooldock_wiper_t, tooldock_wiper_h],
              align=Z);
    }
}

// full dock in the x-end frame; beltpath_index as passed to xaxis_end()
module tool_dock(beltpath_index=0)
{
    side = beltpath_index==0 ? -1 : 1;
    xend_x = main_width/2 + zmotor_mount_rod_offset_x;
    purge_x = tooldock_purge_x;

    echo(str("tool dock ", side==-1?"left":"right",
        ": park nozzle X=", side==-1 ? tooldock_park.x-xend_x : xend_x-tooldock_park.x,
        "  purge X=", side==-1 ? purge_x-xend_x : xend_x-purge_x,
        "  blade X=", side==-1 ? tooldock_slot_x1-xend_x : xend_x-tooldock_slot_x1,
        " to ", side==-1 ? tooldock_slot_x0-xend_x : xend_x-tooldock_slot_x0,
        "  purge window=", tooldock_purge_window, "mm",
        "  (machine frame); z-nut screws become M3x25; trim blade to ",
        tooldock_wiper_l, "mm"));

    tooldock_chassis();
    tooldock_bucket();
    tooldock_carrier();
}

// -- printed parts --
// chassis prints upside down, plate top on the bed; enable
// build-plate-only support (it lands under the arm top and backer).
// bucket prints floor down, no supports (rib overhangs and the pad
// pocket's lip ramps are shallow; the nut-trap and pry-slot ceilings are
// short bridges).
// carrier prints lying on its flat front face, slot sideways.
// hardware per side: 2x M3x25 (chassis), 2x M3x12 + 2x M3 nyloc (jacks),
// 10x d6x3 magnets (3 pairs bucket<->backer at unequal spacing, 2 pairs
// tongue<->yoke; glue the chassis/yoke magnets first, then let them
// orient each mating magnet before gluing so every pair attracts),
// 1x trimmed A1 blade, 1x silicone pad ~6x12mm cut from 8mm sheet
// (+ thin shims to tune squish).

module part_tooldock_chassis_left()
{
    tz(tooldock_plate_z1)
    rotate([0,180,0])
    tooldock_chassis();
}

module part_tooldock_chassis_right()
{
    tz(tooldock_plate_z1)
    rotate([0,180,0])
    mirror([1,0,0])
    tooldock_chassis();
}

module part_tooldock_bucket_left()
{
    tz(-tooldock_bucket_z0)
    tooldock_bucket();
}

module part_tooldock_bucket_right()
{
    tz(-tooldock_bucket_z0)
    mirror([1,0,0])
    tooldock_bucket();
}

// same part for both sides; print two
module part_tooldock_carrier()
{
    ty(tooldock_bar_top_max)
    tz(tooldock_bar_w/2 - tooldock_bar_y)
    rotate(90*X)
    tooldock_carrier();
}

if(false)
{
    // dev preview: left x-end with its dock
    xaxis_end(with_motor=true, beltpath_index=0, show_motor=true);
    tool_dock(beltpath_index=0);
}
