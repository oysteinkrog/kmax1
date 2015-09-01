e=0.01;

// resolution of any round object (segment length)
fnr                         = 0.4;

// width of a single wall, should match your slicer settings
extrusion_width             = 0.6;

// how many lines should a normal wall have (i.e. 0.6(extrusion_width)*6(normal_wall_factor)= 3.6mm wall width)
normal_wall_factor          = 4;

thick_wall_factor           = 6;

// diameter of your filament.
filament_d                  = 1.75;
filament_r                  = filament_d/2;

// [screw_r, screw_head_r, screw_head_h, name]
screw_m3    = [1.6,     2.84,   3,      "screw M3"];
// [nut_r(biggest side), nut_d(smalles side), nut_h, name]
nut_m3      = [3.04,    5.5,    2.4,    "nut M3 DIN 934/ISO 4033/ISO 8673"];
// [washer_r, washer_h, washer_inner_r, name]
washer_m3   = [3.5,     0.5,    1.6,    "washer M3 DIN 125 A/ISO 7089"];

// inner, outer, thickness
bearing_608 = [8,22,7];
bearing_626 = [8,19,6];
bearing_625 = [5,16,5];
bearing_608 = [8,22,7];
bearing_MR128 = [8,12,3.5];

