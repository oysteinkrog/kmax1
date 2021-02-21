include <thing_libutils/units.scad>
include <thing_libutils/system.scad>
include <thing_libutils/bearing_data.scad>
include <thing_libutils/pulley.scad>
include <thing_libutils/bearing-linear-data.scad>
/*include <thing_libutils/thread-data.scad>*/
include <thing_libutils/nut-data.scad>
include <thing_libutils/timing-belts-data.scad>
include <thing_libutils/stepper-data.scad>

use <thing_libutils/misc.scad>

e=0.01*mm;

// high quality etc
is_build = false;

// minimum size of a fragment
// resolution of any round object (segment length)
// Because of this variable very small circles have a smaller number of fragments than specified using $fa. 
// The default value is 2.
$fs = is_build ? 0.5 : 1;

// minimum angle for a fragment.
// The default value is 12 (i.e. 30 fragments for a full circle)
$fa = is_build ? 4 : 16;

$show_vit = is_build ? false : true;

// enable preview model (faster openscad)
$preview_mode = is_build ? false : true;


extrusion_height            = 0.4*mm;

// width of a single wall, should match your slicer settings
extrusion_width             = 0.4*mm;

// how many lines should a normal wall have (i.e. 0.6(extrusion_width)*6(normal_wall_factor)= 3.6mm wall width)
normal_wall_factor          = 3;

thick_wall_factor           = 4;

// diameter of your filament.
filament_d                  = 1.75*mm;
filament_r                  = filament_d/2;
Mat_filament = Mat_PlasticBlack;


main_width = 420*mm;
main_depth = 420*mm;
main_height = 400*mm;
main_upper_width = 500*mm;

// underneath y axis
y_plate_offset_z = -5*mm;

extrusion_size = 20*mm;
extrusion_thread = ThreadM5;
extrusion_thread_dia = lookup(ThreadSize, extrusion_thread);
extrusion_nut = NutHexM5;
extrusion_nut_dia = lookup(NutWidthMax, extrusion_nut);

extrusion_mount_thread = ThreadM4;

// for tapped ends
extrusion_end_nut = NutHexM6;

main_lower_dist_z = 80*mm;
main_upper_dist_y = 160*mm;

gantry_connector_thickness = 5;
gantry_upper_offset_y = -25;

rod_fit_tolerance=1.01;

ziptie_type = [2.5*mm, 3*mm];
ziptie_thickness = ziptie_type[0];
ziptie_width = ziptie_type[1]+0.6*mm;
ziptie_bearing_distance = 3*mm;

xaxis_rod_distance = 65*mm;
xaxis_rod_d = 9.975*mm;
xaxis_rod_l = 500*mm;
// relative to entire machine
xaxis_rod_offset_x = 0*mm;
xaxis_bearings_top=1;
xaxis_bearings_bottom=1;
xaxis_bearing_top = LinearBearingLM10L;
xaxis_bearing_bottom = LinearBearingLM10;;

xaxis_pulley = pulley_2GT_20T;
xaxis_pulley_inner_d = xaxis_pulley[2];
xaxis_pulley_outer_d = xaxis_pulley[3];
xaxis_idler_pulley = pulley_2GT_20T_idler;
xaxis_idler_pulley_inner_d = xaxis_idler_pulley[2];
xaxis_idler_pulley_outer_d = xaxis_idler_pulley[3];

xaxis_belt = TimingBelt_GT2_2;
xaxis_belt_width = 6*mm;
xaxis_beltpath_width = max(xaxis_belt_width+3*mm, xaxis_pulley[0]+2*mm);
xaxis_beltpath_z_offset_pulley = xaxis_pulley_inner_d/2;
/*xaxis_beltpath_z_offsets = [xaxis_beltpath_z_offset_pulley];*/
xaxis_beltpath_z_offsets = [-3*mm-xaxis_beltpath_z_offset_pulley, 3*mm+xaxis_beltpath_z_offset_pulley];
xaxis_beltpath_height_body = xaxis_pulley_outer_d/2+3*mm+v_sum(v_abs(xaxis_beltpath_z_offsets))+5*mm;
xaxis_beltpath_height_holders = max(xaxis_pulley_outer_d+2*mm, xaxis_pulley_inner_d+xaxis_beltpath_z_offsets[0]+3*mm);

xaxis_carriage_bearing_offset_y = ziptie_thickness+3*mm;
xaxis_carriage_beltpath_offset_y = xaxis_carriage_bearing_offset_y+get(LinearBearingOuterDiameter, xaxis_bearing_top)/2;

xaxis_motor = dict_replace(Nema17, NemaFrontAxleLength, 22*mm);
xaxis_motor_thread=ThreadM3;
xaxis_motor_nut=NutHexM3;

xaxis_endstop_type = "SWITCH";
/*xaxis_endstop_type = "SN04";*/

yaxis_rod_distance = 170*mm;
yaxis_rod_d = 11.975*mm;
yaxis_rod_l = 500*mm;
yaxis_bearing = LinearBearingLM12;
yaxis_bearing_distance_y = 7*cm;

yaxis_motor = dict_replace(Nema17, NemaFrontAxleLength, 22*mm);

yaxis_pulley = pulley_2GT_20T;
yaxis_pulley_inner_d = yaxis_pulley[2];
ymotor_mount_thickness = 5;
ymotor_mount_thickness_h = 5;
yaxis_motor_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;

yaxis_belt = TimingBelt_GT2_2;
yaxis_belt_width = 6*mm;
yaxis_belt_path_offset_x = -yaxis_pulley_inner_d/2;
yaxis_belt_path_offset_z = 5*mm;

yaxis_motor_offset_z = yaxis_belt_path_offset_z - 10*mm;

yaxis_idler_pulley = pulley_2GT_20T_idler_9mm;
yaxis_idler_pulley_inner_d = yaxis_idler_pulley[2];
yaxis_idler_pulley_outer_d = yaxis_idler_pulley[3];
yaxis_idler_pulley_h = yaxis_idler_pulley[0];
yaxis_idler_mount_thickness = 5;
yaxis_idler_pulley_tight_len = 10*mm;
yaxis_idler_pulley_offset_y = yaxis_idler_mount_thickness + yaxis_pulley_inner_d/2 + yaxis_idler_pulley_tight_len;
yaxis_idler_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_idler_offset_z = 10*mm;

yaxis_carriage_offset =
    Z*get(LinearBearingInnerDiameter, yaxis_bearing)/2;


zaxis_rod_d = 11.975*mm;
zaxis_rod_l = 500*mm;
// relative to entire machine
zaxis_rod_offset = [0,-20*mm,0];
zaxis_bearing = LinearBearingLMH12L;
zaxis_bearing_ID=get(LinearBearingInnerDiameter,zaxis_bearing);
zaxis_bearing_OD=get(LinearBearingOuterDiameter,zaxis_bearing);
zaxis_bearing_L=get(LinearBearingLength,zaxis_bearing);

// Nema17 motor w/340mm long 8*mm leadscrew
zaxis_motor = dict_replace_multiple(Nema17,
        [
        [NemaAxleDiameter, 8*mm],
        [NemaFrontAxleLength, 340*mm],
        [NemaAxleFlatDepth, 0*mm],
        ]);

zmotor_w = lookup(NemaSideSize,zaxis_motor);
zmotor_h = lookup(NemaLengthLong,zaxis_motor);

// inner_d, outer_d, thread, outer_h, full_h, screw_dist, screw_thread
zaxis_nut = [20*mm, 36*mm, 8*mm, 5*mm, 23*mm, 13.5*mm, ThreadM3];
zaxis_nut_mat = Mat_PlasticBlack;

zaxis_motor_offset_z = 10*mm;
zmotor_mount_thickness = 5;
zmotor_mount_thickness_h = 10;
zmotor_mount_motor_offset=5;

zmotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
zmotor_mount_width = zmotor_w+zmotor_mount_thickness*2 + zmotor_mount_thread_dia*8;
zmotor_mount_h = main_lower_dist_z+extrusion_size+zaxis_motor_offset_z;

zmotor_mount_clamp_dist = zaxis_rod_d*2.5;
zmotor_mount_clamp_thread = extrusion_mount_thread;
zmotor_mount_clamp_nut = NutHexM4;
zmotor_mount_clamp_thread_dia = lookup(ThreadSize, zmotor_mount_clamp_thread);
zmotor_mount_clamp_nut_dia = lookup(NutWidthMin, zmotor_mount_clamp_nut);
zmotor_mount_clamp_nut_thick = lookup(NutThickness, zmotor_mount_clamp_nut);
zmotor_mount_clamp_width = zmotor_mount_clamp_dist+zmotor_mount_clamp_thread_dia*3.5;

xaxis_zaxis_distance_y_ = max(xaxis_rod_d/2 + zaxis_bearing_OD/2, zaxis_nut[1]/2 - xaxis_rod_d/2);
xaxis_zaxis_distance_y = xaxis_zaxis_distance_y_ + ziptie_type[0]+.5*mm + 1*mm;

zaxis_nut_mount_outer = zaxis_nut[1]/2 + zaxis_rod_d/2 + 1*mm;

// offset between Z motor screw and z rod
// place z rod as close as possible (depends on z nut and also motor etc)
zaxis_rod_screw_distance_x = max(zaxis_nut_mount_outer, zaxis_rod_d/2 + zmotor_w/2 + 1*mm);

// z screw offset from lower extrusion (outer)
zmotor_mount_screw_offset_x = zmotor_w/2 + zmotor_mount_motor_offset;

// z rod offset from lower extrusion (outer)
zmotor_mount_rod_offset_x = zmotor_mount_screw_offset_x + zaxis_rod_screw_distance_x;
