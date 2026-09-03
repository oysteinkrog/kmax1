include <../config.scad>
use <../x-end.scad>

// slab probe: x-end bottom face outline (bottom face at -xaxis_end_wz/2 = -42.4875)
intersection()
{
    xaxis_end(with_motor=true, beltpath_index=0);
    translate([-50, -60, -42.4875]) cube([120, 120, 0.3]);
}
