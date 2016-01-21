use <thing_libutils/utils-shapes.scad>;
use <thing_libutils/utils-misc.scad>;
use <thing_libutils/utils-attach.scad>;

blowfan40();
module blowfan40()
{
    //translate([27,25,0])
    //rotate([0,0,90])
    //%import("scroll.stl");
    h = 19.5;
    d = 40.5;
    difference()
    {
        union()
        {
            translate([d/2,d/2,0])
                cylindera(d=d,h=h);

            //cube([51.5,52.5,15]);
            translate([d,d,0])
                cubea([20,30,h],[-1,-1,1]);

            translate([(d-35)-3,d-3,h-13.2])
                cylindera(d=6.3,h=13.2);
            translate([d-3,(d-35)-3,h-13.2])
                cylindera(d=6.3,h=13.2);
            translate([(d-35)-3,(d-35)-3,h-13.2])
                cylindera(d=6.3,h=13.2);
        }

        translate([41.5/2,40.5/2,-9])
            difference()
            {
                cylindera(d=27.4,h=h, center=false);
                cylindera(d=22,h=h, center=false);
            }

        translate([(d-35)-3,d-3,-1])
            cylindera(d=3,h=13.2*2);
        translate([d-3,(d-35)-3,-1])
            cylindera(d=3,h=13.2*2);
        translate([(d-35)-3,(d-35)-3,-1])
            cylindera(d=3,h=13.2*2);
    }
}

module blowfan50(h=15)
{
    //translate([27,25,0])
    //rotate([0,0,90])
    //%import("scroll.stl");
    difference()
    {
        union()
        {
            translate([50.5/2,51.5/2,0])
                cylinder(d=50.5,h=15, center=false);

            //cube([51.5,52.5,15]);
            translate([51.5+1,52.5,0])
                cubea([30,19.6,15],[-1,-1,1]);         

            translate([7,47.8,0])
                cylinder(d=9.3,h=h);
            translate([44.5,5,0])
                cylinder(d=9.3,h=h);            
        }

        translate([54/2,50/2,-9])
            difference()
            {
                cylinder(d=32.5,h=15, center=false);
                cylinder(d=23,h=15, center=false);
            }

        translate([7,47.8,-0])
            cylinder(d=4.3,h=h);
        translate([44.5,5,0])
            cylinder(d=4.3,h=h);
    }    
}

