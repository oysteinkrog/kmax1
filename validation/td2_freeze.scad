// Shell-freeze probe: v2 bucket must equal the v1 bucket everywhere
// outside the wiper-support region (towers/yokes, bar-end relief, the
// old jack bores). mode=1: v2 minus v1; mode=2: v1 minus v2. Both must
// be EMPTY (or zero-volume residue) after masking that region out.
include <../config.scad>
use <../tool-dock.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

mode = 1;

module mask()
{
    // covers v1 yokes+flares+bores+relief and v2 towers+relief
    translate([89, -41, -103]) cube([45, 19, 43]);
    // pad zone, intentionally changed by the cast-RTV tray redesign:
    // v1 pocket/undercut/pry/pedestal out, wall recess + pad towers
    // in. Starts at the bucket outboard face so the dovetail rib
    // (x < bucket_x0) stays fully proven.
    translate([tooldock_bucket_x0, -55, -99.5])
    cube([89.3 - tooldock_bucket_x0, 51, 39.5]);
}

difference()
{
    union()
    {
        $show_vit = false;
        if(mode==1) tooldock2_bucket(); else tooldock_bucket();
    }
    union()
    {
        $show_vit = false;
        if(mode==1) tooldock_bucket(); else tooldock2_bucket();
    }
    mask();
}
