include <config.scad>;
include <x-end.h>
include <x-carriage.h>
include <printbed.h>

// Tool dock: nozzle wiper + purge bucket for the IDEX tools, one per x-end.
// The tools are "docked" whenever they sit at the X endstops, and the x-end
// travels with the gantry in Z, so a dock hung off the x-end sees the parked
// tool at one fixed offset at every layer height. Everything below is in the
// x-end local frame (the frame xaxis_end() is drawn in): +X inboard toward
// the bed, -Y toward the machine front, origin on the z-rod axis at x-rod
// height. The right-hand dock is the same geometry mirrored by the caller,
// exactly like the x-end itself.
//
// Three printed parts per side:
//  - chassis: a thick plate clamped under the z-nut flange by its two M3
//    screws (lengthened to M3x25), blending into an arm that reaches
//    inboard past the frame side rail to a tall backer wall with a
//    dovetail rail.
//  - bucket: a big rounded tub that slides onto the rail from the machine
//    front - pull it forward to empty it, no tools. Carries two towers
//    for the wiper carrier.
//  - carrier: the blade holder bar, clamped in the towers through
//    vertical slots so blade engagement is adjustable.

// -- parked tool, derived from the machine config --

// keep in sync with axis_range_x_ in main.scad
tooldock_axis_range_x_ = main_width/2 - extrusion_size - x_carriage_w/2 + 20;

// nozzle tip position with the carriage against the endstop
tooldock_park = [
    main_width/2 + zmotor_mount_rod_offset_x - tooldock_axis_range_x_
        + extruder_offset.x + extruder_b_filapath_offset.x,
    -xaxis_bearing_top_OD/2 - xaxis_carriage_bearing_offset_y
        + extruder_b_filapath_offset.y,
    extruder_offset.z + extruder_offset_b.z
        + extruder_b_hotend_mount_offset.z - hotend_height,
];

// The nozzle tip is the lowest point of the moving toolhead; ducts and the
// probe sit >=1.5mm higher. Static dock geometry inboard of the x-end plan
// outline must stay this far below the nozzle-tip plane so the toolhead
// sweeps over it at any X. Only the silicone blade may poke above.
tooldock_sweep_clearance = 1.65*mm;
tooldock_rim_z = tooldock_park.z - tooldock_sweep_clearance;

// -- world obstacles at Z-min, in this local frame --
// The gantry bottoms out with axis_pos_z = 95.35 (see main.scad); world z
// maps to local z - axis_pos_z. Static things the dock must clear:
//  - frame side rail: local x band [rod_offset, rod_offset+extrusion],
//    top at world 0 = local -95.35 at Z-min
//  - z-motor mount plate: local x 0..rod_offset, top world 20 = -75.35
//  - z-motor mount addon tower: local x ~15..40, top world ~32 = -63.35
//  - under-bed plate: local x >= rod_offset+extrusion, top world -9.51
//    = local -104.86
//  - heatbed mockup edge (254 wide): local x 137.19
tooldock_axis_min_z = 95.35*mm;     // keep in sync with axis_range_z[0]
tooldock_railband_x0 = zmotor_mount_rod_offset_x;
tooldock_railband_x1 = zmotor_mount_rod_offset_x + extrusion_size;
tooldock_rail_top = -tooldock_axis_min_z;
tooldock_motorplate_top = 20*mm - tooldock_axis_min_z;
// the z-motor mount addon: a 2mm adapter plate (local x ~6.5..47.7, top
// world 22) under a tower housing the coupling (local x ~11.5..42.7 at
// its base disc, column to x ~39.2, top world ~32)
tooldock_addonplate_top = 22*mm - tooldock_axis_min_z;
tooldock_addontower_x1 = 43*mm;
tooldock_addontower_top = 32*mm - tooldock_axis_min_z;
tooldock_ybedplate_top = -9.5125*mm - tooldock_axis_min_z;
tooldock_bed_edge_x = main_width/2 + zmotor_mount_rod_offset_x
    - (printbed_size.x + 4*mm)/2;

// -- Bambu A1 silicone wiper (the big A1, not the mini) --
// nominal 37.5 x 8 x 4.5mm; MEASURE the actual blades and tune the fit

// The tool only ever moves in X relative to the dock, so the blade lies
// ALONG X: docking drags the nozzle tip lengthwise through the blade's top
// edge for the full blade length, and undocking wipes it again on the way
// out. NOTE: whether the A1 itself wipes lengthwise is unverified; this
// design does either way, and deposits debris off the blade ends into the
// bucket on both strokes.

// TRIM the 37.5mm blade to this length (straight scissors cut). The freed
// span becomes the purge window beside the nozzle pad; at full blade
// length the window all but disappears (the purge assert below enforces
// this).
tooldock_wiper_l = 30*mm;     // length, along the travel
tooldock_wiper_t = 4.5*mm;    // blade thickness
tooldock_wiper_h = 8*mm;      // height
// how much of the blade height is buried in the carrier slot
tooldock_wiper_slot_depth = 4.6*mm;
// slot is this much narrower than the blade for a friction grip
tooldock_wiper_pinch = 0.3*mm;
// slot length clearance
tooldock_wiper_fit_l = 0.4*mm;

// -- chassis: clamp plate under the x-end --
// The x-end body is the convex hull of its projection with a flat bottom
// face at -wz/2; the z-nut flange (d36 x 5) sits proud below it, held by
// two M3 screws. The chassis plate is sandwiched between that flange and
// the (lengthened) screws: slide it in from outboard - an open slot lets
// it pass around the captive leadscrew - then the two screws clamp it.
// The plate covers most of the bottom-face footprint (probed: x -13..53.7,
// y -37..+13.7) so moment loads bear on the wide flange contact and the
// screws stay in pure tension.

tooldock_plate_t = 10*mm;
// plate top presses the z-nut flange underside (tiny slack, closed by the
// screws)
tooldock_plate_z1 = -xaxis_end_wz/2 - zaxis_nut[3] - 0.05*mm;
tooldock_plate_z0 = tooldock_plate_z1 - tooldock_plate_t;
// backed off a little from the parked carriage face
tooldock_gap = 0.3*mm;
// outboard edge keeps 2mm to the z-rod surface
tooldock_plate_x0 = 8*mm;
tooldock_plate_x1 = xaxis_end_width(true) - tooldock_gap;
tooldock_plate_y0 = -36.5*mm;
tooldock_plate_y1 = 9*mm;
tooldock_plate_r = 5*mm;

// The parked toolhead hangs a block below the x-end bottom at the
// plate's front-inboard corner (probed empirically: local x >= 49.1,
// y -36.4..-19.4, z -47.5..-57.3). Keep-out with margins; the plate and
// block are cut back around it.
// governed by the Stealthburner cowl width at plate height (probed
// reach: local x 44.8); the old toolhead's B-motor face sat at 49.1
tooldock_keepout_x0 = 43.8*mm;
tooldock_keepout_y1 = -17.9*mm;
tooldock_keepout_z0 = -58.9*mm;

// the z-nut clamp screws, as placed in xaxis_end(); reuse with +9mm
// length: M3x16 -> M3x25
tooldock_znut_screw_x = zaxis_rod_screw_distance_x;
tooldock_znut_screw_y = [
    -xaxis_zaxis_distance_y - zaxis_nut[5],
    -xaxis_zaxis_distance_y + zaxis_nut[5],
];
// leadscrew slide-in slot width
tooldock_slot_screw_w = zaxis_nut[2] + 5*mm;

// -- chassis: block, arm and backer --
// Below the plate a block fills the space under the x-end, then an arm
// dives under the toolhead sweep plane, crosses the frame side rail band
// and ends in a tall backer wall that carries the bucket rail. Depth
// limits at Z-min: z-motor addon tower (local x ~15..40) caps the block
// at x<41; the motor mount plate caps the arm at -73 while over it; past
// the rail band the arm and backer drop to -93 (2.35 above the rail top).

tooldock_block_x0 = 41*mm;
tooldock_block_y0 = tooldock_plate_y0;
tooldock_block_y1 = -2*mm;
// block bottom clears the addon adapter plate; only the arm (inboard of
// the adapter's reach) may go deeper, down to the mount plate limit
tooldock_block_z0 = tooldock_addonplate_top + 2.35*mm;   // -71
tooldock_arm_z0 = tooldock_motorplate_top + 2.35*mm;     // -73

tooldock_arm_x0 = 50*mm;
// arm front edge: reaches forward of the block to triangulate the
// extended backer (clean vs the machine: the SB cowl exists only above
// z=-60.1 there, the arm tops out at the rim)
tooldock_arm_y0 = -50*mm;
tooldock_arm_z0_deep = tooldock_rail_top + 2.35*mm;      // -93

// +1.8 (was +1.5): the rib tip passes the frame upright band during
// slide-out with 0.6mm instead of 0.3mm
tooldock_backer_x1 = tooldock_railband_x1 + 1.8*mm;
// thick enough to swallow the retention magnets
tooldock_backer_x0 = tooldock_backer_x1 - 5.5*mm;
// extended to the bucket front: longer groove mouth for blind
// insertion and room for the third magnet pair
tooldock_backer_y0 = -72*mm;
tooldock_backer_y1 = 4*mm;
tooldock_backer_z0 = tooldock_arm_z0_deep;

// -- bucket rail: dovetail slide, open at the machine front --
// A dovetailed rib along the bucket's outboard wall top slides into a
// groove in the backer face from the front (-y); pull the bucket forward
// to take it off. The dovetail carries the weight and the wipe drag;
// two magnet pairs in the mating faces stop vibration from walking the
// bucket out, and a firm forward pull breaks them in shear.

// groove centerline: kept BELOW the pad pocket band (pocket floor is at
// pad_floor ~ -70.5) so the rib keeps the full wall thickness behind it
// instead of the 1.1mm skin the pocket leaves higher up
tooldock_rail_z = -74*mm;
tooldock_rail_h = 3.4*mm;        // groove height at the opening
tooldock_rail_depth = 1.4*mm;
tooldock_rail_angle = 15;        // dovetail undercut
// closed end (slide-in stop). Moved forward so the dovetail disengages
// after ~59.6mm of slide-out: the bucket's front corner meets the front
// y-rod clamps at ~65.3mm (probed at Z-min), so the window must sit
// forward enough to release before that
tooldock_rail_y1 = -12*mm;
// the last stretch before the closed end loses this much groove height
// (top flank only): pushing the bucket home wedges the rib tight and
// takes up the 0.2mm flank clearance (0.75mm of pull-out play otherwise)
tooldock_rail_wedge = 0.35*mm;
tooldock_rail_wedge_l = 12*mm;
tooldock_rail_clr = 0.2*mm;
tooldock_rib_setback = 1*mm;

// retention magnets: neodymium discs (6x3 nominal), glued into open
// pockets in both mating faces, attracting across the 0.2 interface gap.
// Glue them in attracting orientation!
tooldock_mag_d = 6.2*mm;         // pocket diameter (magnet 6.0)
tooldock_mag_h = 3.1*mm;         // pocket depth (magnet 3.0)
tooldock_mag_z = -80*mm;
// three pairs; UNEQUAL spacing on purpose, so a mis-seated bucket can
// never latch two pairs at a false offset
tooldock_mag_y = [-64*mm, -36*mm, -14*mm];

// -- bucket --
// One big rounded tub, fully inboard of the frame side rail band; the
// nozzle physically cannot travel outboard of park (the endstop), so
// nothing is lost by not reaching under the x-end. Walls and cavity are
// drafted (hull between a top and an inset bottom slab) for organic looks
// and easy emptying; floor bottom stays 2.5 above the under-bed plate.

tooldock_wall = 2.5*mm;
tooldock_bucket_x0 = tooldock_backer_x1 + tooldock_rail_clr;
tooldock_bucket_x1 = tooldock_bed_edge_x - 4*mm;
// front wall flush with the (extended) backer
tooldock_bucket_y0 = tooldock_backer_y0;
tooldock_bucket_y1 = tooldock_backer_y1;
tooldock_bucket_z0 = tooldock_ybedplate_top + 2.5*mm;    // -102.36
tooldock_bucket_r = 6*mm;
tooldock_bucket_draft = 2.5*mm;  // side draft: bottom inset by this
tooldock_floor = 3.4*mm;
tooldock_floor_z = tooldock_bucket_z0 + tooldock_floor;
tooldock_cavity_draft = 2.2*mm;

tooldock_assert_park_over_bucket =
    assert(tooldock_bucket_x0 + tooldock_wall < tooldock_park.x - 0.5);

// -- wiper carrier: adjustable blade holder --
// A bar along X with the friction slot on top, ends resting in two yoke
// towers; each end has a vertical slot so a Y-axis M3 clamp screw (from
// the machine front) locks it at any height over a 4mm range. At the top
// of the range the bar stays 0.4 below the rim so only silicone ever
// meets the toolhead.

tooldock_bar_w = 8*mm;           // bar width in y
tooldock_bar_h = 6.5*mm;
tooldock_slot_w = tooldock_wiper_t - tooldock_wiper_pinch;
tooldock_slot_l = tooldock_wiper_l + tooldock_wiper_fit_l;

tooldock_bar_top_max = tooldock_rim_z - 0.4*mm;
tooldock_adj_travel = 4*mm;
// blade tip engagement above the nozzle plane, at the top of the range
tooldock_engage_max = tooldock_bar_top_max
    + (tooldock_wiper_h - tooldock_wiper_slot_depth) - tooldock_park.z;
// the standing blade tip at max engagement must clear the toolhead duct
// bottom (park.z + sweep_clearance) as the ducts sweep over it in X
tooldock_assert_engage = assert(tooldock_bar_top_max
    + tooldock_wiper_h - tooldock_wiper_slot_depth
    <= tooldock_park.z + tooldock_sweep_clearance - 0.2*mm);

// inboard margin keeps the bar end off the drafted inboard wall; the
// cavity also gets a local vertical relief there (tooldock_bucket_cavity)
tooldock_slot_x1 = tooldock_bucket_x1 - tooldock_wall - 3*mm;
tooldock_slot_x0 = tooldock_slot_x1 - tooldock_slot_l;
tooldock_bar_x1 = tooldock_slot_x1 + 2.05*mm;
tooldock_bar_x0 = tooldock_slot_x0 - 2.05*mm;
tooldock_assert_bar_wall = assert(tooldock_bar_x1 + 0.45*mm
    <= tooldock_bucket_x1 - tooldock_wall);
tooldock_bar_y = tooldock_park.y;    // bar centered on the nozzle line

// tongues at the bar ends, front faces flush with the bar front so the
// carrier can print lying flat on that face
tooldock_tongue_t = 3.2*mm;      // thickness in y
tooldock_tongue_l = 10*mm;       // length in x
tooldock_tongue_h = 16*mm;       // below the bar
tooldock_tongue_cx = [
    tooldock_bar_x0 + 1*mm + tooldock_tongue_l/2,
    tooldock_bar_x1 - 1*mm - tooldock_tongue_l/2,
];
tooldock_tongue_y0 = tooldock_bar_y - tooldock_bar_w/2;  // front-flush

// towers: yokes on the bucket floor, channel open at the top. Their tops
// stay under the bar at its lowest position so the bar never lands on
// them; the tongues alone reach down into the channels.
tooldock_yoke_gap = tooldock_tongue_t + 0.4*mm;
tooldock_yoke_flank = 3.2*mm;
// yoke centered on the channel (which is front-flush on the bar), not on
// the bar itself, so both flanks get full thickness
tooldock_yoke_y0 = tooldock_tongue_y0 - 0.2*mm - tooldock_yoke_flank;
tooldock_yoke_y1 = tooldock_tongue_y0 + tooldock_tongue_t + 0.2*mm
    + tooldock_yoke_flank;
tooldock_yoke_l = tooldock_tongue_l + 0.6*mm + 6*mm;     // x extent
tooldock_yoke_top = tooldock_bar_top_max - tooldock_bar_h
    - tooldock_adj_travel - 0.5*mm;

// -- carrier height adjustment: jack screws from the bucket underside --
// Each tongue bottom rests its dimple on the tip of a vertical M3x12 that
// threads through a nyloc trapped at the yoke root. Turn from below (hex
// key into the recessed head in the bucket bottom) to set blade
// engagement; the nyloc holds the setting. A d6x3 magnet in each tongue
// front face shears against a partner in the yoke front flank (constant
// 0.2mm gap) so the carrier cannot hop off the jack tips, yet pulls
// straight up for a blade swap without disturbing the height.
tooldock_jack_thread = ThreadM3;
tooldock_jack_nut_w = 5.8*mm;    // M3 nyloc across flats + fit
tooldock_jack_nut_t = 4.4*mm;    // nyloc thickness + fit
tooldock_jack_nut_z0 = tooldock_floor_z + 1.6*mm;   // trap slot bottom
tooldock_jack_mag_d = 6.2*mm;    // d6x3 magnet pockets (attracting pair)
tooldock_jack_mag_h = 3.0*mm;
tooldock_jack_mag_z = -80*mm;
// nominal engagement and the tongue bottom it puts the jack tips at
tooldock_engage_nom = 0.7*mm;
tooldock_tongue_bot_nom = tooldock_park.z + tooldock_engage_nom
    - (tooldock_wiper_h - tooldock_wiper_slot_depth)
    - tooldock_bar_h - tooldock_tongue_h;
// channel bottom: clearance under the tongue at its lowest (travel/2)
tooldock_chan_bot = tooldock_tongue_bot_nom - tooldock_adj_travel/2
    - 1.5*mm;

// -- nozzle-block pad --
// A piece of solid silicone sheet the parked nozzle rests on, sealing the
// tip so an idle-but-hot tool cannot ooze (both tools stay at print temp).
// Cut it from the sheet, press it into the undercut pocket on the bucket's
// outboard wall top; trim squish with thin shims under it, pry it out via
// the slot under it. Only the compliant pad crosses the sweep plane; every
// rigid pocket part stays below the plane.
tooldock_pad_t = 8*mm;           // silicone sheet thickness
// modeled squish; the rib rides the groove's bottom flank so the seated
// bucket sits rail_clr (0.2) low, leaving ~0.35mm of actual squish
tooldock_pad_squish = 0.55*mm;
tooldock_pad_wall = 1.4*mm;      // pocket wall thickness
// the outer 1.1mm of the bucket wall keeps full height as the pocket's
// outboard lip (it also backs the dovetail rib behind it)
tooldock_pad_x0 = tooldock_bucket_x0 + 1.1*mm;
tooldock_pad_x1 = tooldock_pad_x0 + 6*mm;
tooldock_pad_y0 = tooldock_park.y - 6*mm;
tooldock_pad_y1 = tooldock_park.y + 6*mm;
tooldock_pad_top = tooldock_park.z + tooldock_pad_squish;
tooldock_pad_floor = tooldock_pad_top - tooldock_pad_t;
// rigid pocket lips stop just below the sweep plane
tooldock_pad_lip_z = tooldock_rim_z - 0.2*mm;
tooldock_pad_undercut = 0.7*mm;  // lip inset; the pad squeezes past it
tooldock_pedestal_x1 = tooldock_pad_x1 + tooldock_pad_wall;
tooldock_pedestal_y0 = tooldock_pad_y0 - tooldock_pad_wall;
tooldock_pedestal_y1 = tooldock_pad_y1 + tooldock_pad_wall;
// the nozzle contact patch must land well inside the pad, and the pad
// top must clear the duct bottom by >= 1mm
tooldock_assert_pad = assert(
    tooldock_park.x - tooldock_pad_x0 >= 2*mm
    && tooldock_pad_x1 - tooldock_park.x >= 2*mm
    && tooldock_pad_top
       <= tooldock_park.z + tooldock_sweep_clearance - 1*mm);

// purge point: the open window between the pad pedestal and the carrier
// bar end
tooldock_purge_x = (tooldock_pedestal_x1 + tooldock_bar_x0 - 1*mm)/2;
tooldock_purge_window = tooldock_bar_x0 - 1*mm - tooldock_pedestal_x1;
tooldock_assert_purge = assert(tooldock_purge_window >= 4*mm);
