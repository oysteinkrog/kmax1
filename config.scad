include <MCAD/stepper.scad>
include <bearings.scad>
include <screws.scad>
include <thing_libutils/metric-thread.scad>
include <thing_libutils/metric-hexnut.scad>
include <thing_libutils/misc.scad>

e=0.01;

// resolution of any round object (segment length)
fnr                         = 0.4;

extrusion_height            = 0.4*mm;

// width of a single wall, should match your slicer settings
extrusion_width             = 0.4*mm;

// how many lines should a normal wall have (i.e. 0.6(extrusion_width)*6(normal_wall_factor)= 3.6mm wall width)
normal_wall_factor          = 3;

thick_wall_factor           = 4;

// diameter of your filament.
filament_d                  = 1.75*mm;
filament_r                  = filament_d/2;

// enable preview model (faster openscad)
preview_mode=true;

main_width = 300*mm;
main_depth = 420*mm;
main_height = 400*mm;
main_upper_width = 420*mm;

extrusion_color = [0.5,0.5,0.5];
extrusion_size = 20*mm;
extrusion_thread = ThreadM5;
extrusion_thread_dia = lookup(ThreadSize, extrusion_thread);
extrusion_nut = MHexNutM5;
extrusion_nut_dia = lookup(MHexNutWidthMax, extrusion_nut);

main_lower_dist_z= 80*mm;
main_upper_dist_y= 160*mm;

gantry_connector_thickness = 5;

rod_fit_tolerance=1.01;

ziptie_thickness = 4;
ziptie_width = 4;
ziptie_bearing_distance=2;

xaxis_rod_distance = 60*mm;
xaxis_rod_d = 9.975*mm;
xaxis_rod_l = 500*mm;
xaxis_bearing=bearing_igus_rj4jp_01_10;
xaxis_pulley_d = 12.2;
xaxis_belt_width = 6*mm;

xaxis_carriage_bearing_offset_z = ziptie_thickness/2;
xaxis_carriage_beltpath_offset = xaxis_carriage_bearing_offset_z+xaxis_bearing[1]/2;

yaxis_rod_distance = 170*mm;
yaxis_rod_d = 11.975*mm;
yaxis_rod_l = 500*mm;
yaxis_bearing=bearing_igus_rj4jp_01_12;
yaxis_bearing_distance_y = 7*cm;

yaxis_motor = dict_replace(Nema17, NemaFrontAxleLength, 21.5*mm);

// 2GT2 20T pulley
yaxis_pulley_d = 18;
ymotor_mount_thickness = 5;
ymotor_mount_thickness_h = 5;
yaxis_motor_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_motor_offset_z = -5*mm;
yaxis_belt_path_offset_x = -yaxis_pulley_d/2;
yaxis_belt_path_offset_z = yaxis_motor_offset_z + 15*mm;

yaxis_idler_mount_thickness = 5;
yaxis_idler_pulley_tight_len = 20*mm;
yaxis_idler_pulley_offset_y = yaxis_idler_mount_thickness + yaxis_pulley_d/2 + yaxis_idler_pulley_tight_len;
yaxis_idler_offset_x = lookup(NemaSideSize,yaxis_motor)/2+ymotor_mount_thickness;
yaxis_idler_offset_z = 10*mm;
yaxis_idler_pulley_h = 8.65*mm;

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

zaxis_motor_offset_z = 10*mm;
zmotor_mount_thickness = 5;
zmotor_mount_thickness_h = 10;
zmotor_mount_motor_offset=5;

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
