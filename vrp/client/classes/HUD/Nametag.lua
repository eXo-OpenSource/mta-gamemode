-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/Nametag.lua
-- *  PURPOSE:     Nametag class
-- *
-- ****************************************************************************
Nametag = inherit(Singleton)
Nametag.font = "default-bold"
Nametag.fontSize = 2
addEvent("reciveNametagBuffs", true)

local sizePerRankIcon = 150/5
local maxDistance = 40
local bOnScreen, bLineOfSight, px, py, pz, bDistance, textWidth, drawName, fontSize, scx,scy, color, armor, r,g,b, health, cx,cy,cz
local fontHeight


function Nametag:constructor()
	for key, player in ipairs(getElementsByType("player")) do
		setPlayerNametagShowing(player, false)
	end
	self.m_Stream = {}
	self.m_Style = core:get("HUD", "NametagStyle", NametagStyle.Default)
	self.m_Draw = bind(self.draw, self)
	self.m_StreamIn = bind(self.Event_StreamIn, self)
	self.m_StreamOut = bind(self.Event_StreamIn, self)

	addEventHandler("onClientElementStreamIn", root, self.m_StreamIn)
	addEventHandler("onClientElementStreamOut", root, self.m_StreamOut)
	addEventHandler("onClientRender", root, self.m_Draw)
end

function Nametag:destructor()
	removeEventHandler("onClientElementStreamIn", root, self.m_StreamIn)
	removeEventHandler("onClientElementStreamOut", root, self.m_StreamOut)
	removeEventHandler("onClientRender", root, self.m_Draw)
end



function Nametag:Event_StreamIn()
	if source ~= localPlayer then
		local bType = getElementType(source) == "player"
		if bType then
			self.m_Stream[source] = true
		end
	end
end

function Nametag:Event_StreamOut()
	if source ~= localPlayer then
		local bType = getElementType(source) == "player"
		if bType then
			self.m_Stream[source] = false
		end
	end
end

function Nametag:draw()
	local x,y,z = getElementPosition(localPlayer)
	cx,cy,cz = getCameraMatrix()
	for player, _ in pairs( self.m_Stream ) do
		if isElement(player) then
			bOnScreen = isElementOnScreen( player )
			px,py,pz = getElementPosition(player)
			bDistance = getDistanceBetweenPoints2D( x, y, px, py )
			if bDistance <= maxDistance then
				bLineOfSight = isLineOfSightClear( cx, cy, cz, px,py,pz+1, true, false, false, true, false, false, false,localPlayer)
				if bLineOfSight then
					scx,scy = getScreenFromWorldPosition( px, py, pz+1.5 )
					if scx and scy then
						drawName = getPlayerName(player)
						fontSize =  1+ ( 10 - bDistance ) * 0.02
						fontHeight = dxGetFontHeight(fontSize,Nametag.font)
						textWidth = dxGetTextWidth(drawName, fontSize, Nametag.font)
						armor = getPedArmor(player)
						health = getElementHealth(player)
						r,g,b =  self:getColorFromHP(health)
						dxDrawText( drawName, scx- (textWidth*0.5), scy-fontHeight*2, scx+(textWidth*0.5), scy-fontHeight*1.2,tocolor(r,g,b) ,fontSize, Nametag.font, "center" )
						self:drawIcons(player, "center", scx-(textWidth*0.5), scy-fontHeight, true, fontHeight)
					end
				end
			end
		end
	end
end

function Nametag:drawIcons(player, align, startX, startY, armor, width, textwidth)
	if isChatBoxInputActive() then
		setElementData(localPlayer, "writing", true)
	else
		setElementData(localPlayer, "writing", false)
	end

	local icons = {}

	if armor and player:getArmor() > 0 then
		icons[#icons+1] = "armor.png"
	end
	if getElementData(player,"writing") == true then
		icons[#icons+1] = "chat.png"
	end
	if (player:getPublicSync("Rank") or 0) > 0 then
		icons[#icons+1] = "admin.png"
	end
	if player:getWanteds() > 0 then
		icons[#icons+1] = "w"..player:getWanteds()..".png"
	end
	if player:getFaction() then
		icons[#icons+1] = player:getFaction():getShortName()..".png"
	end

	if align == "center" then
		startX = startX + ((#icons-1)*width)
	end

	for index, icon in pairs(icons) do
		dxDrawImage(startX, startY, width, width, "files/images/Nametag/"..icon)
	end

end


function Nametag:getColorFromHP(hp)
	if hp <= 0 then
		return 0, 0, 0
	else
		hp = math.abs ( hp - 0.01 )
		return ( 100 - hp ) * 2.55 / 2, ( hp * 2.55 ), 0
	end
end


function isCursorOverArea ( x,y,w,h )
	if isCursorShowing () then
		local cursorPos = {getCursorPosition()}
		local mx, my = cursorPos[1]*screenWidth,cursorPos[2]*screenHeight
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return true
		end
	end
	return false
end
