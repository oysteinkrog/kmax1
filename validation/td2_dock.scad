// v2 dock assembled preview: chassis (plate + riser + wing + backer) +
// bucket (frozen shell, wiper towers, pad towers, wall recess) +
// wiper carrier + pad carrier, both at the nominal shim stack, with
// vits (blade, cast pad, shims, magnets, screws).
// Toggles: -D '$show_vit=false' for bare plastic, or set the part
// flags below to isolate pieces.
include <../config.scad>
use <../tool-dock-v2.scad>
include <../tool-dock-v2.h>

$show_vit = true;

show_chassis = true;
show_bucket = true;
show_carrier = true;
show_padcarrier = true;

if(show_chassis)    tooldock2_chassis();
if(show_bucket)     tooldock2_bucket();
if(show_carrier)    tooldock2_carrier();
if(show_padcarrier) tooldock2_padcarrier();
