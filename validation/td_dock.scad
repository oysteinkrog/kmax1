// assembled dock, left side, with vitamins (blade, pad, screws, magnets)
include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../tool-dock.scad>
include <../tool-dock.h>

$show_vit = true;
tool_dock(beltpath_index=0);
