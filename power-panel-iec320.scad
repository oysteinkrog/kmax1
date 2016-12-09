include <config.scad>
include <thing_libutils/units.scad>
include <thing_libutils/shapes.scad>
include <thing_libutils/metric-screw.scad>
//use <boxes.scad>
use <MCAD/boxes.scad>
/*use <GoblinOne.scad>*/

//3 Pin IEC320 C14 Inlet Male Power Socket w Fuse Switch 10A 250V
//http://www.amazon.com/IEC320-Inlet-Power-Socket-Switch/dp/B00511QVVK
//http://www.uxcell.com/pin-iec320-c14-inlet-male-power-socket-fuse-switch-10a-250v-p-104813.html

//position X/Y offset
IEC_offset = [0,0];

//mounting width of IEC switch/fuse/socket
IEC_width = 47*mm + .2*mm;

//mounting height of IEC switch/fuse/socket
IEC_height = 27*mm + .2*mm;

//mounting flange depth of IEC switch/fuse/socket
IEC_depth = 1;

//width of flange before returning to full panel thickness
IEC_rim = 1.5;

//side length of the corner cutout on the IEC connect end of the power module
IEC_corner = 6-.5;

power_panel_iec320_width = IEC_width+15*mm;
power_panel_iec320_height = main_lower_dist_z+extrusion_size;
power_panel_iec320_thickness = 3.8*mm;

//horizontal distance from edge to mounting hole
power_panel_iec320_hole_hedge_w = 5*mm;

//vertical spacing of mounting holes
power_panel_iec320_hole_vspace = main_lower_dist_z;

mount_hole_d = 5*mm;

module power_panel_iec320(align=[0,0,0], orient=[0,0,-1])
{
    s = [power_panel_iec320_width,power_panel_iec320_height,power_panel_iec320_thickness];
    size_align(size=s, align=align, orient=orient, orient_ref=[0,0,-1])
    rotate ([180,0,180])
    difference ()
    {
        //power_panel_iec320
        rcubea(size=s);

        //socket
        translate(v = [IEC_offset[0], IEC_offset[1], 0])
        difference()
        {
            union()
            {
                translate(v = [0, 0, -IEC_depth])
                cube(size = [IEC_width,IEC_height+IEC_rim*2,power_panel_iec320_thickness], center = true );
                cube(size = [IEC_width,IEC_height,power_panel_iec320_thickness+1], center = true);
            }
            for (x = [-1:2:1])
            translate([(IEC_width-IEC_corner)/2, x*(IEC_height-IEC_corner)/2,0])

            rotate([0,0,x*45])
            translate([0,-(IEC_width+IEC_height)/2,-(power_panel_iec320_thickness+1)/2])
            cube([IEC_width+IEC_height,IEC_width+IEC_height,power_panel_iec320_thickness+1]);
        }

        // extrusion mounting holes
        for (x = [-1,1])
        for (y = [-1,1])
        translate([x*(power_panel_iec320_width/2-power_panel_iec320_hole_hedge_w-mount_hole_d/2), y*(power_panel_iec320_hole_vspace/2), -s[2]/2])
        screw_cut(nut=extrusion_nut, screw_l=12*mm, with_nut=false, align=[0,0,1], orient=[0,0,1]);
    }
}

module part_power_panel_iec320()
{
    power_panel_iec320() ;
}

if(false)
{
    power_panel_iec320() ;
}

