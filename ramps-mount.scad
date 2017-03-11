include <thing_libutils\shapes.scad>
include <config.scad>

holes_thread = ThreadM3;
holes_size = lookup(ThreadSize, holes_thread);
holes_size_outer = holes_size*2.2;
holes_support = 11;

// this data from "Arduino Dimensions and Hole Patterns"
holes=[
    //BL
    [0,0],
    //TL
    [1.3,48.2],
    //BR
    [81.5,0],
    //TR
    [74.9,48.2]
];

module arduino_mount()
{
    translate([70.5,0,0]) {
        translate([0,-30,0]) {
            bar_clamp();
            cube([10,76,1.3]);
        }
        translate([6.8,-18,0])rotate([0,0,3.5])cube([3,63,holes_support*.65]);
    }

    translate([-3,0,0]) {
        translate([0,-30,0]) {
            bar_clamp();
            cube([10,76,1.3]);
        }
        translate([6.8,-18,0])rotate([0,0,3.5])cube([3,63,holes_support*.65]);
    }


    difference() {
        translate([5,-17,0])cube([66,2,20]);
        for (z = [0:8]) {
            translate([(z*7)+10,-14,15])rotate([90,0,0])cylinder(r=1.5,h=5, $fn=10);
        }
    }

    arduino_holes();


    $fn=100;

    linear_extrude(height=1.3)
        barbell(holes[3], holes[0], 6, 6, 240, 240);

    linear_extrude(height=1.3) 
        barbell(holes[2], holes[1], 6, 6, 240, 240);
}

#cube_from_to(holes[2], holes[1], [0,5,5]);

module cube_from_to(startpos=N, endpos=N, size=[10,10,10])
{
    s = [startpos[0]-endpos[0], startpos[1]-endpos[1], startpos[2]-endpos[2]];
    s_ = [s[0]==undef?size[0]:s[0]+size[0],s[1]==undef?size[1]:s[1]+size[1],s[2]==undef?size[2]:s[2]+size[2]];
    s__ = [abs(s_[0]), abs(s_[1]), abs(s_[2])];
    echo(s__);

    translate([startpos[0]==undef?0:startpos[0],startpos[1]==undef?0:startpos[1],startpos[2]==undef?0:startpos[2]])
    #cubea(size=s__);
}

module arduino_holes() 
{
    difference()
    {
        union()
        {
            for(hole=holes)
            {
                translate([hole[0],hole[1],0])
                    cylindera(d=holes_size_outer,h=holes_support, align=Z);
            }
        }
        for(hole=holes)
        {
            translate([hole[0],hole[1],-.1])
                fncylinder(d=holes_size, h=holes_support+.2, align=Z);
        }
    }

}

module bar_clamp() {

    translate([0,7,7])rotate([0,90,0])difference() {
        translate([-3,0,5])cube([20,16,10], true);

        union() {
            cylinder(10, r=4, $fn=40);
            translate([-7,0,5])cube([13,7,10], center=true);
        }
        // Hole
        translate([-8,8,5])rotate([90,0,0])cylinder(16, r=1.5, $fn=20);
    }
}


module barbell (x1,x2,r1,r2,r3,r4) 
{
    x3=triangulate (x1,x2,r1+r3,r2+r3);
    x4=triangulate (x2,x1,r2+r4,r1+r4);
    render()
        difference ()
        {
            union()
            {
                translate(x1)
                    circle (r=r1);
                translate(x2)
                    circle(r=r2);
                polygon (points=[x1,x3,x2,x4]);
            }
            translate(x3)
                circle(r=r3,$fa=5);
            translate(x4)
                circle(r=r4,$fa=5);
        }
}

function triangulate (point1, point2, length1, length2) = 
point1 + 
length1*rotated(
        atan2(point2[1]-point1[1],point2[0]-point1[0])+
        angle(distance(point1,point2),length1,length2));

function distance(point1,point2)=
sqrt((point1[0]-point2[0])*(point1[0]-point2[0])+
        (point1[1]-point2[1])*(point1[1]-point2[1]));

function angle(a,b,c) = acos((a*a+b*b-c*c)/(2*a*b)); 

function rotated(a)=[cos(a),sin(a),0];


arduino_mount();
