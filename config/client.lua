return {
    useTarget = false,
    debugPoly = false,

    peds = {
        { -- Cityhall Ped
            model = 'a_m_m_hasjew_01',
            coords = vec4(-262.79, -964.18, 30.22, 181.71),
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            cityhall = true,
            zoneOptions = { -- Used for when UseTarget is false
                length = 3.0,
                width = 3.0,
                debugPoly = false,
            },
        },
        { -- Driving School Ped
            model = 'a_m_m_eastsa_02',
            coords = vec4(240.91, -1379.2, 32.74, 138.96),
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            drivingschool = true,
            zoneOptions = { -- Used for when UseTarget is false
                length = 3.0,
                width = 3.0,
            },
        },
    },
}