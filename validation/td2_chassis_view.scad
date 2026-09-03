// v2 chassis alone (shell redesign). flip=1 shows it in print
// orientation (plate on the bed, cells opening upward).
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

$show_vit = true;
flip = 0;

if(flip)
    part_tooldock2_chassis_left();
else
    tooldock2_chassis();
