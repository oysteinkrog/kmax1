// Mate probe: v2 bucket vs v2 chassis around the drop-in dovetails.
// mode=0 seated: expect EMPTY except zero-volume face contact where
//   the rib noses sit on the groove floors (CGAL may emit a few
//   degenerate facets with ~0 volume; real volume is a defect).
// mode=1 pull-off, bucket +x 1.2: expect a REAL intersection -- the
//   rib flanks lock against the groove flanks (the lock engages after
//   ~0.5 of travel, see the .h).
// mode=2 y-bump, bucket +y 0.8: expect a REAL intersection (flanks).
// mode=3 lift 3: expect EMPTY (straight lift is the removal path).
// mode=4 lift 12.5 then out 3: expect EMPTY (ribs clear of the grooves).
// mode=5 pull-off inside the clearance, +x 0.3: expect EMPTY (the
//   documented free travel before the lock engages).
// The v1 bucket no longer mates the v2 chassis (interface changed
// 2026-09-02, see the .h mount section).
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

mode = 0;

dx = (mode==1) ? 1.2 : (mode==4) ? 3 : (mode==5) ? 0.3 : 0;
dy = (mode==2) ? 0.8 : 0;
dz = (mode==3) ? 3 : (mode==4) ? 12.5 : 0;

intersection()
{
    union() { $show_vit = false; tooldock2_chassis(); }
    translate([dx, dy, dz])
    union() { $show_vit = false; tooldock2_bucket(); }
}
