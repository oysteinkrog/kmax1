include <MCAD/stepper.scad>
//include <MCAD/motors.scad>

include <config.scad>
include <thing_libutils/system.scad>;
include <thing_libutils/units.scad>;
include <thing_libutils/gears-data.scad>
include <thing_libutils/bearing-linear-data.scad>
include <thing_libutils/misc.scad>;
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


// Bondtech 5mm drive gear
extruder_drivegear_type = "Bondtech";
extruder_drivegear_d_outer = 9.5*mm;
extruder_drivegear_d_inner = 7.35*mm;
extruder_drivegear_h = 13.95*mm;
extruder_drivegear_drivepath_offset=3*mm;
extruder_drivegear_bearing_thread = ThreadM3;
extruder_drivegear_bearing_h = extruder_drivegear_h;
extruder_drivegear_bearing_d = extruder_drivegear_d_outer;
extruder_drivegear_bearing_id = 3*mm;
extruder_drivegear_bearing_bolt_h = 20*mm;

// MK8 drive gear
//extruder_drivegear_type = "MK8";
//extruder_drivegear_d_outer = 9*mm;
//extruder_drivegear_d_inner = 7.45*mm;
//extruder_drivegear_h = 11*mm;
//extruder_drivegear_drivepath_offset = extruder_drivegear_h-7.85*mm;
//extruder_drivegear_bearing = bearing_MR83;
//extruder_drivegear_bearing_thread = ThreadM3;
//extruder_drivegear_bearing_h = extruder_drivegear_bearing.z;
//extruder_drivegear_bearing_d = extruder_drivegear_bearing.y;
//extruder_drivegear_bearing_id = extruder_drivegear_bearing.x;
//extruder_drivegear_bearing_bolt_h = extruder_drivegear_bearing_h+4*mm;

// MK7 drive gear
//extruder_drivegear_type = "MK7";
//extruder_drivegear_d_outer = 12.65*mm;
//extruder_drivegear_d_inner = 11.5*mm;
//extruder_drivegear_h = 11*mm;

xaxis_endstop_SN04_pos = [-xaxis_carriage_top_width/2,0,xaxis_end_wz/2] + v_z(xaxis_endstop_size_SN04)/2;

gear_80t_48P =[
[GearMod, spurgear_M_from_DP(48)],
[GearTeeth, 80]
];

gear_17t_48P =[
[GearMod, spurgear_M_from_DP(48)],
[GearTeeth, 17]
];

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


//extruder_gear_small = gear_13t_mod05;
//extruder_gear_big = gear_60t_mod05;

extruder_gear_small = [
    [GearMod, spurgear_M_from_DP(48)],
    [GearTeeth, 19]
];

extruder_gear_big = [
    [GearMod, spurgear_M_from_DP(48)],
    [GearTeeth, 66]
];

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
extruder_a_bearing_offset = [0,-.5*mm,0];
extruder_a_h = 16*mm;
extruder_a_base_h=extruder_a_bearing[2]-extruder_a_bearing_offset.y+1*mm;

extruder_b_bearing = bearing_MR105;
extruder_b_mount_dia = 9*mm;

// from E3D V6 heatsink drawing
// http://wiki.e3d-online.com/wiki/File:DRAWING-V6-175-SINK.png
// each entry == dia + h
hotend_d_h=[[16*mm,3.7*mm],[12*mm,6*mm],[16*mm,3*mm]];
hotend_outer_size_xy=max(vec_i(hotend_d_h,0));
hotend_outer_size_h=max(vec_i(hotend_d_h,1))+5*mm;

// if bondtech, less bite but each side bites
extruder_filament_bite = extruder_drivegear_type == "Bondtech" ? .4*mm : .4*mm;

// drivegear relative to extruder B
extruder_b_drivegear_offset =
    - Y*(12.5*mm)
    - Y*(hotend_outer_size_xy/2)
;

// offset between drivegear and filament path
extruder_filapath_drivegear_offset =
    + X*(extruder_drivegear_d_inner/2)
    + X*(filament_d/2)
    - X*(extruder_filament_bite)
;

extruder_b_bearing_offset = extruder_b_drivegear_offset
    - Y*(extruder_drivegear_h/2)
    - Y*(extruder_b_bearing[2]/2)
    - Y*(2*mm)
;

// drivegear relative to extruder C
extruder_c_drivegear_offset =
    N
    + Y*(hotend_outer_size_xy/2)
;

// filament path relative to extruder B
extruder_b_filapath_offset =
    + extruder_b_drivegear_offset
    + extruder_filapath_drivegear_offset
;
// filament path relative to extruder C
extruder_c_filapath_offset =
    + extruder_c_drivegear_offset
    + extruder_filapath_drivegear_offset
;

extruder_b_w = extruder_drivegear_d_outer+15*mm;

extruder_b_mount_thick = 5*mm;

/*extruder_carriage_sensormount_offset=[35,-7,-41];*/
//extruder_carriage_sensormount_offset=[-25,-7,-47];
extruder_carriage_sensormount_offset=[extruder_b_filapath_offset.x + 28*mm,0,-47.5*mm];
extruder_carriage_sensormount_conn=[extruder_carriage_sensormount_offset,Y];

sensormount_conn = [N,Y];

extruder_motor_mount_angle = 0-180;

// dist between gear and motor
extruder_gear_motor_dist = .5*mm;
extruder_motor_gear_offset_angle = 90;
extruder_motor_offset_x = cos(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_offset_z = sin(extruder_motor_gear_offset_angle) * extruder_gears_distance;
extruder_motor_holedist = lookup(NemaDistanceBetweenMountingHoles, extruder_motor);

extruder_a_mount_offsets = [for(x=[-1,1]) for(z=[-1,1])
[x*(extruder_motor_holedist/2+4*mm),0,z*extruder_motor_holedist/2]+[x*5,0,z<0?-5.2*mm:z*4]
];

extruder_gear_big_offset=[-extruder_motor_offset_x,0,extruder_motor_offset_z];

// extruder mount offset, relative to X carriage
extruder_offset = [0, 0, 22*mm];

// extruder a offset relative to extruder
extruder_offset_a = -extruder_gear_big_offset+[
    0,
    xaxis_bearing_top_OD + xaxis_carriage_bearing_offset_y + 2*mm,
    0];

// extruder b offset relative to extruder
extruder_offset_b = N;

// hotend mount relative to filament path
// basically lower it by the size of the drivegear and then a bit of a margin
// this margin is basically needed for the guidler pivot/mount
extruder_filament_path_hotend_mount_offset =
    + Z*(-extruder_drivegear_d_outer/2 - 10*mm);

// hotend mount offset relative to extruder B
extruder_b_hotend_mount_offset =
    + extruder_b_filapath_offset
    + extruder_filament_path_hotend_mount_offset;


extruder_b_thick=
    - extruder_b_hotend_mount_offset.y
    - extruder_offset_b.y
    + hotend_outer_size_xy/2
;

extruder_c_thickness = extruder_b_bearing[2]+5*mm;

hotend_clamp_screw_l = 40*mm;
//hotend_clamp_screw_l = extruder_b_thick+extruder_c_thickness + 5*mm;

// extruder c offset relative to extruder
extruder_offset_c =
    + extruder_offset_b
    - Y*extruder_b_thick
 ;

// hotend mount offset relative to extruder C
extruder_c_hotend_mount_offset =
    + extruder_c_filapath_offset
    + extruder_filament_path_hotend_mount_offset;
;

extruder_c_bearing_offset = extruder_offset_c;

// shaft from big gear to hobbed gear
extruder_shaft_d = 5*mm;
extruder_shaft_len_b = -extruder_b_bearing_offset.y;
extruder_shaft_len = extruder_shaft_len_b+extruder_a_h+extruder_offset_a[1];

echo("Extruder B main shaft length: ", extruder_shaft_len);

extruder_hotend_clamp_nut = NutHexM3;
extruder_hotend_clamp_thread = ThreadM3;

// as per E3D spec
hotend_height = 63*mm;
//hotend_height = 60.55*mm;

extruder_b_hotend_mount_conn = [extruder_b_hotend_mount_offset, -Z];

hotend_conn = [N, -Z];

extruder_ptfe_tube_d = 4.2*mm;
extruder_filaguide_d = extruder_ptfe_tube_d + 3*mm;

guidler_screw_thread = ThreadM3;
guidler_screw_nut = NutKnurlM3_5_42;;
guidler_screw_thread_dia= lookup(ThreadSize, guidler_screw_thread);

guidler_mount_d = guidler_screw_thread_dia+5*mm;
guidler_drivegear_offset =
     Y * (extruder_drivegear_type=="Bondtech" ?extruder_drivegear_drivepath_offset + 1*mm : 0)
;

guidler_bolt_mount_d = extruder_drivegear_bearing_id+3*mm;

guidler_w = max(hotend_outer_size_xy, extruder_drivegear_bearing_bolt_h + 4*mm);
guidler_d = extruder_drivegear_bearing_id/2+3*mm;

guidler_screw_distance = 10;

house_guidler_screw_h = guidler_screw_thread_dia+10*mm;

house_guidler_screw_h = guidler_screw_thread_dia+10*mm;

guidler_mount_off =
    + X*(extruder_drivegear_bearing_d/2)
    + X*1*mm
    - Z*(extruder_drivegear_bearing_d/2 + guidler_mount_d/2)
    + guidler_drivegear_offset
    ;

extruder_b_guidler_mount_off =
    + extruder_b_filapath_offset
    + Y*(guidler_w/2)
    + guidler_mount_off
    + X*(extruder_drivegear_bearing_d/2)
    // does guidler bearing/drivgear bite or not? (is it a bearing or a drivegear??)
    - (extruder_drivegear_type == "Bondtech" ? X*(extruder_filament_bite) : X*(filament_d/2))
    // to allow guidler to allow some pressure
    - X*.1*mm
    - Z*.1*mm
;

extruder_b_guidler_screw_offset_h = 15*mm + guidler_screw_thread_dia -6*mm;
extruder_b_guidler_screw_offset_x = -4*mm;

extruder_guidler_screw_offset =
    + guidler_drivegear_offset
    + Z*15*mm
    + X*4*mm
    ;

extruder_b_guidler_screw_offset =
    + extruder_b_guidler_mount_off
    + extruder_guidler_screw_offset
    - Y*guidler_mount_off.y
    - Y*guidler_w/2
    - X*guidler_d
    - X*5*mm
    ;

extruder_b_guidler_mount_w = - extruder_b_guidler_mount_off.y;

extruder_b_pushfit_nut = NutKnurlM5_5_42;
extruder_b_pushfit_nut_thread = get(NutThread, extruder_b_pushfit_nut);

sensor_diameter=12;
sensormount_thickness=xaxis_carriage_thickness;
sensormount_size = [17.8*mm,sensormount_thickness,15*mm];

sensormount_sensor_hotend_offset = v_xy(extruder_carriage_sensormount_offset) - v_y(sensormount_size/2) - v_xy(extruder_b_hotend_mount_offset);
echo("Sensor mount offset", sensormount_sensor_hotend_offset);

// extruder guidler mount point
extruder_conn_guidler = [ extruder_b_guidler_mount_off, -Y];

// guidler connection point
guidler_conn = [ Y*(guidler_w/2)+guidler_mount_off, -Y];
//extruder_guidler_roll = 0;
extruder_guidler_roll = -1-90;

alpha = 0.7;
/*alpha = 1;*/
color_xcarriage = [0.3,0.5,0.3, alpha];
color_hotend = [0.8,0.4,0.4, alpha];
color_extruder = [0.2,0.6,0.9, alpha];
color_guidler = [0.4,0.5,0.8, alpha];
color_filament = [0,0,0, alpha];

hotend_tolerance=.2*mm;
bearing_pressfit_tolerance = .2*mm;

// hotend clamp screws distance from center
hotend_clamp_thread = ThreadM3;
hotend_clamp_nut = NutKnurlM3_5_42;

hotend_clamp_screw_dia = lookup(ThreadSize, hotend_clamp_thread);
hotend_clamp_screws_dist = hotend_d_h[1][1] + 1.2*hotend_clamp_screw_dia + 2.0*mm;
hotend_clamp_pad = 0;
hotend_clamp_thickness = hotend_outer_size_xy/3;
hotend_clamp_w = [
2*(hotend_clamp_screws_dist + hotend_clamp_screw_dia + hotend_clamp_pad),
2*(hotend_clamp_screws_dist + hotend_clamp_screw_dia + hotend_clamp_pad),
];
hotend_clamp_height = hotend_d_h[1][1];

// relative to hotend mount
extruder_b_hotend_clamp_offset =
    + Z*(-hotend_outer_size_h/2)
;

extruder_c_hotend_clamp_offset =
    + Z*(-hotend_outer_size_h/2)
    - Y*(hotend_outer_size_xy/2)
;


// extruder b mount offsets onto extruder
extruder_b_mount_offsets=[
    // position the mount offsets so that we reuse the hotend clamp screws
    +X*hotend_clamp_screws_dist+v_xz(extruder_b_hotend_mount_offset+extruder_b_hotend_clamp_offset),
    -X*hotend_clamp_screws_dist+v_xz(extruder_b_hotend_mount_offset+extruder_b_hotend_clamp_offset),
    -X*(3*mm)+Z*(20*mm)
];

// extruder c mount offsets onto extruder b
extruder_c_mount_offsets=[
    // position the mount offsets so that we reuse the hotend clamp screws
    +X*hotend_clamp_screws_dist+v_xz(extruder_c_hotend_mount_offset+extruder_c_hotend_clamp_offset),
    -X*hotend_clamp_screws_dist+v_xz(extruder_c_hotend_mount_offset+extruder_c_hotend_clamp_offset),
    -X*(3*mm)+Z*(20*mm)
];


guidler_extra_h_up=extruder_drivegear_bearing_d/2+hotend_clamp_screw_dia/2;

x_carriage_w = max(xaxis_carriage_top_width, xaxis_carriage_bottom_width, sqrt(2)*(extruder_motor_holedist+extruder_b_mount_dia));
