include <config.scad>

module pulley(h, inner_d, outer_d, bore, walls, idler=false, full_h, align=[0,0,0], orient = [0,0,1])
{
    size_align(size=[outer_d, outer_d, h], align=align, orient=orient)
    {
        difference()
        {
            union()
            {
                for(z=[-1,1])
                    translate([0,0,z*h/2])
                        fncylindera(d = outer_d, h = walls, align=[0,0,-z], orient=[0,0,1]);

                fncylindera(d = inner_d, h = h, align=[0,0,0], orient=[0,0,1]);

                if(!idler)
                {
                    translate([0,0,h-walls])
                        fncylindera(d = outer_d, h = full_h-h, align=[0,0,0], orient=[0,0,1]);
                }
            }
            fncylindera(d = bore, h = h+full_h, align=[0,0,0], orient=[0,0,1]);
        }
    }
}

module pulley_idler_2GT2_20T(align=[0,0,0], orient = [0,0,1])
{
    h = 8.65*mm;
    inner_d = 12*mm;
    outer_d = 18*mm;
    walls = 1*mm;

    pulley(inner_d = inner_d, outer_d=outer_d, bore=5*mm, h=h, walls=walls, idler=true);
}

module pulley_2GT2_20T(align=[0,0,0], orient = [0,0,1])
{
    h = 8.65*mm;
    full_h = 16*mm;
    inner_d = 12*mm;
    outer_d = 16*mm;
    walls = 1*mm;

    pulley(inner_d = inner_d, outer_d=outer_d, bore=5*mm, h=h, walls=walls, idler=false, full_h=full_h);
}

/*pulley_idler_2GT2_20T();*/
/*pulley_2GT2_20T();*/
