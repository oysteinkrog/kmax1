include <config.scad>
include <fanduct.h>

use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/sweep.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/skin.scad>
use <thing_libutils/misc.scad>
use <thing_libutils/splines.scad>
use <thing_libutils/sweep.scad>
use <thing_libutils/transforms.scad>
use <thing_libutils/shapes.scad>
use <thing_libutils/attach.scad>
use <thing_libutils/naca_sweep.scad>
include <fan_5015S.scad>

// helper functions to work on headered-arrays (where first entry is column headers)
function nSpline_header(S, N) =
let(slice = v_slice(S,start=1))
concat(
    [S[0]],
    nSpline(slice, N)
    );

// data for duct geometry
// ss parameter is initial size of duct (e.g. for fan throat/output)
// returned data has a header row
// warning, don't set r to 0 or rendering breaks!
function gen_data(ss) = [
    [       "Tx","Ty","Tz",     "Sx",   "Sy", "Rx", "Ry",  "r"],
    [     ss.x/4, -27,  55,   ss.x/2,   ss.y,   13,    0,  .01],
    [ 2.5+ss.x/4, -25,  49, 5+ss.x/2, 1+ss.y,   13,    0,  .1 ],
    [         15, -18,  40,       11,     20,   13,    0,  .4 ],
    [         17,  -8,  20,       11,     17,   11,  -10,  .5 ],
    [         14,  -3,  10,        8,     15,    8,  -25,  .7 ],
    [         11,   0,   4,        6,     13,    0,  -45,  .8 ],
];

fanduct_data = gen_data(fanduct_throat_size_withwall);

module duct(A, fanduct_wallthick=2, N=100, d=2)
{
    // rounded bugs out when rendering if r value is 0 :/
    function shape_profile(size,r) = rounded_rectangle_profile(size=size,r=r);
    /*function shape_profile(size,r) = rectangle_profile(size);*/

    module showcontrols(V)
    {
        function gen_T(V) = 
        [
           for (i=[0:len(V)-2])
           let(R = vec3(geth(V,["Rx","Ry"],i)))
           let(T = geth(V,["Tx","Ty","Tz"],i))
           translation(T)*rotation(v_mul(R,[1,-1,1]))
        ];

        T = gen_T(A);
        for (i=[0:len(T)-1])
        let(t=T[i])
        multmatrix(t)
        color("red")
        let(S = [geth(A,"Sx",i),geth(A,"Sy",i)])
        let(r = geth(A,"r",i))
        let(r_ = [.5*r*S.x, .5*r*S.y])
        let(h=.5)
        difference()
        {
            linear_extrude(height=h,center=true)
            polygon(shape_profile(size=S+[1,1], r=r_));

            linear_extrude(height=h+.1,center=true)
            polygon(shape_profile(size=S, r=r_));

            /*torus(r=a[3], radial_width=1.5);*/
        }

        function gen_dat(V) =
           [
           for (i=[0:len(V)-2])
               let(S = geth(V,["Sx","Sy"],i))
               let(R = vec3(geth(V,["Rx","Ry"],i)))
               let(T = geth(V,["Tx","Ty","Tz"],i))
               let(dat = R_(R.x, R.y, R.z, v=to_3d(circle_profile(r=.5))))
               T_(T.x,T.y,T.z, dat)
           ];
        outer = gen_dat(nSpline_header(A,N));    // outer skin
        skin(outer, close = true, slices = true);
    }

    // generate transformed shapes
    function gen_dat(V) =
       [
       for (i=[0:len(V)-2])
           let(S = geth(V,["Sx","Sy"],i))
           let(r = [S.x*.5*geth(V,"r",i), S.y*.5*geth(V,"r",i)])
           let(R = vec3(geth(V,["Rx","Ry"],i)))
           let(T = geth(V,["Tx","Ty","Tz"],i))
           let(dat = R_(R.x, R.y, R.z, v=to_3d(shape_profile(size=S,r=r))))
           T_(T.x,T.y,T.z, dat)
       ];

    // inner skin data: modify tube diameter
    function modify_inner(S, subtract) = array_header_col_subtract(S, ["Sx", "Sy"], subtract);

    module sweepshape(V_outer,interp=true)
    {
        // inner skin is outer, but smaller size and reversed (so it will go back to start and join)
        V_inner = modify_inner(reverse_header(V_outer), fanduct_wallthick);
        if(interp)
        {
            outer = gen_dat(nSpline_header(V_outer,N));    // outer skin
            inner = gen_dat(nSpline_header(V_inner,N));    // inner skin
            sweep(concat(outer, inner), close = true, showslices = false);
            /*sweep(outer, close = true, showslices = false);*/
            /*skin(concat(outer, inner), loop=true);*/
        }
        else
        {
            outer = gen_dat(V_outer);    // outer skin
            inner = gen_dat(V_inner);    // inner skin
            sweep(concat(outer, inner), close = true, showslices = true);
        }
    }

    function mirrorshape(S, size) =
    let(cols = header_col_index(S,["Tx","Rx","Ry"]))
    concat([S[0]],
    [
        for(i=[1:len(S)-1])
        [
        for(j=[0:len(S[0])-1])
            v_contains(cols,j) ? -S[i][j] :
            S[i][j]
        ]
    ]);

    // debug experiment, mirror + join path for both duct arms
    /*A_ = mirrorshape(A);*/
    /*A__ = reverse_header(A_);*/
    /*A___ = concat_header(A__,A);*/
    /*sweepshape(A___,true);*/

    if($preview_mode)
    {
        /*tx(15)*/
        /*sweep(gen_dat(A), close = false, slices = true);*/

        /*tx(-15)*/
        showcontrols(A);
    }

    material(Mat_Plastic)
    sweepshape(A,true);
}

module mirrorcopy(axis)
{
    children();
    mirror(axis)
    children();
}

module fanduct_throat(throat_seal_h)
{
    difference()
    {
        union()
        {
            hull()
            {
                ty((fanduct_throat_size_withwall.y)/2)
                cubea([fanduct_throat_size.x,fanduct_throat_size.y,throat_seal_h]+XY*fanduct_wallthick,align=Z-Y);

                tz(seal_height)
                ty(fanduct_throat_size.y/2 - 47)
                tz(11.34/2)
                cylindera(h=fanduct_throat_size_withwall.x, d=7, orient=X);
            }

        }

        tz(-.1)
        cubea([fanduct_throat_size.x,fanduct_throat_size.y,1000],align=Z);

        seal_height = 4;
        tz(seal_height)
        {
            ty((fanduct_throat_size.y)/2)
            cubea([fanduct_throat_size.x,1000,1000],align=Z-Y, extra_size=.1*Y, extra_align=-Z);

            ty(-(fanduct_throat_size_withwall.y)/2)
            tz(-5)
            cubea([fanduct_throat_size.x,1000,1000],align=Z-Y, extra_size=.1*Y, extra_align=-Z);

            tz(-seal_height+2*mm)
            cubea([3.8,1000,1000],align=Z+Y);

            ty(fanduct_throat_size.y/2 - 47)
            tz(11.34/2)
            cylindera(h=1000, d=3.65, orient=X);
        }
    }

    ry(45)
    cubea([fanduct_wallthick/sqrt(2),fanduct_throat_size_withwall.y,fanduct_wallthick/sqrt(2)]);
}

module fanduct(part)
{
    $fn=is_build?$fn:48;

    A = fanduct_data;

    mirrorcopy(X)
    {
        duct(A=A, fanduct_wallthick=fanduct_wallthick, N=$fn, debug=true);
    }

    tx(-geth(A,"Tx",0))
    t(geth(A,["Tx","Ty","Tz"],0))
    r(geth(A,["Rx","Ry","Rz"],0))
    {
        throat_seal_h = 13*mm;

        material(Mat_Plastic)
        fanduct_throat(throat_seal_h);

        fanduct_conn_fan = [N,-Z];
        tz(2)
        attach(fanduct_conn_fan, fan_5015S_conn_flowoutput, 0)
        fan_5015S();
    }
}

module part_fanduct()
{
    ry(180)
    t(-13)
    t(-geth(fanduct_data,["Tx","Ty","Tz"],0))
    r(-geth(fanduct_data,["Rx","Ry","Rz"],0))
    difference()
    fanduct();
}

fanduct();
/*part_fanduct();*/
