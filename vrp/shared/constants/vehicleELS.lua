--Vehicles which need ELS
--[[
    Premier
    Elegant
    LSPD
    SFPD (/Highway Patrol?)
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
    Fire PD Cars
    Romero (?)
    Utility Van (?)

    Direction Lights:
    LS,SF,LVPD
    Newsvan
]]


ELS_PRESET = {
    [596] = { -- LSPD / Police Cruiser 
        hasSiren = true,
        sequenceCount = 4,
        sequenceDuration = 200,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 0, 0, 255},
            r2 = {-0.5, -0.35, 0.95, 0.3, 255, 0, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 0, 0, 0},
            b1 = {0.75, -0.35, 0.95, 0.3, 0, 0, 255, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 0, 0, 255, 0},
            b3 = {0.25, -0.35, 0.95, 0.3, 0, 0, 255, 0},
			w = {0, -0.35, 0.95, 0.4, 255, 255, 255, 0, 0},
        },
        sequence = {
            [1] = {
				r1 = {alpha = 0},
				r2 = {alpha = 0},
				r3 = {alpha = 0},
				b2 = {alpha = 255},
				w = {strobe = false},
                vehicle_light = {"d2", {255, 0, 0}},
            },
            [2] = {
				r3 = {alpha = 255},
				b1 = {alpha = 255},
            },
            [3] = {
				r2 = {alpha = 255},
				b1 = {alpha = 0},
				b2 = {alpha = 0},
				b3 = {alpha = 0},
                vehicle_light = {"d1", {0, 0, 255}},
            },
			[4] = {
				r1 = {alpha = 255},
				b3 = {alpha = 255},
				w = {strobe = {50, 50, 255, 100}},
			}
        },
    },
    [597] = { -- SFPD / Highway Patrol
        hasSiren = true,
        sequenceCount = 4,
        sequenceDuration = 500,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 0, 0, 0},
            r2 = {-0.5, -0.35, 0.95, 0.3, 255, 0, 0, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 0, 0, 0},
            b1 = {0.75, -0.35, 0.95, 0.3, 0, 0, 255, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 0, 0, 255, 0},
            b3 = {0.25, -0.35, 0.95, 0.3, 0, 0, 255, 0},
            rf = {-0.6, 2.45,  0, 0.2, 255, 255, 255, 0},
            bf = {0.6, 2.45,  0, 0.2, 255, 255, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {strobe = false},
                r2 = {strobe = {100, 100, 255, 150}},
                r3 = {strobe = false},
                b1 = {strobe = {100, 100, 255, 150}},
                b2 = {strobe = false},
                b3 = {strobe = {100, 100, 255, 150}},
                rf = {strobe = {70, 70}},
                bf = {strobe = {70, 70}},
                vehicle_light = {"d2", {255, 0, 0}},
            },
            [2] = {
                r1 = {strobe = {100, 100, 255, 150}},
                r2 = {strobe = false},
                r3 = {strobe = {100, 100, 255, 150}},
                b1 = {strobe = false},
                b2 = {strobe = {100, 100, 255, 150}},
                b3 = {strobe = false},
                rf = {strobe = false},
                bf = {strobe = false},
				vehicle_light = {"d1", {0, 0, 255}},
            },
            [3] = {
                r1 = {strobe = false, alpha = 0},
                r2 = {strobe = false, alpha = 0},
                r3 = {strobe = false, alpha = 0},
                b1 = {strobe = {100, 100, 255, 150}},
                b2 = {strobe = {100, 100, 255, 150}},
                b3 = {strobe = {100, 100, 255, 150}},
				vehicle_light = {"d2", {255, 0, 0}},
            },
            [4] = {
                r1 = {strobe = {100, 100, 255, 150}},
                r2 = {strobe = {100, 100, 255, 150}},
                r3 = {strobe = {100, 100, 255, 150}},
                b1 = {strobe = false, alpha = 0},
                b2 = {strobe = false, alpha = 0},
                b3 = {strobe = false, alpha = 0},
				vehicle_light = {"d1", {0, 0, 255}},
            },
        },
    },
    [598] = { -- LVPD 
        hasSiren = true,
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
				vehicle_light = {"d2", {255, 0, 0}},
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
				vehicle_light = {"d1", {0, 0, 255}},
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
    ["LVPD_Orange"] = { -- LVPD 
        sequenceCount = 4,
        sequenceDuration = 300,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 150, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 150, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 150, 0},
            b1 = {0.75, -0.35, 0.95, 0, 255, 150, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 255, 150, 0},
            b3 = {0.25, -0.35, 0.95, 0, 255, 150, 0},
            rf = {-0.4, 2.5,  0.05, 0.3, 255, 150, 0, 0},
            bf = {0.4, 2.5,  0.05, 0.3, 255, 150, 0, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
                rf = {strobe = {70, 70}},
                bf = {strobe = {70, 70}},
				vehicle_light = {"d2", {255, 150, 0}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
                rf = {strobe = false},
                bf = {strobe = false},
				vehicle_light = {"d1", {255, 150, 0}},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0.3}},
				vehicle_light = {"d2", {255, 150, 0}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
				vehicle_light = {"d1", {255, 150, 0}},
            },
        },
    },
    ["LVPD_Red"] = { -- LVPD 
        sequenceCount = 4,
        sequenceDuration = 350,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 10, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 10, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 10, 0},
            b1 = {0.75, -0.35, 0.95, 0, 255, 10, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 255, 10, 0},
            b3 = {0.25, -0.35, 0.95, 0, 255, 10, 0},
            rf = {-0.4, 2.5,  0.05, 0.3, 255, 10, 0, 0},
            bf = {0.4, 2.5,  0.05, 0.3, 255, 10, 0, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
                rf = {strobe = {90, 90}},
                bf = {strobe = {90, 90}},
				vehicle_light = {"d2", {255, 10, 0}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
                rf = {strobe = false},
                bf = {strobe = false},
				vehicle_light = {"d1", {255, 10, 0}},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0.3}},
				vehicle_light = {"d2", {255, 10, 0}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
				vehicle_light = {"d1", {255, 10, 0}},
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
    [407] = { --Fire Truck
        sequenceCount = 4,
        sequenceDuration = 300,
        light = {
            uw = {0, 3.3, 1.35, 0.5, 255, 255, 255, 0},
            urr = {0.65, 3.3, 1.35, 0, 255, 10, 0},
            url = {-0.65, 3.3, 1.35, 0.4, 255, 10, 0},
            frr = {0.7, 4.15, 0.06, 0.2, 255, 10, 0},
			frl = {-0.7, 4.15, 0.06, 0, 255, 10, 0},
			fyr = {0.3, 4.45, -0.65, 0.2, 255, 145, 0, 0},
			fyl = {-0.3, 4.45, -0.65, 0.2, 255, 145, 0, 0},
			byr = {0.4, -3.35, 0.4, 0, 255, 145, 0},
			bym = {0, -3.35, 0.4, 0.4, 255, 145, 0},
			byl = {-0.4, -3.35, 0.4, 0, 255, 145, 0},
        },
        sequence = {
            [1] = {
				uw = {strobe = {80, 80}},
				urr = {fade = {0.4}},
          		url = {fade = {0}},
				byr = {fade = {0.3}},
				bym = {fade = {0}},
				byl = {fade = {0.3}},
            },
            [2] = {
				uw = {strobe = false},
           		urr = {fade = {0}},
           		url = {fade = {0.4}},
				frr = {fade = {0}},
                frl = {fade = {0.2}},
				fyr = {strobe = {100, 100, 255, 100}},
                fyl = {strobe = false},
                vehicle_light = {"d1", {255, 10, 0}},
            },
            [3] = {
				urr = {fade = {0.4}},
          		url = {fade = {0}},
				byr = {fade = {0}},
				bym = {fade = {0.4}},
				byl = {fade = {0}},
            },
            [4] = {
				urr = {fade = {0}},
           		url = {fade = {0.4}},
				frr = {fade = {0.2}},
				frl = {fade = {0}},
				fyr = {strobe = false},
                fyl = {strobe = {100, 100, 255, 100}},
                vehicle_light = {"d2", {255, 10, 0}},
            },
        }
    },
    [544] = { --Fire Truck Ladder
        sequenceCount = 4,
        sequenceDuration = 400,
        light = {
            tfry = {0.95, 2, 1.45, 0, 255, 145, 0},
            tfly = {-0.95, 2, 1.45, 0.4, 255, 145, 0},
            tbry = {0.95, 2.75, 1.45, 0.4, 255, 145, 0},
            tbly = {-0.95, 2.75, 1.45, 0, 255, 145, 0},
            frr = {0.65, 3.6, 0.06, 0, 255, 0, 0},
            flr = {-0.65, 3.6, 0.06, 0.2, 255, 0, 0},
            bry = {0.9, -4.2, -0.85, 0.2, 255, 145, 0, 0},
            bly = {-0.9, -4.2, -0.85, 0.2, 255, 145, 0, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"d1", {255, 10, 0}},
                tfry = {fade = {0.4}},
                tfly = {fade = {0}},
                tbry = {fade = {0}},
                tbly = {fade = {0.4}},
                frr = {fade = {0.2}},
                flr = {fade = {0}},
            },
            [2] = {
                vehicle_light = {"d2", {255, 10, 0}},
                tfry = {fade = {0}},
                tfly = {fade = {0.4}},
                tbry = {fade = {0.4}},
                tbly = {fade = {0}},
                bry = {strobe = {100, 100, 255, 100}},
                bly = {strobe = false},
            },
            [3] = {
                vehicle_light = {"d1", {255, 145, 0}},
                tfry = {fade = {0.4}},
                tfly = {fade = {0}},
                tbry = {fade = {0}},
                tbly = {fade = {0.4}},
                frr = {fade = {0}},
                flr = {fade = {0.2}},
            },
            [4] = {
                vehicle_light = {"d2", {255, 145, 0}},
                tfry = {fade = {0}},
                tfly = {fade = {0.4}},
                tbry = {fade = {0.4}},
                tbly = {fade = {0}},
                bly = {strobe = {100, 100, 255, 100}},
                bry = {strobe = false},
            },
        }
    },
    [416] = { --Ambulance
        sequenceCount = 2,
        sequenceDuration = 250,
        light = {
            tw = {0, 0.9, 1.3, 0.5, 255, 255, 255, 0},
            trr = {0.5, 0.9, 1.3, 0.3, 255, 10, 0, 0},
            tlr = {-0.5, 0.9, 1.3, 0.3, 255, 10, 0, 0},
            brr = {1.05, -3.6, 1.45, 0, 255, 10, 0},
            blr = {-1.05, -3.6, 1.45, 0.4, 255, 10, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"d1", {255, 10, 0}},
				brr = {fade = {0.4}},
				blr = {fade = {0}},
				tw = {strobe = {50, 50}},
				trr = {strobe = false},
           	 	tlr = {strobe = false},
            },
            [2] = {
                vehicle_light = {"d2", {255, 10, 0}},
				brr = {fade = {0}},
				blr = {fade = {0.4}},
				tw = {strobe = false},
				trr = {strobe = {100, 100, 255, 100}},
           	 	tlr = {strobe = {100, 100, 255, 100}},
            },
        }
    },
    [601] = { --SWAT Tank
        sequenceCount = 2,
        sequenceDuration = 300,
        light = {

            fr = {-1.2, 2.1, 0.97, 0.3, 255, 0, 0, 0},
            fb = {1.2, 2.1, 0.97, 0.3, 0, 0, 255, 0},
            sr = {-1, 0, 0, 0.4, 255, 0, 0},
            sb = {1, 0, 0, 0.4, 255, 0, 0},
            br = {-1, -3, 1.15, 0.3, 255, 0, 0, 0},
			bb = {1, -3, 1.15, 0.3, 0, 0, 255, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"l", {255, 0, 0}},
             	fr = {strobe = {100, 100, 255, 100}},
				bb = {strobe = {100, 100, 255, 100}},
				fb = {strobe = false},
				br = {strobe = false},
				sr = {strobe = {50, 50, 255, 100}, color = {255, 0, 0}},
				sb = {strobe = {50, 50, 255, 100}, color = {0, 0, 255}},
            },
            [2] = {
                vehicle_light = {"r", {0, 0, 255}},
				fb = {strobe = {100, 100, 255, 100}},
				br = {strobe = {100, 100, 255, 100}},
				fr = {strobe = false},
				bb = {strobe = false},
                sb = {color = {255, 0, 0}},
				sr = { color = {0, 0, 255}},
            },
        }
    },
}