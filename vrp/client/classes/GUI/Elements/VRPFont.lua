-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPFont.lua
-- *  PURPOSE:     Not actually a GUI Element but useful for proper font sizes
-- *
-- ****************************************************************************

Fonts = {
	FontAwesome = "files/fonts/FontAwesome5.ttf",					-- Icons
	EkMukta = "files/fonts/EkMukta.ttf",							-- Main font
	EkMukta_Bold = "files/fonts/EkMukta-Bold.ttf",					-- Toast messages
	Digital = "files/fonts/digital-7.ttf",							-- Speedo
	JennaSue = "files/fonts/JennaSue.ttf",							-- Handwritten date for FishSpeciesGUI
	Gasalt = "files/fonts/Gasalt.ttf",								-- Achievements
	BitBold = "files/fonts/BitBold.ttf",							-- EasterEggArcade
	JosefinSansThin = "files/fonts/JosefinSans-Thin.ttf",			-- Minigame: GoJump / 2Cars
	JosefinSansRegular = "files/fonts/JosefinSans-Regular.ttf",		-- Minigame: SideSwipe
	VanadineBold = "files/fonts/vanadine-bold.ttf",					-- Minigame: 2Cars
	Gobold = "files/fonts/gobold-light.ttf",						-- Minigame: 2Cars
	Mario256 = "files/fonts/SuperMario256.ttf",						-- WareGame
	Ghetto = "files/fonts/Ghetto.ttf",								-- GangArea, SprayWall
	Rage = "files/fonts/rage.ttf",									-- Vehicle radio
}

-- This rescales our font to look good on a certain pixel height
function VRPFont(height, font, bold)
	return {font or Fonts.EkMukta, math.floor(height/1.6), bold}
end

function FontAwesome(height)
	return {Fonts.FontAwesome, math.floor(height/2)}
end

local VRPFonts = {}
function getVRPFont(fontData)
	local font = fontData[1]
	local height = fontData[2]
	local bold = fontData[3]

	local fontsize = height + (bold and 10000 or 0)
	font = font or Fonts.EkMukta

	if not VRPFonts[font] then
		VRPFonts[font] = {}
	end
	if not VRPFonts[font][fontsize] then
		VRPFonts[font][fontsize] = dxCreateFont(font, fontsize - (bold and 10000 or 0), bold)
	end

	VRPFonts[font][fontsize].lastUsed = getTickCount()
	return VRPFonts[font][fontsize]
end

-- Cleanup unused fonts
setTimer(
	function()
		for fontName, fonts in pairs(VRPFonts) do
			for fontSize, font in pairs(fonts) do
				if isElement(font) and getTickCount() - font.lastUsed >= 60000 then
					destroyElement(font)
					VRPFonts[fontName][fontSize] = nil
					--outputChatBox(("Destroy: %s (%s)"):format(fontName, fontSize))
				end
			end
		end
	end, 10000, 0
)

-- This gets the text width for a font which is 'height' pixels high
function VRPTextWidth(text, height)
	return dxGetTextWidth(text, 1, getVRPFont(VRPFont(height)))
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
	Pointer = "",
	DoubleDown = "",
	Boxes = "",
	Cube = "",
	Book = "",
	Player = "",
	Play = "",
	Group = "",
	Dollar = "",
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
	Dice = "",
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

-- uncomment this to render a list of all loaded fonts
--[[addEventHandler("onClientRender", root,
	function()
		local i, total = 0, 0
		for fontName, fontSizes in pairs(VRPFonts) do
			local count = table.size(fontSizes)
			total = total + count

			for fontSize, font in pairs(fontSizes) do
				dxDrawText(("%s: %s (%.2f)"):format(fontName, fontSize, (getTickCount()-font.lastUsed)/1000), 15, 250+(i*15))
				i = i + 1
			end
		end
		dxDrawText("-----------", 15, 250+(i*15))
		i = i + 1
		dxDrawText(("Total: %s"):format(total), 15, 250+(i*15))
	end
)]]

-- uncomment this to render a preview of all icons on the screen
--[[addEventHandler("onClientRender", root,
	function()
		local global_x = 0
		local global_y = 0
		for i, v in pairs(FontAwesomeSymbols) do
			if global_x == 15 then
				global_x = 0
				global_y = global_y + 1
			end
			dxDrawText(v, 70+global_x*70, 300+global_y*40, 20, 20, Color.white, 1, 1, getVRPFont(FontAwesome(20)))
			dxDrawText(i, 70+global_x*70, 300+global_y*40+20, 20, 20, Color.white, 1, 1)
			global_x = global_x + 1
		end
	end
)]]
