-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPFont.lua
-- *  PURPOSE:     Not actually a GUI Element but useful for proper font sizes
-- *
-- ****************************************************************************

-- This rescales our font to look good on a certain pixel height
local VRPFonts = {}
function VRPFont(height)
	local fontsize = math.floor(height/2)
	if not VRPFonts[fontsize] then
		VRPFonts[fontsize] = dxCreateFont("files/fonts/Segoe/segoeui.ttf", fontsize)
	end

	return VRPFonts[fontsize]
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
	SoundOn = ""
}
