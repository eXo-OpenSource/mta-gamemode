-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPFont.lua
-- *  PURPOSE:     Not actually a GUI Element but useful for proper font sizes
-- *
-- ****************************************************************************

-- This rescales our font to look good on a certain pixel height
local VRPFonts = {}
function VRPFont(height, font)
	local fontsize = math.floor(height/1.6)
	font = font or Fonts.EkMukta

	if not VRPFonts[font] then
		VRPFonts[font] = {}
	end
	if not VRPFonts[font][fontsize] then
		VRPFonts[font][fontsize] = dxCreateFont(font, fontsize)
	end

	return VRPFonts[font][fontsize]
end

-- This gets the text width for a font which is 'height' pixels high
function VRPTextWidth(text, height)
	return dxGetTextWidth(text, 1, VRPFont(height))
end


local FontAwesomes = {}
function FontAwesome(height)
	local fontsize = math.floor(height/2)
	if not FontAwesomes[fontsize] then
		FontAwesomes[fontsize] = dxCreateFont("files/fonts/FontAwesome.otf", fontsize)
	end

	return FontAwesomes[fontsize]
end

FontAwesomeSymbols = {
	Close = "",
	Left = "",
	CartPlus = "",
	Cart = "",
	Phone = "",
	Book = "",
	Back = "",
	Player = "",
	Group = "",
	Money = "",
	Info = "",
	Check = "",
	Square = "",
	Search = "",
	Refresh = "",
	Expand = "",
	Copy = "",
	Trash = "",
	Save = "",
	SoundOff = "",
	SoundOn = "",
	Mail = "",
	Gamepad = "",
	Suitcase = "",
	Minus = "",
	Plus = "",
	Lock = "",
	Unlock = "",
}

Fonts = {
	EkMukta = "files/fonts/EkMukta.ttf",
	EkMukta_Bold = "files/fonts/EkMukta-Bold.ttf",
	Digital = "files/fonts/digital-7.ttf",
}
