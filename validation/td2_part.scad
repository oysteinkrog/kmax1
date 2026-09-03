// v2 part export wrapper: -D which=1 chassis_left, 2 bucket_left,
// 3 carrier, 4 shim set, 5 padcarrier_left, 6 padcarrier_right
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>
$show_vit = false;
which = 1;
if(which==1) part_tooldock2_chassis_left();
if(which==2) part_tooldock2_bucket_left();
if(which==3) part_tooldock2_carrier();
if(which==4) part_tooldock2_shims();
if(which==5) part_tooldock2_padcarrier_left();
if(which==6) part_tooldock2_padcarrier_right();
