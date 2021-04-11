
include <../../thing_libutils/shapes.scad>

// high quality etc
is_build = true;

// minimum size of a fragment
// resolution of any round object (segment length)
// Because of this variable very small circles have a smaller number of fragments than specified using $fa. 
// The default value is 2.
$fs = is_build ? 0.5 : 1;

// minimum angle for a fragment.
// The default value is 12 (i.e. 30 fragments for a full circle)
$fa = is_build ? 4 : 16;
$preview_mode = is_build ? false : true;

tx(-91.48)
ty(5.51)
tz(-37)
import("RuRAMPS4D_Case.stl");

for(x=[-1,1]*(68.9))
for(y=[-1,1]*74)
tx(x) ty(y)
difference()
{
    rcubea(size=[17,15,3], align=Z);
    tx(sign(x)*2)
    cylindera(h=1000, d=3.5);
}
