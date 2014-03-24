-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Color.lua
-- *  PURPOSE:     Static color "pseudo-class"
-- *
-- ****************************************************************************

Color = {
	Clear     = {0, 0, 0, 0   },
	Black     = {0,     0,   0},
	White     = {255, 255, 255},
	Red       = {178,  35,  33}, --{255,   0,   0},
	Yellow    = {255, 255,   0},
	Green     = {11,  102,   8}, --{0,   255,   0},
	Blue      = {0,     0, 255},
	DarkBlue  = {0,    32,  63},
	DarkBlueAlpha = {0,32,  63, 200},
}

for k, v in pairs(Color) do
	Color[k] = tocolor(unpack(v))
end
