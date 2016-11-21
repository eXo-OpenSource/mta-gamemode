-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/RageFont.lua
-- *  PURPOSE:     Not actually a GUI Element but useful for proper font sizes
-- *
-- ****************************************************************************

-- This rescales our font to look good on a certain pixel height
local RageFonts = {}
function RageFont(height)
	local fontsize = math.floor(height/2)
	if not RageFonts[fontsize] then
		RageFonts[fontsize] = dxCreateFont("files/fonts/rage.ttf", fontsize)
	end

	return RageFonts[fontsize]
end

-- This gets the text width for a font which is 'height' pixels high
function RageTextWidth(text, height)
	return dxGetTextWidth(text, 1, RageFont(height))
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
	Expand = ""
}
