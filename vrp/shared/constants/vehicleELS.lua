ELS_PRESET = {
    [411] = {
        sequenceCount = 2,
        light = {
            --name = {x, y, z, size, r, g, b}
            vl = {0.5, 2, 0, 0.2, 255, 0, 0},
            vr = {-0.5, 2, 0, 0.2, 0, 0, 255},
        },
        sequence = {
            [1] = {
                vl = {
                    enabled = true,
                },
                vr = {
                    enabled = false,
                },
            },
            [2] = {
                vl = {
                    enabled = false,
                },
                vr = {
                    enabled = true,
                },
            },
        },
    },


}