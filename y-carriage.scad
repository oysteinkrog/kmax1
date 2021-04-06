include <y-carriage.h>
include <thing_libutils/shapes.scad>

module yaxis_carriage()
{
    tz(14.5)
    material(Mat_PrintCarriage)
    import("stl/Original_Prusa_i3_MK3_platform.stl");

    /*material(Mat_PrintCarriage)*/
    /*{*/
        /*// y axis carriage plate "arms"*/
        /*for(x=[-1,1])*/
        /*for(y=[-1,1])*/
        /*hull()*/
        /*{*/
            /*translate([x*yaxis_carriage_size[0]/2, y*yaxis_carriage_size[1]/2, 0])*/
            /*cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);*/

            /*translate([x*(yaxis_carriage_size[0]/2-yaxis_carriage_size_inner[0]/2), y*(yaxis_carriage_size[1]/2-yaxis_carriage_size_inner[1]/2*mm), 0])*/
            /*cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);*/
        /*}*/

        /*// y axis carriage plate*/
        /*hull()*/
        /*for(x=[-1,1])*/
        /*for(y=[-1,1])*/
        /*{*/
            /*translate([x*(yaxis_carriage_size[0]/2-yaxis_carriage_size_inner[0]/2), y*(yaxis_carriage_size[1]/2-yaxis_carriage_size_inner[1]/2*mm), 0])*/
            /*cylindera(d=10*mm, h=yaxis_carriage_size[2], align=[-x,-y,1]);*/
        /*}*/
    /*}*/
}
