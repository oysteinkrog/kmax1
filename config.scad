include <bearings.scad>
include <screws.scad>

e=0.01;

// resolution of any round object (segment length)
fnr                         = 0.4;

// width of a single wall, should match your slicer settings
extrusion_width             = 0.4;

// how many lines should a normal wall have (i.e. 0.6(extrusion_width)*6(normal_wall_factor)= 3.6mm wall width)
normal_wall_factor          = 3;

thick_wall_factor           = 4;

// diameter of your filament.
filament_d                  = 1.75;
filament_r                  = filament_d/2;

main_width = 340;
main_depth = 420;
main_height = 400;
main_upper_width = 420;
extrusion_size = 20;

main_lower_dist_z= 80;
main_upper_dist_y= 160;

xaxis_rod_distance = 45;
xaxis_rod_d = 9.975;
xaxis_rod_l = 500;
xaxis_bearing=bearing_igus_rj4jp_01_10;

yaxis_rod_distance = 170;
yaxis_rod_d = 11.975;
yaxis_rod_l = 500;
yaxis_bearing=bearing_igus_rj4jp_01_12;
ycarriage_size=[220,220,5];

zaxis_rod_d = 11.975;
zaxis_rod_l = 500;
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

zaxis_motor_offset_z = 10;

// place z rod on edge of motor
zaxis_rod_screw_distance_x = lookup(NemaSideSize,zaxis_motor);

xaxis_zaxis_distance_y = xaxis_rod_d/2 + zaxis_bearing[1]/2;

