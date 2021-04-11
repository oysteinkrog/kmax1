
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

module part_female()
{
    difference()
    {
        union()
        {
            tx(-71.48)
            import("DragChainFemale.stl");

            cubea(size=[10, 20, 2], align=YZ);
        }
        ty(10)
        spread(Y*6.35/2, dist=1)
        cylindera(d=2.7, h=100, orient=Z);
    }

}


module part_male()
{
    difference()
    {
        union()
        {
            tx(-11.48)
            import("DragChainMale_fixed.stl", convexity=10);

            cubea(size=[10, 20, 2], align=YZ);
        }
        ty(10)
        spread(Y*6.35/2, dist=1)
        cylindera(d=2.7, h=100, orient=Z);
    }

}
part_male();
