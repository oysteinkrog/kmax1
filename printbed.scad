use <thing_libutils/shapes.scad>
include <thing_libutils/system.scad>
include <thing_libutils/transforms.scad>
include <printbed.h>

module printbed(align=Z, orient=Z)
{
    /*size_align(size=printbed_size, align=align, orient=orient)*/
    /*cubea(printbed_size);*/

    sheet_size=[250*mm, 240*mm, 1*mm];
    heatbed_size=[250*mm,240*mm,1*mm];
    s=[254*mm,230*mm,2*mm];
    size_align(size=s, align=align, orient=orient)
    {
        tz(-1.1*mm)
        t(-s/2)
        material(Mat_BlackPaint)
        import("stl/heatbedmk52.stl");

        material(Mat_PrintBed)
        {
            ty(-4*mm)
            cubea(sheet_size, align=-Z);
        }
    }

}

printbed();
