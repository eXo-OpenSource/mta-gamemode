-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Color.lua
-- *  PURPOSE:     Static color "pseudo-class"
-- *
-- ****************************************************************************

Color = {
	Clear     = {0, 0, 0, 0   },
	Black     = {0,     0,   0},
	White     = {255, 255, 255},
	Red       = {255,   0,   0},
	Yellow    = {255, 255,   0},
	Green     = {0,   255,   0},
	Blue      = {0,     0, 255}


}

for k, v in pairs(Color) do
	Color[k] = tocolor(unpack(v))
end
