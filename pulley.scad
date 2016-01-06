// h, full_h, inner_d, outer_d, walls, bore
pulley_2GT_20T_idler = [8.65*mm, undef, 12*mm, 18*mm, 1*mm, 5*mm];
pulley_2GT_20T       = [8.65*mm, 16*mm, 12*mm, 16*mm, 1*mm, 5*mm];

module pulley(pulley=pulley_2GT_20T, align=[0,0,0], orient = [0,0,1])
{
    is_idler = pulley[1] == undef;
    pulley_full(
            is_idler=is_idler,
            h=pulley[0],
            full_h=is_idler?0:pulley[1],
            inner_d=pulley[2],
            outer_d=pulley[3],
            walls=pulley[4],
            bore=pulley[5],
            align=align,
            orient=orient
            );
}

module pulley_full(h, inner_d, outer_d, bore, walls, is_idler=false, full_h, align=[0,0,0], orient = [0,0,1])
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

                if(!is_idler)
                {
                    translate([0,0,h-walls])
                        fncylindera(d = outer_d, h = full_h-h, align=[0,0,0], orient=[0,0,1]);
                }
            }
            fncylindera(d = bore, h = h+full_h, align=[0,0,0], orient=[0,0,1]);
        }
    }
}

/*pulley(pulley_2GT_20T_idler, align, orient);*/
/*pulley(pulley_2GT_20T, align=align, orient=orient);*/
