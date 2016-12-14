-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMiniMap.lua
-- *  PURPOSE:     MiniMap class
-- *
-- ****************************************************************************
GUIMiniMap = inherit(GUIElement)
inherit(GUIColorable, GUIMiniMap)

function GUIMiniMap:constructor(posX, posY, width, height, parent)
	self.m_PosX = 0
	self.m_PosY = 0
	self.m_ImageSize = 3072/2, 3072/2 --3072, 3072
	self.m_Image = self:makePath("Radar.jpg", false)
	self.m_Blips = {}

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
	self:setPosition(0, 0)
end

function GUIMiniMap:drawThis()
	dxSetBlendMode("modulate_add")
		if self.m_Image then
			dxDrawImageSection(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY),
				self.m_Width, self.m_Height,
				self.m_MapX, self.m_MapY,
				self.m_Width, self.m_Height,
				self.m_Image,
				self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0,
				self.m_RotationCenterOffsetY or 0,
				self.m_Color
			)
			for index, blip in pairs(self.m_Blips) do
				dxDrawImage(blip["posX"], blip["posY"], 32, 32, self:makePath(blip["icon"], true), 0, 0, 0, self.m_Color)
			end
		end

		if GUI_DEBUG then
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
		end
	dxSetBlendMode("blend")
end

function GUIMiniMap:worldToMapPosition(posX, posY)
	local mapX = (posX / ( 6000/self.m_ImageSize) + self.m_ImageSize/2)
	local mapY = (posY / (-6000/self.m_ImageSize) + self.m_ImageSize/2)
	return mapX, mapY
end

function GUIMiniMap:worldToMiniMapPosition(posX, posY)
	local mapX = (posX / ( 6000/self.m_ImageSize) + self.m_Width/2)
	local mapY = (posY / (-6000/self.m_ImageSize) + self.m_Height/2)
	return mapX, mapY
end

function GUIMiniMap:setPosition(posX, posY)
	local posX, posY = self:worldToMapPosition(posX, posY)
	self.m_MapX, self.m_MapY = posX - self.m_Width/2, posY - self.m_Height/2
	self:anyChange()
	return self
end

function GUIMiniMap:addBlip(icon, posX, posY) -- todo fix position, its wrong

	outputDebug(posX..", "..posY)
	outputDebug(self.m_MapX..", "..self.m_MapY)
	self.m_Blips[#self.m_Blips+1] = {["icon"] = icon, ["posX"] = posX, ["posY"] = posY}
	self:anyChange()
	return self
end

function GUIMiniMap:makePath(fileName, isBlip)
	-- if HUDRadar:getSingleton():getDesignSet() == RadarDesign.Monochrome then
	-- 	local path = (isBlip and "files/images/Radar_Monochrome/Blips/"..fileName) or "files/images/Radar_Monochrome/"..fileName
	-- 	return path
	--else
	-- Monochrome causes problems
	if true then -- HUDRadar:getSingleton():getDesignSet() == RadarDesign.GTA
		return (isBlip and "files/images/Radar_GTA/Blips/"..fileName) or "files/images/Radar_GTA/"..fileName
	end
end
