use <thing_libutils/shapes.scad>
include <thing_libutils/system.scad>
include <thing_libutils/transforms.scad>
include <printbed.h>

module printbed(align=U, orient=Z)
{
    {
        /*size_align(size=printbed_size, align=align, orient=orient)*/
        /*cubea(printbed_size);*/

        s=[254*mm,230*mm,1.5*mm];
        size_align(size=s, align=align, orient=orient)
        {
            t(-s/2)
            material(Mat_BlackPaint)
            import("stl/heatbedmk52.stl");

            tz(1.1*mm)
            material(Mat_PrintBed)
            {
                sheet_size=[250*mm, 240*mm, 1*mm];
                ty(-4*mm)
                cubea(sheet_size, align=Z);
            }
        }

    }
}
