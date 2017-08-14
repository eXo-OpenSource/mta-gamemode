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
	Grey	  = {0x23, 0x23, 0x23, 230},
	LightGrey = {128, 128, 128, 255},
	Red       = {178,  35,  33}, --{255,   0,   0},
	Yellow    = {255, 255,   0},
	Green     = {11,  102,   8}, --{0,   255,   0},
	Blue      = {0,     0, 255},
	DarkBlue  = {0,    32,  63},
	DarkBlueAlpha   = {0,32,  63, 200},
    DarkLightBlue = {0, 50, 100, 255},
	Brown     = {189, 109, 19},
	BrownAlpha= {189, 109, 19, 180},
	LightBlue = {50, 200, 255},
	Orange    = {254, 138, 0},
	LightRed  = {242, 0, 86},

	HUD_Red		= {161,	47,	47},
	HUD_Red_D	= {133,	28,	28},
	HUD_Grey	= {158,158,158},
	HUD_Grey_D	= {97,97,97},
	HUD_Green	= {56,	142,60},
	HUD_Green_D	= {27,	94,	32},
	HUD_Blue	= {25,118,210},
	HUD_Blue_D	= {13,71,161},
	HUD_Cyan	= {0,151,167},
	HUD_Cyan_D	= {0,96,100},
	HUD_Orange_D= {245,127,23},
	HUD_Lime_D	= {130,119,23},
	HUD_Brown_D	= {62,39,35},
	AD_LightBlue = {0, 125, 125},
}

AdminColor = {
	[0] = {255,255,255},
	[1] = {0,128,0},
	[2] = {4,95,180},
	[3] = {4,95,180},
	[4] = {4,95,180},
	[5] = {255,0,0},
	[6] = {255,0,0},
	[7] = {255,0,0},
	[8] = {255,0,0},
	[9] = {255,0,0},
}

for k,v in pairs(AdminColor) do
	AdminColor[k] = tocolor(unpack(v))
end

for k, v in pairs(Color) do
	Color[k] = tocolor(unpack(v))
end


--originally from misterdick's color tests
function Color.fromcolor(color)
    local blue = bitAnd(color,255)
    local green = bitAnd(bitRShift(color,8),255)
    local red = bitAnd(bitRShift(color,16),255)
    local alpha = bitAnd(bitRShift(color,24),255)
    return red, green, blue, alpha
end

function Color.changeAlphaPeriod(color, p) -- 0 = 0 alpha, 1 = full alpha depending on color
	p = math.clamp(0, p, 1)
	if p == 0 then return Color.Clear end
	if p == 1 then return color end
	local r, g, b, a = Color.fromcolor(color)
	return tocolor(r, g, b, a * p)
end

function Color.changeAlpha(color, alpha)
	p = math.clamp(0, p, 255)
	if p == 0 then return Color.Clear end
	local r, g, b, a = Color.fromcolor(color)
	return tocolor(r, g, b, alpha)
end
