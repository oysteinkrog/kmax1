include <tool-dock.h>

// Tool dock v2: same dock architecture (chassis on the z-nut, bucket
// dropped onto the backer, blade wiped lengthwise), redesigned after the v1
// jack review and the first test print:
//
//  - The wiper carrier sits on a HARD SEAT: two towers on the bucket
//    floor, blade height set once at commissioning by stacking printed
//    shim washers over a locating boss on each tower top. No screws, no
//    nylocs, no thrust membranes, nothing to follow or to foul: the
//    nozzle-to-dock Z is a construction constant, so in-service
//    adjustability bought nothing but failure modes. Vertical magnet
//    pairs (tower seat <-> bar underside) clamp the bar down onto the
//    shim stack and let it pull straight off for blade swaps; the boss
//    re-locates it exactly, so the setting survives the swap.
//  - The chassis is rebuilt from rounded drafted lofts placed inside the
//    allowed envelope BY CONSTRUCTION (no subtractive keep-out boxes, no
//    sharp carved edges). The backer envelope and the mount magnet
//    pattern stay bit-identical to v1.
//  - The v1 horizontal dovetail slide is REPLACED by two short VERTICAL
//    dovetails the bucket drops onto (see the mount section below): the
//    printed test showed the 3.0x1.2 rib is too fiddly to thread blind
//    and too weak against bumps. The v1 bucket no longer mates the v2
//    chassis.
//
// Everything not defined here is inherited from tool-dock.h; the frozen
// v1 numbers (backer, mount magnets, bucket shell, pad, purge layout)
// are referenced by name, never re-typed. The v1 rail constants remain
// defined there but nothing in v2 uses them any more.

// -- chassis: plate, riser, wing, backer --
// Three stacked prisms and nothing else. The clamp plate (kept from the
// shell design: 4 top skin, 3 walls, cells open at the underside, solid
// collar around the z-nut) sits on a short riser; the riser lands on a
// flat horizontal WING plate that spans the full backer length and
// butt-welds flush into the backer's inboard face. Every z limit is a
// v1 envelope constant:
//  - wing top = rim: inboard of the x-end plan outline everything rigid
//    stays sweep_clearance below the nozzle-tip plane (tool-dock.h:41),
//    and the wing top then continues the backer top as ONE plane
//  - wing bottom = block_z0 (-71): 2.35 above the z-motor addon adapter
//    plate, the binding floor for x < 47.7
//  - wing x0 = 44: past the addon tower base disc (probed reach x 42.7;
//    the tower column itself ends at x 43)
// The old skirt/deep-zone/arm/knee/buttress stack is gone; the wing is
// a solid 6.5 plate (it IS the wall that gives strength).
tooldock2_cwall = 3*mm;          // plate shell wall
tooldock2_cskin = 4*mm;          // plate top skin (flange side)
// solid collar around the z-nut: flange bearing ring + both screw
// bosses (screws sit 13.5 from the nut center, flange radius 18)
tooldock2_collar_r = 19*mm;

// -- z-bearing flange rebate --
// The x-end's z linear bearing (LMH12L) sits with its flange UNDER the
// x-end bottom face: the flange hangs 6 below that face, the plate top
// sits only 5.05 below it (the nut flange), and the flange's 27-wide cut
// side reaches x 13.5 while the plate starts at x 8 -- a 0.95 x 5.5
// interference along the plate's inboard edge. Found on the test print;
// the machine probe had missed it because xaxis_end() draws its
// vitamins with the % modifier, which CGAL ignores (the probe now adds
// them solid). Fix: a rebate in the plate top along that edge, 2 clear
// of the flange side and 0.65 below its underside. The nut flange
// contact loses its outboard 5.5 (x 10..15.5) and keeps 30.
tooldock2_zbrg_flange_z0 = -xaxis_end_wz/2
    - get(LinearBearingFlangeThickness, zaxis_bearing);      // -48.49
tooldock2_zbrg_flange_x1 =
    get(LinearBearingFlangeCutDiameter, zaxis_bearing)/2;    // 13.5
tooldock2_zbrg_rebate_x1 = tooldock2_zbrg_flange_x1 + 2*mm; // 15.5
tooldock2_zbrg_rebate_z = tooldock2_zbrg_flange_z0 - 0.65*mm;   // -49.14
tooldock2_assert_zbrg = assert(
    tooldock2_zbrg_rebate_z <= tooldock2_zbrg_flange_z0 - 0.5*mm
    && tooldock_plate_z1 - tooldock2_zbrg_rebate_z
        <= tooldock2_cskin - 2*mm                  // >=2 skin over cells
    && tooldock2_zbrg_rebate_x1 > tooldock_plate_x0 + 2*mm);
tooldock2_wing_x0 = 44*mm;
tooldock2_wing_z0 = tooldock_block_z0;               // -71
tooldock2_wing_top = tooldock_rim_z;                 // -64.5
tooldock2_wing_r_front = 8*mm;   // plan radius, front-inboard corner
tooldock2_wing_r_rear = 4*mm;    // plan radius, rear-inboard corner
tooldock2_assert_wing = assert(
    tooldock2_wing_x0 >= tooldock_addontower_x1 + 1*mm
    && tooldock2_wing_z0 >= tooldock_addonplate_top + 2.3*mm
    && tooldock2_wing_top <= tooldock_rim_z + 0.001);

// neck: the connection between the clamp plate and the wing carries
// the whole dock's moment, so it uses every legal millimeter of its
// window, built as a pairwise hull chain (rounded stations, smooth
// chines, no stacked blocks):
//  - descent: straight drop from the plate underside to a station 0.5
//    under the cowl corner's z floor, kept behind the keep-out line
//  - flare: from that station the section sweeps forward and down
//    onto the wing, reaching the plate's full front depth at the wing
//    plane. Every interpolated face sits at or below the corner
//    floor, so the sweep cannot clip the parked cowl.
//  - cheek: a full-height web on the inboard strip (x < keepout_x0,
//    where the cowl corner does not exist), running the plate's full
//    depth. It ties the plate's front edge straight down to the
//    flare, which multiplies the neck's droop stiffness: a web at
//    full section depth dominates the bending inertia.
//  - landing: the flare's wing-plane station sits flush with the
//    wing top, and the chain continues into the wing itself
//    (hull_pairwise), so the neck sweeps onto the wing as a plan
//    skirt instead of sitting on it as a tongue.
// All of it runs to the plate's REAR edge (y 9); the cowl only
// limits the front. x0 clears the z-motor addon COLUMN (reach x 39.2,
// tool-dock.h:64) by 1; only the wing must clear the base DISC
// (x 42.7), because the disc tops out at -70.57, below everything
// but the wing.
tooldock2_riser_x0 = 40.2*mm;
tooldock2_riser_front_top = tooldock_keepout_z0 - 0.5*mm;   // -59.4

// neck shoulder bar: the sphere-row station shared by the descent and
// flare hulls; its radius rolls the shoulder chine (the edge where
// the vertical front face turns into the flare's sweep). Center depth
// is set so the swept top face crosses the keep-out line at ~ -59.4:
// the tangent from the wing station rises ~1.6 above the sphere
// centers there, so the 0.5 margin under the parked cowl's corner
// floor is preserved.
tooldock2_shoulder_r = 2*mm;
tooldock2_shoulder_z = tooldock2_riser_front_top - 1.6*mm;   // -61.0

// print-stand redesign: the chassis prints standing on its REAR (+y)
// edge, so every rear face is pulled to one plane at the plate's
// rear edge. For the wing and cove this is new legal envelope
// (machine-probed); for the backer it is a deliberate exception to
// the v1 freeze -- rear face only, gated by the mate probes. The
// groove ends at rail_y1 and opens at the FRONT face, so the
// extension never touches the bucket's slide path.
tooldock2_rear_y1 = tooldock_plate_y1;                       // 9
tooldock2_assert_riser = assert(
    tooldock2_riser_x0 >= 39.2*mm + 1*mm
    && tooldock2_riser_front_top <= tooldock_keepout_z0 - 0.5*mm
        + 0.001
    && tooldock_keepout_x0 - tooldock2_riser_x0 >= 3*mm  // printable cheek
    && tooldock2_wing_top < -63.35*mm);  // wing stays under the tower top

// -- carrier bar --
// Wider than v1 so it eaves over the tower seats (debris roof) and deep
// enough to host the blade slot on top and the boss/magnet pockets
// underneath with solid webs between.
tooldock2_bar_w = 11*mm;
tooldock2_bar_h = 10.5*mm;
// blade buried a touch less than v1 (4.05 vs 4.6): the exposed 3.95
// keeps the bar top low enough that the whole shim range stays legal
// against both the rim rule and the duct line (asserts below)
tooldock2_slot_depth = 4.05*mm;
// bar top at NOMINAL engagement (0.7, inherited)
tooldock2_bar_top = tooldock_park.z + tooldock_engage_nom
    - (tooldock_wiper_h - tooldock2_slot_depth);            // -66.10
tooldock2_bar_bot = tooldock2_bar_top - tooldock2_bar_h;    // -76.60

// -- shim stack --
// Printed washers dropped over the locating boss with the carrier lifted
// off (a two-second magnet pull); captive on the boss, clamped by the
// magnets, cannot vibrate out. Thickness is identified by diameter.
// Range is asymmetric on purpose: the duct line caps upward correction
// at +0.7 (same ceiling v1 had), downward correction gets the rest.
tooldock2_stack_nom = 1.2*mm;    // nominal stack = 0.4 + 0.8
tooldock2_stack_max = 1.9*mm;    // design ceiling for the asserts
tooldock2_shim_t = [0.2*mm, 0.4*mm, 0.8*mm];
tooldock2_shim_od = [8*mm, 8.5*mm, 9*mm];   // size identifies thickness
tooldock2_shim_id = 4.6*mm;

// -- towers --
// Rounded columns from the bucket floor, flat seat on top carrying the
// locating boss and the clamp magnet. The bar overhangs the seat by the
// eave all around, roofing the seat interface against falling debris;
// there are no channels, traps or upward bores anywhere.
tooldock2_seat_top = tooldock2_bar_bot - tooldock2_stack_nom;  // -77.80
tooldock2_seat_l = 16*mm;        // x extent
tooldock2_eave = 1.8*mm;
tooldock2_seat_w = tooldock2_bar_w - 2*tooldock2_eave;         // 7.4
tooldock2_seat_y0 = tooldock_bar_y - tooldock2_seat_w/2;
tooldock2_tower_cx = tooldock_tongue_cx;    // v1 positions carry over

// locating boss (on the seat) and its pocket (in the bar underside):
// fixes x/y and yaw; wipe drag reacts here, not on the magnets.
// Per-tower offsets MIRRORED about the bar center: that makes the
// boss/magnet pattern 180-degree-rotation symmetric, so one and the
// same printed bar fits the mirrored right-side dock (rotated about
// vertical). With the v1-style uniform offset the right-side bosses
// missed their pockets by 9mm and each side needed a chiral print.
tooldock2_boss_d = 4*mm;
tooldock2_boss_h = 4*mm;
tooldock2_boss_dx = [-4.5*mm, 4.5*mm];   // per tower, along x
tooldock2_pocket_d = tooldock2_boss_d + 0.4*mm;
tooldock2_pocket_depth = tooldock2_boss_h + 0.4*mm;

// clamp magnets: d6x3 pair per tower (seat face up, bar face down,
// attracting through the shim stack). Both pockets open onto free faces
// for gluing; polarity: glue the seat magnets first, let them orient
// the bar magnets before gluing.
tooldock2_mag_dx = [3.5*mm, -3.5*mm];    // per tower, mirrored too
tooldock2_mag_d = 6.2*mm;
tooldock2_mag_h = 3.1*mm;

// -- the dimension chain, asserted end to end --
// (the v1 jack died of an unchecked column; never again)
// 1. bar top at the design-max stack stays under the rim rule
tooldock2_assert_rim = assert(
    tooldock2_bar_top + (tooldock2_stack_max - tooldock2_stack_nom)
    <= tooldock_rim_z - 0.4*mm + 0.001);
// 2. blade tip at the design-max stack clears the duct sweep line
tooldock2_assert_duct = assert(
    tooldock2_bar_top + (tooldock2_stack_max - tooldock2_stack_nom)
    + (tooldock_wiper_h - tooldock2_slot_depth)
    <= tooldock_park.z + tooldock_sweep_clearance - 0.2*mm + 0.001);
// 3. the boss still engages the bar pocket by >=2 at max stack
tooldock2_assert_boss = assert(
    tooldock2_boss_h - tooldock2_stack_max >= 2*mm);
// 4. the pocket is deeper than the boss (bar seats on the shims/seat,
//    never on the boss tip)
tooldock2_assert_pocket = assert(
    tooldock2_pocket_depth >= tooldock2_boss_h + 0.3*mm);
// 5. webs inside the bar: slot floor to boss-pocket ceiling, and the
//    boss-to-magnet pocket wall (tower 0 checked; tower 1 is its exact
//    mirror by construction)
tooldock2_assert_webs = assert(
    tooldock2_bar_h - tooldock2_slot_depth - tooldock2_pocket_depth
        >= 1.6*mm
    && (tooldock2_mag_dx[0] - tooldock2_mag_d/2)
       - (tooldock2_boss_dx[0] + tooldock2_pocket_d/2) >= 2*mm);
// 6. seat magnet and boss both fit on the seat
tooldock2_assert_seat = assert(
    tooldock2_boss_dx[0] - tooldock2_boss_d/2
        >= -tooldock2_seat_l/2 + 1*mm
    && tooldock2_mag_dx[0] + tooldock2_mag_d/2
        <= tooldock2_seat_l/2 - 1*mm
    && tooldock2_mag_d <= tooldock2_seat_w - 1*mm);
// -- pad carrier: cast-RTV nozzle-block tray --
// v1's press-in sheet pad becomes a separate printed part: a bar along
// Y under the park point, a closed open-topped cup mid-span that red
// RTV silicone is cast into, and a foot at each end riding the SAME
// hard-seat mechanism as the wiper carrier (boss + shim stack + clamp
// magnet, identical washers). The nozzle parks 3.15 from the bucket's
// inboard face, so the cup's outboard wall has to stand where the
// bucket wall is: the wall's top band gets a through-window there and
// the cup's outboard wall sits in it, 0.15 inside the bucket's inboard
// face. (The first v2 draft kept a 0.9 wall parapet and left the cup
// open on that side, to be taped shut for casting -- rejected: the pad
// looked small and unsupported, and taping a mould is a chore.)
//
// Casting: on the bench, cup up. Fill with RTV, tool it ~2.5 proud of
// the rigid rim, cure, then set the actual squish with shims exactly
// like the blade. The cast keys on undercut walls on all four sides
// plus the floor dimples.
tooldock2_pcav_x0 = tooldock_pad_x0;        // 77.29, v1 margin kept
tooldock2_pcav_x1 = tooldock2_pcav_x0 + 7*mm;
tooldock2_pcav_y0 = tooldock_park.y - 9*mm; // 18 long (v1 pad was 12)
tooldock2_pcav_y1 = tooldock_park.y + 9*mm;
tooldock2_pcup_wall = 1.6*mm;               // cup y walls
tooldock2_pcup_x0 = tooldock_bucket_x0 + 0.15*mm;  // outboard cup face
tooldock2_pcup_x1 = tooldock2_pcav_x1 + 1.2*mm;
tooldock2_pwin_clr = 0.3*mm;                // wall window clearance (y)
// rigid rim at the v1 lip height; cast nominal top = v1 pad top
tooldock2_prim_top = tooldock_pad_lip_z;             // -64.7
tooldock2_pcast_t = 5.5*mm;                 // nominal cast thickness
tooldock2_pcav_floor = tooldock_pad_top - tooldock2_pcast_t;  // -67.8
// bar body: inboard of the bucket wall's inner face, uniform bottom
tooldock2_pbar_x0 = tooldock_bucket_x0 + tooldock_wall + 0.3*mm;
tooldock2_pbar_h = 7*mm;
tooldock2_pbar_bot = tooldock2_prim_top - tooldock2_pbar_h;   // -71.7
// the cup body that stands in the wall window, and the window under
// it. The cup floor is 1.0 thick out there (it is a mould floor that
// also bridges the cavity on the upside-down print; the 0.4 the old lip
// had let a floor dimple punch through). The window floor accounts for
// the FULL downward shim travel (tray on the bare seats = 1.2 below
// nominal) plus 0.2
tooldock2_plip_bot = tooldock2_pcav_floor - 1.0*mm;  // -68.8
tooldock2_pwin_z0 = tooldock2_plip_bot - 0.2*mm
    - tooldock2_stack_nom;                           // -70.2
// feet: one per end, widened so the clamp magnet pocket fits, with the
// wiper carrier's boss/magnet spacing turned 90 degrees (along y)
tooldock2_pfoot_l = 16*mm;                  // y extent per foot
tooldock2_pfoot_x1 = tooldock2_pbar_x0 + 8.7*mm;
tooldock2_pbar_y0 = tooldock2_pcav_y0 - tooldock2_pcup_wall
    - tooldock2_pfoot_l;
tooldock2_pbar_y1 = tooldock2_pcav_y1 + tooldock2_pcup_wall
    + tooldock2_pfoot_l;
tooldock2_pfoot_cy = [
    tooldock2_pbar_y0 + tooldock2_pfoot_l/2,
    tooldock2_pbar_y1 - tooldock2_pfoot_l/2,
];
tooldock2_pfoot_cx = (tooldock2_pbar_x0 + tooldock2_pfoot_x1)/2;
// boss toward the cup, magnet away from it; both bosses sit 1mm off the
// foot centerline on the SAME x side, so the bar cannot be mounted
// rotated 180 degrees (flipped, the bosses miss their pockets by 2mm --
// flipped mounting would park the nozzle beside the cast, not on it)
tooldock2_pboss_dy = [4.5*mm, -4.5*mm];     // per foot, toward the cup
tooldock2_pboss_dx = 1*mm;
tooldock2_pmag_dy = [-3.5*mm, 3.5*mm];
// pad seats: shallower eave than the wiper (the magnet pocket needs the
// width), same seat mechanism otherwise
tooldock2_peave = 0.6*mm;
tooldock2_pseat_w = tooldock2_pfoot_x1 - tooldock2_pbar_x0
    - 2*tooldock2_peave;                    // 7.5
tooldock2_pseat_l = tooldock2_pfoot_l - 2*tooldock2_peave;
tooldock2_pseat_top = tooldock2_pbar_bot - tooldock2_stack_nom;

// purge point, recomputed: the open window between the pad cup and the
// wiper bar end
tooldock2_purge_x = (tooldock2_pcup_x1 + tooldock_bar_x0 - 1*mm)/2;
tooldock2_purge_window = tooldock_bar_x0 - 1*mm - tooldock2_pcup_x1;

// 7. everything stands clear of the purge fall line: the wiper tower
//    base flare (v1's yokes passed 0.5; the window is narrower now that
//    the tray is wider than the v1 pedestal, so 1.2 is the floor) and
//    the pad cup on the other side
tooldock2_assert_fall = assert(
    tooldock2_purge_window >= 4*mm
    && min(tooldock2_tower_cx) - tooldock2_seat_l/2 - 2
        >= tooldock2_purge_x + 1.2*mm
    && tooldock2_purge_x - tooldock2_pcup_x1 >= 3*mm);
// 8. pad geometry chain: rigid rim below the sweep plane, nominal cast
//    top clears the duct line (v1 pad rule), nozzle patch margins kept,
//    boss-to-magnet web, magnet fits the seat, wall window floor stays
//    2 above the mount magnet pockets, cup outboard wall is printable,
//    solid floor under the cast, and web over the boss pockets in the
//    feet
tooldock2_assert_pad = assert(
    tooldock2_prim_top <= tooldock_rim_z - 0.2*mm + 0.001
    && tooldock2_pcav_floor + tooldock2_pcast_t
        <= tooldock_park.z + tooldock_sweep_clearance - 1*mm + 0.001
    && tooldock_park.x - tooldock2_pcav_x0 >= 2*mm
    && tooldock2_pcav_x1 - tooldock_park.x >= 2*mm
    && (tooldock2_pboss_dy[0] - tooldock2_pmag_dy[0])
        - tooldock2_pocket_d/2 - tooldock2_mag_d/2 >= 1.2*mm
    && tooldock2_mag_d <= tooldock2_pseat_w - 1*mm
    && tooldock2_pwin_z0 >= tooldock_mag_z + tooldock_mag_d/2 + 2*mm
    && tooldock2_pcav_x0 - tooldock2_pcup_x0 >= 0.9*mm
    && tooldock2_pcav_floor - tooldock2_pbar_bot >= 3*mm
    && tooldock2_pbar_h - tooldock2_pocket_depth >= 1.6*mm);

// -- drop-in dovetail mount ----------------------------------------------
// v2 interface change (2026-09-02): TWO SHORT VERTICAL DOVETAILS. Each
// is a groove cut down into the backer face -- open at the top, closed
// at the bottom -- plus a matching rib on the bucket wall's inboard
// face. The bucket drops straight onto the chassis and the ribs bottom
// out on the groove floors. Removal is a straight lift (rib length plus
// clearance, ~12) and out. No slide, no tilt, no threading. The groove
// mouths funnel 2.5 per side in y over the top 2.5, the rib noses
// taper 45 degrees, so the drop self-aligns from ~3.5 off in y; x is
// guided by the wall sliding down the backer face.
//
// Why not a hook (tried first, same day): a hook that LOCKS against
// pull-off needs a downward tooth on the bucket, and every version of
// that tooth prints as a mid-air island on the upright bucket. Moving
// the tooth to the chassis puts the pocket into the 2.5 wall, which
// cannot hold a locked profile (and the pad-carrier feet block
// thickening the wall from the cavity side). A sloped rail without a
// tooth only holds by gravity, ~1.3 N here -- the magnets would have
// been the structure, which is what the test print already had.
//
// Loads: the flanks lock x (pull-off) and y (front/back bumps) with a
// 2.3 undercut per flank (45 degrees) against 0.35 clearance; v1 had
// 0.375 against 0.2, which is no lock once print slop is counted. Each
// flank is a 2.3 x 2.3 wedge of backer, ~10 long, four in total:
// pull-off puts them in PLA shear at kN scale, and the rib neck (6 wide
// at the mouth) is in plain tension. The groove floors take the
// weight; the wall bottom bears on the backer face as before. The one
// free motion is straight lift -- the removal gesture -- guarded by
// gravity and the three magnet pairs; bumps do not lift. The x-lock
// engages after ~0.5 of outward travel (clearance over the flank's
// x-projection); the magnets hold the wall seated inside that, so they
// are now the pose preload, not the structure.
//
// Printing: the groove is a horizontal channel in the standing chassis
// print. The dovetail angle is measured from the depth axis, which is
// horizontal on that print, so the channel's UPPER flank is an
// overhang at exactly the dovetail angle: 45 degrees prints; the 25
// degrees first tried would have sagged into the clearance. The funnel
// is 45 degrees for the same reason. The rib is a plain vertical rib
// on the upright bucket with a 45-degree nose. The grooves only REMOVE
// chassis material, so the machine envelope is untouched, and the ribs
// sit inside the backer's footprint.
tooldock2_dt_cy = [-55*mm, -11*mm];      // groove/rib centres (y)
tooldock2_dt_w = 7.0*mm;                 // groove mouth width (y)
tooldock2_dt_depth = 2.3*mm;             // groove depth into the backer
tooldock2_dt_angle = 45;                 // flank angle from the depth axis
tooldock2_dt_clr = 0.35*mm;              // rib clearance, all around
tooldock2_dt_z0 = -76*mm;                // groove floor = rib bottom
tooldock2_dt_z1 = tooldock_rim_z - 1.5*mm;   // rib top, under the rim
tooldock2_dt_flare = 2.5*mm;             // groove-top funnel, per side (y)
tooldock2_dt_flare_h = 2.5*mm;           // funnel height below the rim
tooldock2_dt_nose = 1.0*mm;              // rib-bottom 45-degree lead-in
tooldock2_dt_under = tooldock2_dt_depth * tan(tooldock2_dt_angle); // 2.3

tooldock2_assert_dt = assert(
    tooldock_backer_x1 - tooldock_backer_x0 - tooldock2_dt_depth
        >= 3*mm                                          // backer web
    && tooldock2_dt_under - tooldock2_dt_clr >= 0.6*mm   // real lock
    && tooldock2_dt_z1 <= tooldock_rim_z - 1.0*mm        // under the rim
    && tooldock2_dt_z0 >= tooldock_mag_z + tooldock_mag_d/2 + 0.8*mm
    && tooldock2_dt_cy[0] + tooldock2_dt_w/2 + tooldock2_dt_under
        <= tooldock2_pcav_y0 - tooldock2_pcup_wall
           - tooldock2_pwin_clr - 0.7*mm                  // wall window
    && tooldock2_dt_cy[1] - tooldock2_dt_w/2 - tooldock2_dt_under
        >= tooldock2_pcav_y1 + tooldock2_pcup_wall
           + tooldock2_pwin_clr + 0.7*mm
    && tooldock2_dt_cy[0] - tooldock2_dt_w/2 - tooldock2_dt_under
        >= tooldock_bucket_y0 + tooldock_bucket_r + 0.5*mm  // flat band
    && tooldock2_dt_cy[1] + tooldock2_dt_w/2 + tooldock2_dt_under
        <= tooldock_bucket_y1 - tooldock_bucket_r - 0.5*mm);
