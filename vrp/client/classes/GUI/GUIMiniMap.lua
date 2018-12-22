-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMiniMap.lua
-- *  PURPOSE:     MiniMap class
-- *
-- ****************************************************************************
GUIMiniMap = inherit(GUIElement)
inherit(GUIColorable, GUIMiniMap)
local borderColor = { ["Radar_GTA"] = tocolor(108, 137, 171), ["Radar_Monochrome"] = tocolor(121, 170, 213) }
local imageSize = { ["Radar_GTA"]  = 1536, ["Radar_Monochrome"] = 1536}
function GUIMiniMap:constructor(posX, posY, width, height, parent)
	self.m_PosX = 0
	self.m_PosY = 0
	local path, color, size = self:makePath("Radar.jpg", false)
	self.m_ImageSize = size
	self.m_Image = dxCreateTexture(path)
	if self.m_Image then
		dxSetTextureEdge(self.m_Image, "border", color or borderColor["Radar_GTA"])
	else 
		self.m_Image = path
	end
	self.m_Blips = {}
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
end

function GUIMiniMap:drawThis()
	dxSetBlendMode("modulate_add")
		if self.m_Image then
			if self.m_MapX then -- suppress warning of arguement #5 so the frames don't go down
				dxDrawImageSection(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY),
					self.m_Width, self.m_Height,
					self.m_MapX, self.m_MapY,
					self.m_Width, self.m_Height,
					self.m_Image,
					self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0,
					self.m_RotationCenterOffsetY or 0,
					self.m_Color
				)
			end
			for index, blip in pairs(self.m_Blips) do
				if blip then
					dxDrawImage(blip["posX"]-16, blip["posY"]-16, 32, 32, self:makePath(blip["icon"], true), 0, 0, 0, self.m_Color)
				end
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

function GUIMiniMap:setMapPosition(posX, posY)
	local posX, posY = self:worldToMapPosition(posX, posY)
	self.m_MapX, self.m_MapY = posX - self.m_Width/2, posY - self.m_Height/2
	self:anyChange()
	return self
end

function GUIMiniMap:addBlip(icon, posX, posY) -- todo fix position, its wrong
	local x,y = self:worldToMapPosition(posX, posY)
	if self:isWithinMapBound( x, y) then
		local offX = x - self.m_MapX
		local offY = y - self.m_MapY 
		offX = self.m_AbsoluteX + offX 
		offY = self.m_AbsoluteY + offY
		self.m_Blips[#self.m_Blips+1] = {["icon"] = icon, ["posX"] =  offX, ["posY"] =  offY}
		self:anyChange()
		return self
	end
end

function GUIMiniMap:isWithinMapBound( x, y )
	if x >= self.m_MapX and x <= self.m_MapX + self.m_Width then 
		if y >= self.m_MapY and y <= self.m_MapY + self.m_Height then 
			return true
		end
	end
	return false
end

function GUIMiniMap:makePath(fileName, isBlip)
    if isBlip then
        if fileExists("_custom/files/images/Radar/Blips/"..fileName) then
            return "_custom/files/images/Radar/Blips/"..fileName
        end
        return "files/images/Radar/Blips/"..fileName
    else
        local designSet = (HUDRadar:getSingleton().m_DesignSet == RadarDesign.Monochrome) and "Radar_Monochrome" or "Radar_GTA"
		local fileSuffix = (HUDRadar:getSingleton().m_DesignSet == RadarDesign.Monochrome) and "-small" or ""
        if fileExists("_custom/files/images/Radar/"..designSet.."/Radar"..fileSuffix..".png") then
            return "_custom/files/images/Radar/"..designSet.."/Radar.png", borderColor[designSet], imageSize[designSet]
        elseif fileExists("_custom/files/images/Radar/"..designSet.."/Radar"..fileSuffix..".jpg") then
            return "_custom/files/images/Radar/"..designSet.."/Radar"..fileSuffix..".jpg", borderColor[designSet], imageSize[designSet]
        end
        return "files/images/Radar/"..designSet.."/Radar"..fileSuffix..".jpg", borderColor[designSet], imageSize[designSet]
    end
end
