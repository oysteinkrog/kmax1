include <MCAD/stepper.scad>
include <bearings.scad>
include <screws.scad>
include <thing_libutils/metric-thread.scad>

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

main_width = 340*mm;
main_depth = 420*mm;
main_height = 400*mm;
main_upper_width = 420*mm;

extrusion_color = [0.5,0.5,0.5];
extrusion_size = 20*mm;
extrusion_thread = ThreadM5;

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
ycarriage_size=[220*mm,220*mm,5*mm];

zaxis_rod_d = 11.975*mm;
zaxis_rod_l = 500*mm;
zaxis_bearing=bearing_igus_rj4jp_01_12;

// NEMA17 motor w/340mm leadscrew
zaxis_motor = [
                [NemaModel, 17],
                [NemaLengthShort, 33*mm],
                [NemaLengthMedium, 39*mm],
                [NemaLengthLong, 47*mm],
                [NemaSideSize, 42.20*mm], 
                [NemaDistanceBetweenMountingHoles, 31.04*mm], 
                [NemaMountingHoleDiameter, 4*mm], 
                [NemaMountingHoleDepth, 4.5*mm], 
                [NemaMountingHoleLip, -1*mm], 
                [NemaMountingHoleCutoutRadius, 0*mm], 
                [NemaEdgeRoundingRadius, 7*mm], 
                [NemaRoundExtrusionDiameter, 22*mm], 
                [NemaRoundExtrusionHeight, 1.9*mm], 
                [NemaAxleDiameter, 8*mm], 
                // custom front axle length
                [NemaFrontAxleLength, 340*mm], 
                [NemaBackAxleLength, 15*mm],
                [NemaAxleFlatDepth, 0.5*mm],
                [NemaAxleFlatLengthFront, 15*mm],
                [NemaAxleFlatLengthBack, 14*mm]
         ];

zaxis_motor_offset_z = 10*mm;

// inner_d, outer_d, thread
zaxis_nut = [20*mm, 36.5*mm, 8*mm];

zaxis_nut_mount_outer = zaxis_nut[1]/2 + zaxis_bearing[1]/2 + 3;

// place z rod on edge of motor
/*zaxis_rod_screw_distance_x = max(zaxis_nut_mount_outer, zaxis_rod_d/2 + lookup(NemaSideSize,zaxis_motor)/2);*/
zaxis_rod_screw_distance_x = zaxis_nut_mount_outer;

xaxis_zaxis_distance_y = xaxis_rod_d/2 + zaxis_bearing[1]/2;


zmotor_w = lookup(NemaSideSize,zaxis_motor);
zmotor_mount_thickness = 5;
zmotor_mount_thickness_h = 10;
zmotor_mount_thread_dia = lookup(ThreadSize, extrusion_thread);
zmotor_mount_width = zmotor_w+zmotor_mount_thickness*2 + zmotor_mount_thread_dia*8;
zmotor_mount_h = main_lower_dist_z+extrusion_size+zaxis_motor_offset_z;
zmotor_mount_motor_offset=5;
zmotor_mount_rod_offset_x = zmotor_w/2+zaxis_rod_screw_distance_x+zmotor_mount_motor_offset;

zmotor_mount_clamp_dist = zaxis_rod_d*2.5;
zmotor_mount_clamp_thread = ThreadM4;
zmotor_mount_clamp_thread_dia = lookup(ThreadSize, zmotor_mount_clamp_thread);
zmotor_mount_clamp_nut = MHexNutM4;
zmotor_mount_clamp_nut_dia = lookup(MHexNutWidthMin, zmotor_mount_clamp_nut);
zmotor_mount_clamp_nut_thick = lookup(MHexNutThickness, zmotor_mount_clamp_nut);

zmotor_mount_conn_motor=[[-zmotor_mount_motor_offset, 0, 0],[0,1,0]];
zmotor_mount_clamp_width = zmotor_mount_clamp_dist+zmotor_mount_clamp_thread_dia*3;

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
