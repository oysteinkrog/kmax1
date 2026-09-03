// Carrier/tower fit probe: a carrier at a shim offset vs the v2
// bucket. pad=0: wiper carrier; pad=1: pad carrier (cast tray).
// drop = stack - stack_nom: -1.2 (no shims, bar on the bare seats) or
// +0.7 (design-max stack). Expect EMPTY (zero-volume face contact
// residue allowed at drop=-1.2, where the bar bottom meets the seats;
// the pad cup body keeps 0.2 over the wall window floor even there;
// the dimples must stay over the bar body: check the -1.2 volume is 0).
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

drop = -1.2;
pad = 0;

intersection()
{
    union() { $show_vit = false; tooldock2_bucket(); }
    tz(drop)
    union()
    {
        $show_vit = false;
        if(pad) tooldock2_padcarrier(); else tooldock2_carrier();
    }
}
