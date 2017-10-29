use <thing_libutils/shapes.scad>;
use <thing_libutils/transforms.scad>;
include <fan_5015S.h>

//optional 5015S fan_5015S fan mockup
module fan_5015S(part)
{
    if(part==undef)
    {
        difference()
        {
            fan_5015S(part="pos");
            fan_5015S(part="neg");
        }
    }
    else if(part=="pos")
    material(Mat_PlasticBlack)
    {
        hull()
        {
            //throat
            tx(-51*mm/2)
            ty(51.3*mm/2)
            cubea([51*mm/2, 20*mm, fan_5015S_Z], align=X-Y);

            tx(1.5*mm)
            ty(1.5*mm)
            cylindera(d=49*mm, h=fan_5015S_Z);
        }

        union()
        {
            hull()
            {
                for(pos=fan_5015S_screwpos)
                translate([pos[0], pos[1], 0])
                cylindera(d=7*mm, h=fan_5015S_Z);
            }
        }
    }
    else if(part=="neg")
    {
        tx(-51*mm/2)
        ty(51.3*mm/2)
        tx(-.1)
        ty(-2.4*mm/2)
        cubea([10*mm, 17.6*mm, 12.2], align=X-Y);

        tz(3*mm)
        difference()
        {
            cylindera(d=31*mm, h=fan_5015S_Z+.1);
            cylindera(d=26*mm, h=fan_5015S_Z+.1);
        }

        union()
        {
            for(pos=fan_5015S_screwpos)
            translate([pos[0], pos[1], 0])
            cylindera(d=3.3*mm, h=fan_5015S_Z+.1);
        }
    }
    else if(part=="conn")
    {
        color("red")
        connector(fan_5015S_conn_flowoutput);
    }
}


// fan_5015S mounting plate
module fan_5015S_bracket(thickness=2.2*mm)
{
    linear_extrude(thickness)
    projection(cut=false)
    fan_5015S();
}


use <thing_libutils/attach.scad>
if(false)
/*attach([[0,0,0], X], fan_5015S_conn_flowoutput)*/
{
    fan_5015S();
    connector(fan_5015S_conn_flowoutput);

}

if(false)
translate([0,0,-10])
fan_5015S_bracket();
