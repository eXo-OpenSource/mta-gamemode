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
		FontAwesomes[fontsize] = dxCreateFont("files/fonts/FontAwesome5.ttf", fontsize)
	end

	return FontAwesomes[fontsize]
end

--for new icons: https://fontawesome.com/icons?d=gallery&m=free -> search -> click on icon -> copy from subtitle (unicode glyph). name it after its original name in the table below
FontAwesomeSymbols = {
	Close = "",
	Left = "",
	ArrowsAlt = "",
	Right = "",
	CartPlus = "",
	Cart = "",
	Phone = "",
	Tshirt = "",
	Boxes = "",
	Cube = "",
	Book = "",
	Player = "",
	Play = "",
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
	Mail = "",
	Gamepad = "",
	Suitcase = "",
	Minus = "",
	Plus = "",
	Lock = "",
	Unlock = "",
	Key = "",
	Home = "",
	Walking = "",
	SignOut = "",
	Star = "",
	Wrench = "",
	Cog = "",
	Cogs = "",
	List = "",
	Bug = "",
	Arrows = "",
	Double_Up = "",
	Double_Down = "",
	Double_Left = "",
	Double_Right = "",
	Music = "",
	Random = "",
	Handshake = "",
	Building = "",
	Medikit = "",
	IDCard = "",
	Table = "", --chart
	Bomb = "",
	Taxi = "",
	Bolt = "",
	Video = "",
	Long_Down = "",
	Waypoint = "",
	Lightbulb = "",
	Cart_Plus = "",
	Cart_Down = "",
	Car = "",
	Bullseye = "",
	Circle_O_Notch = "",
	Circle = "",
	Heart = "",
	Shield = "",
	Comment = "",
	Anchor = "",
	Points = "",
	Calender_Time = "",
	Calender_Check = "",
	Desktop = "",
	Newspaper = "",
	Advertisement = "",
	Fire = "",
	Map = "",
	CommentDot = "",
	File = "",
	Clock = "",
	Brush = "",
	Pencil = "",
	Erase = "",
	Edit = "",
	Ban = "",
	Bell = "",
	Accept = "",
	Hands= "",
	UserLock = "",
	Calendar = "",
	Crosshair = "",
}

Fonts = {
	EkMukta = "files/fonts/EkMukta.ttf",
	EkMukta_Bold = "files/fonts/EkMukta-Bold.ttf",
	Digital = "files/fonts/digital-7.ttf",
	JennaSue = "files/fonts/JennaSue.ttf",
}

local FontMario = {}
function FontMario256(height)
	local fontsize = math.floor(height/2)
	if not FontMario[fontsize] then
		FontMario[fontsize] = dxCreateFont("files/fonts/SuperMario256.ttf", fontsize)
	end

	return FontMario[fontsize]
end

-- uncomment this to render a preview of all icons on the screen
--[[
addEventHandler("onClientRender", root, function()
	local global_x = 0
	local global_y = 0
	for i, v in pairs(FontAwesomeSymbols) do
		if global_x == 15 then
			global_x = 0
			global_y = global_y + 1
		end
		dxDrawText(v, 70+global_x*70, 300+global_y*40, 20, 20, Color.white, 1, 1, FontAwesome(20))
		dxDrawText(i, 70+global_x*70, 300+global_y*40+20, 20, 20, Color.white, 1, 1)
		global_x = global_x + 1
	end
end)
]]
