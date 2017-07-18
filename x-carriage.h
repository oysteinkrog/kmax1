include <MCAD/stepper.scad>
//include <MCAD/motors.scad>

include <config.scad>
include <thing_libutils/system.scad>;
include <thing_libutils/units.scad>;
include <thing_libutils/gears-data.scad>
include <thing_libutils/bearing-linear-data.scad>
include <x-end.h>

use <thing_libutils/gears.scad>

xaxis_bearing_top_ID = get(LinearBearingInnerDiameter, xaxis_bearing_top);
xaxis_bearing_top_OD = get(LinearBearingOuterDiameter, xaxis_bearing_top);
xaxis_bearing_top_L = get(LinearBearingLength, xaxis_bearing_top);

xaxis_bearing_bottom_ID = get(LinearBearingInnerDiameter, xaxis_bearing_bottom);
xaxis_bearing_bottom_OD = get(LinearBearingOuterDiameter, xaxis_bearing_bottom);
xaxis_bearing_bottom_L = get(LinearBearingLength, xaxis_bearing_bottom);

xaxis_carriage_bearing_distance = xaxis_rod_distance;
xaxis_carriage_padding = 1*mm;
xaxis_carriage_mount_distance = xaxis_carriage_bearing_distance+5*mm;
xaxis_carriage_mount_offset_z = 0*mm;
xaxis_carriage_teeth_height=xaxis_belt_width*1.5;
xaxis_carriage_mount_screws = ThreadM4;

xaxis_carriage_top_width = xaxis_carriage_bearing_distance*(xaxis_bearings_top-1) + xaxis_carriage_padding*2;
xaxis_carriage_bottom_width = xaxis_bearing_bottom_L*xaxis_bearings_bottom + xaxis_carriage_bearing_distance*(xaxis_bearings_bottom-1) + 2*xaxis_carriage_padding;

xaxis_carriage_conn = [[0, -xaxis_bearing_top_OD/2 - xaxis_carriage_bearing_offset_y,0], N];

xaxis_carriage_beltfasten_w = 11*mm;
xaxis_carriage_beltfasten_h = 4*mm;
xaxis_carriage_beltfasten_dist = xaxis_carriage_beltfasten_w/2+2*mm;

xaxis_carriage_thickness = xaxis_bearing_top_OD/2 + xaxis_carriage_bearing_offset_y;

// MK8 drive gear
extruder_drivegear_d_outer = 9*mm;
extruder_drivegear_d_inner = 7.45*mm;
extruder_drivegear_h = 11*mm;
extruder_drivegear_drivepath_offset = extruder_drivegear_h-7.85*mm;
extruder_drivegear_drivepath_h = 3.45;

// MK7 drive gear
//extruder_drivegear_d_outer = 12.65*mm;
//extruder_drivegear_d_inner = 11.5*mm;
//extruder_drivegear_h = 11*mm;

xaxis_endstop_SN04_pos = [-xaxis_carriage_top_width/2,0,xaxis_end_wz/2] + v_z(xaxis_endstop_size_SN04)/2;

gear_60t_mod05 =[
[GearMod, 0.5],
[GearTeeth, 60]
];

gear_13t_mod05 =[
[GearMod, 0.5],
[GearTeeth, 13]
];

gear_20t_mod05 =[
[GearMod, 0.5],
[GearTeeth, 20]
];

extruder_gear_small = gear_13t_mod05;
extruder_gear_big = gear_60t_mod05;

extruder_gears_distance=calc_gears_center_distance(extruder_gear_small,extruder_gear_big)+.1*mm;
extruder_gear_small_PD = calc_gear_PD(extruder_gear_small);
extruder_gear_big_PD = calc_gear_PD(extruder_gear_big);
extruder_gear_big_OD = calc_gear_OD(extruder_gear_big);

extruder_gear_big_h = [3.85*mm, 5*mm];
extruder_motor = dict_replace_multiple(Nema17,
        [
        [NemaLengthMedium, 11.75*mm],
        [NemaFrontAxleLength, 5*mm],
        ]);

extruder_a_bearing = bearing_MR125;
extruder_a_bearing_offset_y = [0,-.5*mm,0];
extruder_a_h = 16*mm;
extruder_a_base_h=extruder_a_bearing[2]-extruder_a_bearing_offset_y.y+1*mm;

extruder_b_bearing = bearing_MR105;

// from E3D V6 heatsink drawing
// http://wiki.e3d-online.com/wiki/File:DRAWING-V6-175-SINK.png
// each entry == dia + h
hotend_d_h=[[16*mm,3.7*mm],[12*mm,6*mm],[16*mm,3*mm]];
hotend_outer_size_xy=max(vec_i(hotend_d_h,0))+5*mm;
hotend_outer_size_h=max(vec_i(hotend_d_h,1))+5*mm;

extruder_filament_bite = .5*mm;

extruder_b_drivegear_offset =
    - Y*(hotend_outer_size_xy/2 + 9.5*mm)
;

extruder_b_filapath_offset = extruder_b_drivegear_offset
    + X*(extruder_drivegear_d_inner/2)
    - X*(extruder_filament_bite)
    + X*(filament_d/2)
;

extruder_b_bearing_offset = extruder_b_drivegear_offset
    - Y*(extruder_drivegear_h/2)
    - Y*(extruder_b_bearing[2]/2)
    - Y*(2*mm)
;

extruder_b_w = extruder_drivegear_d_outer+15*mm;

extruder_b_mount_thick = 5*mm;

extruder_b_mount_offsets=[
    [-14*mm,0,-13*mm],
    [20*mm,0,-13*mm],
    [0,0,35*mm-15*mm]
];

/*extruder_b_sensormount_offset=[35,-7,-41];*/
//extruder_b_sensormount_offset=[-25,-7,-47];
extruder_b_sensormount_offset=[-25,-7,-47];
extruder_b_sensormount_conn=[extruder_b_sensormount_offset,Y];

sensormount_conn = [N,Y];

extruder_motor_mount_angle = 0-180;

// dist between gear and motor
extruder_gear_motor_dist = .5*mm;
extruder_motor_gear_offset_angle = 90;
extruder_motor_offset_x = cos(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_offset_z = sin(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_holedist = lookup(NemaDistanceBetweenMountingHoles, extruder_motor);

extruder_a_mount_offsets = [for(x=[-1,1]) for(z=[-1,1])
[x*extruder_motor_holedist/2,1,z*extruder_motor_holedist/2]+[x*5,0,z<0?0:z*9]
];

extruder_gear_big_offset=[-extruder_motor_offset_x,0,extruder_motor_offset_z];

extruder_offset = [0, 0, 22.5*mm];
extruder_offset_a = -extruder_gear_big_offset+[
    0,
    xaxis_bearing_top_OD + xaxis_carriage_bearing_offset_y + 2*mm,
    0];

extruder_offset_b = [0,0,0];

// shaft from big gear to hobbed gear
extruder_shaft_d = 5*mm;
extruder_shaft_len_b = abs(extruder_b_filapath_offset[1])+extruder_drivegear_h/2+extruder_b_bearing[2];
extruder_shaft_len = extruder_shaft_len_b+extruder_a_h+extruder_offset_a[1];

echo("Extruder B main shaft length: ", extruder_shaft_len);

extruder_hotend_clamp_nut = NutHexM3;
extruder_hotend_clamp_thread = ThreadM3;


// as per E3D spec
hotend_height = 63*mm;
hotend_mount_offset = extruder_b_filapath_offset + Z*(-extruder_drivegear_d_outer/2 - 10*mm);
hotend_mount_conn = [hotend_mount_offset, Z];
hotend_conn = [[0,21.3,0], Y];

guidler_bearing = bearing_MR83;
guidler_screws_thread = ThreadM3;
guidler_screws_nut = NutHexM3;
guidler_screws_thread_dia= lookup(ThreadSize, guidler_screws_thread);

// length of the guidler bearing bolt/screw
guidler_mount_w=max(6*mm, guidler_bearing[2]);
guidler_mount_d=8*mm;
guidler_bolt_mount_d = guidler_bearing[0]+3*mm;
guidler_bolt_h=guidler_bearing[2]+4*mm;

guidler_w=max(guidler_mount_w+7*mm, guidler_bearing[2]*2.8);
guidler_d=5;
guidler_h=7;

guidler_screws_thread = ThreadM3;
guidler_screws_nut = NutHexM3;
guidler_screws_thread_dia= lookup(ThreadSize, guidler_screws_thread);
guidler_screws_distance=4*mm;
guidler_screws_mount_d = guidler_screws_thread_dia*2+5*mm;

guidler_srew_distance = 10;
guidler_mount_off =
    + X*(guidler_bearing[1]/1.8)
    - Z*(guidler_bearing[1]/2 + guidler_mount_d/2);

extruder_guidler_mount_off =
    + extruder_b_filapath_offset
    + guidler_mount_off
    + X*(guidler_bearing[1]/2)
    - X*(extruder_filament_bite)
    + X*(filament_d/2)
;

house_guidler_screw_h = guidler_screws_thread_dia+10*mm;

extruder_b_guidler_screw_offset_h = 15*mm + guidler_screws_thread_dia -6*mm;
extruder_b_guidler_screw_offset_x = -4*mm;

extruder_b_mount_thickness = 10*mm;
extruder_b_mount_dia = 10*mm;

x_carriage_w = max(xaxis_carriage_top_width, xaxis_carriage_bottom_width, sqrt(2)*(extruder_motor_holedist+extruder_b_mount_dia));

sensor_diameter=12;
sensormount_thickness=5;
sensormount_OD_cut = 0*mm;
sensormount_OD = sensor_diameter+2*sensormount_thickness;
sensormount_h_ = 10;
sensormount_size = [sensormount_OD,sensormount_OD-2*sensormount_OD_cut,sensormount_h_];

sensormount_sensor_hotend_offset = v_xy(extruder_b_sensormount_offset) - v_y(sensormount_size/2) - v_xy(hotend_mount_offset);
echo("Sensor mount offset", sensormount_sensor_hotend_offset);

// extruder guidler mount point
extruder_conn_guidler = [ extruder_guidler_mount_off, Y];

// guidler connection point
extruder_guidler_conn_mount = [ guidler_mount_off,  Y];
extruder_guidler_roll = 0;

alpha = 0.7;
/*alpha = 1;*/
color_xcarriage = [0.3,0.5,0.3, alpha];
color_hotend = [0.8,0.4,0.4, alpha];
color_extruder = [0.2,0.6,0.9, alpha];
color_guidler = [0.4,0.5,0.8, alpha];
color_filament = [0,0,0, alpha];

// which side does hotend slide in (x-axis, i.e. -1 is left, 1 is right)
hotend_tolerance=1.05*mm;

// hotend clamp screws distance from center
hotend_clamp_thread = ThreadM3;
hotend_clamp_nut = NutKnurlM3_5_42;

hotend_clamp_screw_dia = lookup(ThreadSize, hotend_clamp_thread);
hotend_clamp_screws_dist = hotend_d_h[1][1] + 1.2*hotend_clamp_screw_dia;
hotend_clamp_pad = 0;
hotend_clamp_thickness = hotend_outer_size_xy/3;
hotend_clamp_w = [
2*(hotend_clamp_screws_dist + hotend_clamp_screw_dia + hotend_clamp_pad),
2*(hotend_clamp_screws_dist - hotend_clamp_screw_dia/2),
];
hotend_clamp_height = hotend_d_h[1][1];

// relative to hotend mount
hotend_clamp_offset = Y*(-hotend_outer_size_xy/2 - 2*mm) + Z*(-hotend_d_h[0][1]-hotend_d_h[1][1]/2);//abs(extruder_b_filapath_offset.y)+extruder_drivegear_h/2+extruder_b_bearing[2]+4*mm;

guidler_extra_h_up=guidler_bearing[1]/2+hotend_clamp_screw_dia/2;
