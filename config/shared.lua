return {
    cityhalls = {
        { -- Cityhall 1
            coords = vec3(-265.0, -963.6, 31.2),
            showBlip = true,
            blipData = {
                sprite = 487,
                display = 4,
                scale = 0.65,
                colour = 0,
                title = 'City Services',
            },
            licenses = {
                ['id'] = {
                    item = 'id_card',
                    label = 'ID',
                    cost = 50,
                },
                ['driver'] = {
                    item = 'driver_license',
                    label = 'Driver License',
                    cost = 50,
                },
                ['weapon'] = {
                    item = 'weaponlicense',
                    label = 'Weapon License',
                    cost = 50,
                },
            },
        },
    },

    drivingSchools = {
        { -- Driving School 1
            coords = vec3(240.3, -1379.89, 33.74),
            showBlip = true,
            blipData = {
                sprite = 225,
                display = 4,
                scale = 0.65,
                colour = 3,
                title = 'Driving School',
            },
            instructors = {
                'DJD56142',
                'DXT09752',
                'SRI85140',
            },
        },
    },

    employment = {
        enabled = true, -- Set to false to disable the employment menu
        jobs = {
            unemployed = 'Unemployed',
            trucker = 'Trucker',
            taxi = 'Taxi',
            tow = 'Tow Truck',
            reporter = 'News Reporter',
            garbage = 'Garbage Collector',
            bus = 'Bus Driver',
        },
    },
}