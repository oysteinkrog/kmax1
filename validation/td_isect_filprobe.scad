include <../config.scad>
include <../x-carriage.h>
include <../printbed.h>
use <../main.scad>
intersection()
{
    union()
    {
        $tooldock_hide = true;
        $show_vit = false;
        main();
    }
    translate([-184.85, -10, 10]) cube([8,8,90], center=true);
}
