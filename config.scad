include <MCAD/stepper.scad>
include <screws.scad>
include <pulley.scad>
include <thing_libutils/bearing_data.scad>
include <thing_libutils/metric-thread-data.scad>
include <thing_libutils/metric-hexnut-data.scad>
include <thing_libutils/misc.scad>

e=0.01;

// minimum size of a fragment
// resolution of any round object (segment length)
// Because of this variable very small circles have a smaller number of fragments than specified using $fa. 
// The default value is 2.
$fs = 2;

// minimum angle for a fragment.
// The default value is 12 (i.e. 30 fragments for a full circle)
$fa = 12;

//hq
if(false)
{
    $fs= 0.5;
    $fa = 4;
}

// enable preview model (faster openscad)
preview_mode=false;

extrusion_height            = 0.4*mm;

// width of a single wall, should match your slicer settings
extrusion_width             = 0.4*mm;

// how many lines should a normal wall have (i.e. 0.6(extrusion_width)*6(normal_wall_factor)= 3.6mm wall width)
normal_wall_factor          = 3;

thick_wall_factor           = 4;

// diameter of your filament.
filament_d                  = 1.75*mm;
filament_r                  = filament_d/2;


main_width = 340*mm;
main_depth = 420*mm;
main_height = 400*mm;
main_upper_width = 420*mm;

extrusion_size = 20*mm;
extrusion_thread = ThreadM5;
extrusion_thread_dia = lookup(ThreadSize, extrusion_thread);
extrusion_nut = MHexNutM5;
extrusion_nut_dia = lookup(MHexNutWidthMax, extrusion_nut);

main_lower_dist_z= 80*mm;
main_upper_dist_y= 160*mm;

gantry_connector_thickness = 5;

rod_fit_tolerance=1.01;

ziptie_type = [1.1*mm, 2.4*mm];
ziptie_thickness = ziptie_type[0];
ziptie_width = ziptie_type[1]+0.6*mm;
ziptie_bearing_distance=3*mm;

xaxis_rod_distance = 60*mm;
xaxis_rod_d = 9.975*mm;
xaxis_rod_l = 500*mm;
xaxis_rod_offset_x = 20*mm;
xaxis_bearing=bearing_igus_rj4jp_01_10;

xaxis_pulley = pulley_2GT_20T;
xaxis_pulley_inner_d = xaxis_pulley[2];
xaxis_idler_pulley = pulley_2GT_20T_idler;
xaxis_idler_pulley_inner_d = xaxis_idler_pulley[2];
xaxis_idler_pulley_outer_d = xaxis_idler_pulley[3];

xaxis_belt_width = 6*mm;
xaxis_beltpath_height = xaxis_pulley_inner_d+5*mm;
xaxis_beltpath_width = max(xaxis_belt_width+3*mm, xaxis_pulley[0]+2*mm);

xaxis_carriage_bearing_offset_y = ziptie_thickness+3*mm;
xaxis_carriage_beltpath_offset = xaxis_carriage_bearing_offset_y+xaxis_bearing[1]/2;

xaxis_motor = dict_replace(Nema17, NemaFrontAxleLength, 22*mm);

yaxis_rod_distance = 170*mm;
yaxis_rod_d = 11.975*mm;
yaxis_rod_l = 500*mm;
yaxis_bearing=bearing_igus_rj4jp_01_12;
yaxis_bearing_distance_y = 7*cm;

yaxis_motor = dict_replace(Nema17, NemaFrontAxleLength, 22*mm);

yaxis_pulley = pulley_2GT_20T;
yaxis_pulley_inner_d = yaxis_pulley[2];
ymotor_mount_thickness = 5;
ymotor_mount_thickness_h = 5;
yaxis_motor_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_motor_offset_z = -5*mm;
yaxis_belt_path_offset_x = -yaxis_pulley_inner_d/2;
yaxis_belt_path_offset_z = yaxis_motor_offset_z + 15*mm;

yaxis_idler_pulley = pulley_2GT_20T_idler;
yaxis_idler_pulley_inner_d = yaxis_idler_pulley[2];
yaxis_idler_pulley_outer_d = yaxis_idler_pulley[3];
yaxis_idler_pulley_h = yaxis_idler_pulley[0];
yaxis_idler_mount_thickness = 5;
yaxis_idler_pulley_tight_len = 20*mm;
yaxis_idler_pulley_offset_y = yaxis_idler_mount_thickness + yaxis_pulley_inner_d/2 + yaxis_idler_pulley_tight_len;
yaxis_idler_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_idler_offset_z = 10*mm;

yaxis_carriage_size=[220*mm,220*mm,5*mm];

zaxis_rod_d = 11.975*mm;
zaxis_rod_l = 500*mm;
zaxis_bearing=bearing_igus_rj4jp_01_12;

// Nema17 motor w/340mm long 8*mm leadscrew
zaxis_motor = dict_replace_multiple(Nema17,
        [
        [NemaAxleDiameter, 8*mm],
        [NemaFrontAxleLength, 340*mm],
        ]);

zmotor_w = lookup(NemaSideSize,zaxis_motor);
zmotor_h = lookup(NemaLengthLong,zaxis_motor);

// inner_d, outer_d, thread, outer_h, full_h
zaxis_nut = [20*mm, 36*mm, 8*mm, 5*mm, 23*mm];

zaxis_motor_offset_z = 10*mm;
zmotor_mount_thickness = 5;
zmotor_mount_thickness_h = 10;
zmotor_mount_motor_offset=5;

zmotor_w = lookup(NemaSideSize,zaxis_motor);
zmotor_h = lookup(NemaLengthLong,zaxis_motor);
zmotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
zmotor_mount_width = zmotor_w+zmotor_mount_thickness*2 + zmotor_mount_thread_dia*8;
zmotor_mount_h = main_lower_dist_z+extrusion_size+zaxis_motor_offset_z;

zmotor_mount_clamp_dist = zaxis_rod_d*2.5;
zmotor_mount_clamp_thread = ThreadM4;
zmotor_mount_clamp_nut = MHexNutM4;
zmotor_mount_clamp_thread_dia = lookup(ThreadSize, zmotor_mount_clamp_thread);
zmotor_mount_clamp_nut_dia = lookup(MHexNutWidthMin, zmotor_mount_clamp_nut);
zmotor_mount_clamp_nut_thick = lookup(MHexNutThickness, zmotor_mount_clamp_nut);
zmotor_mount_clamp_width = zmotor_mount_clamp_dist+zmotor_mount_clamp_thread_dia*3;

xaxis_zaxis_distance_y = 1*mm + xaxis_rod_d/2 + zaxis_bearing[1]/2;

zaxis_nut_mount_outer = zaxis_nut[1]/2 + zaxis_rod_d/2 + 1*mm;

// offset between Z motor screw and z rod
// place z rod as close as possible (depends on z nut and also motor etc)
zaxis_rod_screw_distance_x = max(zaxis_nut_mount_outer, zaxis_rod_d/2 + zmotor_w/2 + 1*mm);

// z rod offset from lower extrusion (outer)
zmotor_mount_rod_offset_x = zmotor_w/2+zaxis_rod_screw_distance_x+zmotor_mount_motor_offset;

// z screw offset from lower extrusion (outer)
zmotor_mount_screw_offset_x = zmotor_mount_rod_offset_x - zaxis_rod_screw_distance_x ;

color_extrusion = "DimGray";
color_rods = "CornflowerBlue";
color_part = "DarkRed";
color_gantry_connectors = "OliveDrab";

// GT2 
// there is bunch of GT2 belts with different tooth-to-tooth distance
// this one is most common in reprap world
// adjust to your needs.
belt_width = 6.5;
belt_tooth_distance = 2;
belt_tooth_ratio = 0.5;
belt_thickness = 0.8;

//T2.5
//belt_tooth_distance = 2.5;
//belt_tooth_ratio = 0.5;

//T5 (strongly discouraged)
//belt_tooth_distance = 5;
//belt_tooth_ratio = 0.75;

//HTD3
//belt_tooth_distance = 3;
//belt_tooth_ratio = 0.75;

//MXL
//belt_tooth_distance = 2.032;
//belt_tooth_ratio = 0.64;
