-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPFont.lua
-- *  PURPOSE:     Not actually a GUI Element but useful for proper font sizes
-- *
-- ****************************************************************************

-- This rescales our font to look good on a certain pixel height
local VRPFonts = {}
function VRPFont(height, font, bold)
	local fontsize = math.floor(height/1.6) + (bold and 10000 or 0)
	font = font or Fonts.EkMukta

	if not VRPFonts[font] then
		VRPFonts[font] = {}
	end
	if not VRPFonts[font][fontsize] then
		VRPFonts[font][fontsize] = dxCreateFont(font, fontsize - (bold and 10000 or 0), bold)
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
	Right = "",
	LongRight = "",
	LongLeft = "",
	CartPlus = "",
	Cart = "",
	Phone = "",
	Book = "",
	Back = "",
	Player = "",
	Group = "",
	Money = "",
	Info = "",
	Question = "",
	CheckSquare = "",
	Check = "",
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
	Key = "",
	Home = "",
	SignOut = "",
	Star = "",
	Wrench = "",
	Cog = "",
	Cogs = "",
	List = "",
	Bug = "",
	Arrows = "",
	Double_Up = "",
	Double_Down = "",
	Double_Left = "",
	Double_Right = "",
	Music = "",
	Random = "",
	Handshake = "",
	Building = "",
	Medikit = "",
	IDCard = "",
	Document = "",
	Bomb = "",
	Taxi = "",
	Bolt = "",
	Speedo = "",
	Long_Down = "",
	Waypoint = "",
	Lightbulb = "",
	Cart_Plus = "",
	Cart_Down = "",
	Car = "",
	Bullseye = "",
	Circle_O_Notch = "",
	Circle = "",
	Heart = "",
	Shield = "",
	Comment = "",
	Anchor = "",
	Points = "",
	Calender_Time = "",
	Calender_Check = "",
	Desktop = "",
	Newspaper = "",
	Advertisement = "",
	Fire = "",
	File = "",
	Clock = "",
	Brush = "",
	Pencil = "",
	Erase = "",
	Edit = "",
	Ban = "",
	Bell = "",
	Accept = ""
}

Fonts = {
	EkMukta = "files/fonts/EkMukta.ttf",
	EkMukta_Bold = "files/fonts/EkMukta-Bold.ttf",
	Digital = "files/fonts/digital-7.ttf",
}

local FontMario = {}
function FontMario256(height)
	local fontsize = math.floor(height/2)
	if not FontMario[fontsize] then
		FontMario[fontsize] = dxCreateFont("files/fonts/SuperMario256.ttf", fontsize)
	end

	return FontMario[fontsize]
end

