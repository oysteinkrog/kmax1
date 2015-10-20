// radial bearings
// inner_d, outer_d, length
bearing_608 = [8,22,7];
bearing_626 = [8,19,6];
bearing_625 = [5,16,5];
bearing_608 = [8,22,7];
bearing_MR128 = [8,12,3.5];

// linear bearings
// inner_d, outer_d, length, clips_len, clips_d

// http://www.igus.eu/wpck/12157/Motek14_N14_6_3_Vollkunststofflager?L=en
bearing_igus_rj4jp_01_08 = [8,15,24,17.5,14.3];
bearing_igus_rj4jp_01_10 = [10,19,29,22.5,18];
bearing_igus_rj4jp_01_12 = [12,21,30,23.5,20];
bearing_igus_rj4jp_01_16 = [16,28,37,26.5,26.6];
bearing_igus_rj4jp_01_20 = [20,32,42,30.5,30.3];

module bearing(bearing_type)
{
    difference()
    {
        // outer
        fncylindera(h=bearing_type[2], d=bearing_type[1], align=[0,0,0]);
        // inner
        fncylindera(h=bearing_type[2]+1, d=bearing_type[0], align=[0,0,0]);
        // clips
        if(len(bearing_type) > 3)
        {
            clip_depth=.5;
            for(j=[-1,1])
            translate([0,0,j*bearing_type[3]/2])
            difference()
            {
                fncylindera(h=1, d=bearing_type[2]+1, align=[0,0,0]);
                fncylindera(h=2, d=bearing_type[4]-clip_depth, align=[0,0,0]);
            }

        }
    }
}

