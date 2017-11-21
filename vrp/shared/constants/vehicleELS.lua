--Vehicles which need ELS
--[[
    Premier
    Elegant
    LSPD
    SFPD (/Highway Patrol?)
    FBI LVPD (?)
    Barracks
    SASF Huntley
    SASF Pickup
    Patriot
    Towtruck
    Sweeper
    FBI Truck (finishing)
    SWAT Tank
    Police Rancher
    Rescue Ranger
    Fire Truck
    Fire Truck Ladder
    Ambulance
    Fire PD Cars
    Romero (?)
    Utility Van (?)

    Direction Lights:
    LS,SF,LVPD
    Newsvan
]]


ELS_PRESET = {
    [598] = { -- LVPD 
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 0, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 0, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 0, 0},
            b1 = {0.75, -0.35, 0.95, 0, 0, 0, 255},
            b2 = {0.5, -0.35, 0.95, 0.4, 0, 0, 255},
            b3 = {0.25, -0.35, 0.95, 0, 0, 0, 255},
            rf = {-0.4, 2.5,  0.05, 0.2, 255, 0, 0, 0},
            bf = {0.4, 2.5,  0.05, 0.3, 0, 0, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.4}},
                b2 = {fade = {0}},
                b3 = {fade = {0.4}},
                rf = {strobe = {70, 70}},
                bf = {strobe = {70, 70}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.4}},
                b3 = {fade = {0}},
                rf = {strobe = false},
                bf = {strobe = false},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.4}},
                b2 = {fade = {0.4}},
                b3 = {fade = {0.4}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
            },
        },
    },
    ["LVPD-Orange"] = { -- LVPD 
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 150, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 150, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 150, 0},
            b1 = {0.75, -0.35, 0.95, 0, 255, 150, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 255, 150, 0},
            b3 = {0.25, -0.35, 0.95, 0, 255, 150, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0.3}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
            },
        },
    },
    [528] = { --FBI Truck
        sequenceCount = 2,
        sequenceDuration = 600,
        light = {
            fbu = {0.45,    2.55,   0,    0.25,    0,  0, 255, 0},
            fbd = {0.45,    2.55,   -0.3,   0.25,    0,  0, 255, 0},
            fru = {-0.45,   2.55,   0,    0.2,    255,0, 0,   0},
            frd = {-0.45,   2.55,   -0.3,   0.2,    255,0, 0,   0},
        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                frd = {strobe = false},
                fru = {strobe = {100, 100, 255, 100}},
                fbd = {strobe = {100, 100, 255, 100}},
            },
            [2] = {
                fru = {strobe = false},
                fbd = {strobe = false},
                fbu = {strobe = {100, 100, 255, 100}},
                frd = {strobe = {100, 100, 255, 100}},
            },
        }
    },
    ["FBI_Buffalo"] = { --FBI Buffalo
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            fbu = {0.5, -2, 0.3, 0.25, 0, 0, 255, 0}, --front blue up
            fbd = {0.6, 0.7, 0.25, 0.25, 0, 0, 255, 0}, --fb down
            fru = {-0.5, -2, 0.3, 0.2, 255,0, 0, 0}, 
            frd = {0.3, 0.7, 0.25, 0.2, 255,0, 0, 0},
            fb = {0.4, 2.6, -0.35, 0.25, 0, 0, 255, 0}, --side blue
            fr = {-0.4, 2.6, -0.35, 0.2, 255,0, 0, 0},

        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                fru = {strobe = {70, 70, 255, 150}},
                fb = {strobe = {50, 50}},
                vehicle_light = {"l", {255, 0, 0}},
            },
            [2] = {
				frd = {strobe = false},
				fbd = {strobe = {70, 70, 255, 150}},
                fb = {strobe = false},
                fr = {strobe = {50, 50}},
                vehicle_light = {"r", {0, 0, 255}},
            },
            [3] = {
                fru = {strobe = false},
                fbu = {strobe = {70, 70, 255, 150}},
                fr = {strobe = false},
                vehicle_light = {"l", {255, 0, 0}},
            },
            [4] = {
				frd = {strobe = {70, 70, 255, 150}},
                fbd = {strobe = false},
                vehicle_light = {"r", {0, 0, 255}},
            },
        }
    },
	[490] = { --FBI Rancher
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            fbu = {0.5, 3.2, 0.1, 0.25, 0, 0, 255, 0}, --front blue up
            fbd = {0.5, 3.2, -0.1, 0.25, 0, 0, 255, 0}, --fb down
            fru = {-0.5, 3.2, 0.1, 0.2, 255,0, 0, 0}, 
            frd = {-0.5, 3.2, -0.1, 0.2, 255,0, 0, 0},
            sb = {1.1, -1.3, 0.4, 0.25, 0, 0, 255, 0}, --side blue
            sr = {-1.1, -1.3, 0.4, 0.2, 255,0, 0, 0},
            bb1 = {0.3, -2.8, 0.8, 0.2, 0, 0, 255, 0}, --back blue
            bb2 = {0.6, -2.8, 0.8, 0.2, 0, 0, 255, 0},
            br1 = {-0.3, -2.8, 0.8, 0.2, 255, 0, 0, 0},
            br2 = {-0.6, -2.8, 0.8, 0.2, 255, 0, 0, 0},
        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                frd = {strobe = false},
                fru = {strobe = {70, 70, 255, 150}},
                fbd = {strobe = {70, 70, 255, 150}},
				sr = {strobe = false, alpha=0},
				sb = {strobe = {50, 50}, color={0,0,255,255}},
                bb2 = {alpha = 255},
				br1 = {alpha = 0},
				vehicle_light = {"d2", {255, 0, 0}},
            },
			[2] = {
				sb = {color={255,0,0}},
				br2 = {alpha = 255},
				bb2 = {alpha = 0},
			},
            [3] = {
                fru = {strobe = false},
                fbd = {strobe = false},
                fbu = {strobe = {70, 70, 255, 150}},
                frd = {strobe = {70, 70, 255, 150}},
                sr = {strobe = {50, 50}, color={255,0,0,255}},
				sb = {strobe = false, alpha=0},
				bb1 = {alpha = 255},
				br2 = {alpha = 0},
				vehicle_light = {"d1", {0, 0, 255}},
				
            },
			[4] = {
				sr = {color={0,0,255,255}},
				br1 = {alpha = 255},
				bb1 = {alpha = 0},
			},
        }
    },
    [427] = { --Enforcer
        sequenceCount = 6,
        sequenceDuration = 250,
        light = {
            -- top front
            tfr = {0.4, 1.1, 1.45, 0.4, 255, 0 ,0}, --top front right
            tfl = {-0.4, 1.1, 1.45, 0, 255, 0, 0}, --top front left
            tfm = {0, 1.1, 1.45, 0.4, 255, 145, 0, 0}, --middle
            --side yellow
            sr1 = {1.2, 0.1, 1.25, 0.25, 255, 145, 0}, --side right
            sr2 = {1.2, -1.6, 1.25, 0, 255, 145, 0}, 
            sr3 = {1.2, -3.4, 1.25, 0.25, 255, 145, 0}, 
            sl1 = {-1.2, 0.1, 1.25, 0, 255, 145, 0}, --side left
            sl2 = {-1.2, -1.6, 1.25, 0.25, 255, 145, 0}, 
            sl3 = {-1.2, -3.4, 1.25, 0, 255, 145, 0}, 
            --back
            br = {0.95, -3.8, 1.3, 0.25, 255, 255, 255, 0}, --side right
            bl = {-0.95, -3.8, 1.3, 0.25, 255, 255, 255, 0}, 
        },
        sequence = {
        	[1] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				sr1 = {fade = {0}},				
				sr2 = {fade = {0.25}},
				sr3 = {fade = {0}},
				br = {strobe = false},
				bl = {strobe = false},
				tfm = {strobe = false},
				vehicle_light = {"d2", {255, 0, 0}},

			},
			[2] = {
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				sl1 = {fade = {0.25}},				
				sl2 = {fade = {0}},
				sl3 = {fade = {0.25}},
				vehicle_light = {"d1", {255, 0, 0}},
			},
			[3] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				br = {strobe = {50, 50, 255, 150}},
				bl = {strobe = {50, 50, 255, 150}},
				tfm = {strobe = {50, 50, 255, 150}},
				vehicle_light = {"full", {255, 145, 0}},
			},
			[4] = {
				br = {strobe = false},
				bl = {strobe = false},
				tfm = {strobe = false},
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				sr1 = {fade = {0.25}},				
				sr2 = {fade = {0}},
				sr3 = {fade = {0.25}},
				vehicle_light = {"d1", {255, 0, 0}},
			},
			[5] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				sl1 = {fade = {0}},				
				sl2 = {fade = {0.25}},
				sl3 = {fade = {0}},
				vehicle_light = {"d2", {255, 0, 0}},
			},
			[6] = {
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				br = {strobe = {50, 50, 255, 150}},
				bl = {strobe = {50, 50, 255, 150}},
				tfm = {strobe = {50, 50, 255, 150}},
				vehicle_light = {"full", {255, 145, 0}},
			},
        }
    },

}