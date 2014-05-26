-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/RadarBlip.lua
-- *  PURPOSE:     HUD radar blip class
-- *
-- ****************************************************************************
RadarBlip = inherit(Object)
RadarBlip.ServerBlips = {}

function RadarBlip:constructor(imagePath, worldX, worldY, streamDistance)
	self.m_ImagePath = imagePath
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_Alpha = 255
	self.m_Size = 24
	self.m_StreamDistance = streamDistance or math.huge
end

function RadarBlip:destructor()
end

function RadarBlip:getImagePath()
	return self.m_ImagePath
end

function RadarBlip:setImagePath(path)
	return self.m_ImagePath
end

function RadarBlip:getPosition()
	return self.m_WorldX, self.m_WorldY
end

function RadarBlip:setPosition(x, y)
	self.m_WorldX, self.m_WorldY = x, y
end

function RadarBlip:getAlpha()
	return self.m_Alpha
end

function RadarBlip:setAlpha(alpha)
	self.m_Alpha = alpha
end

function RadarBlip:getSize()
	return self.m_Size
end

function RadarBlip:setSize(size)
	self.m_Size = size
end

function RadarBlip:getStreamDistance()
	return self.m_StreamDistance
end

function RadarBlip:setStreamDistance(distance)
	self.m_StreamDistance = distance
end

addEvent("blipCreate", true)
addEventHandler("blipCreate", root,
	function(index, path, x, y)
		RadarBlip.ServerBlips[index] = HUDRadar:getSingleton():addBlip(path, x, y)
	end
)

addEvent("blipDestroy", true)
addEventHandler("blipDestroy", root,
	function(index)
		if RadarBlip.ServerBlips[index] then
			HUDRadar:getSingleton():removeBlip(RadarBlip.ServerBlips[index])
		end
	end
)

addEvent("blipsRetrieve", true)
addEventHandler("blipsRetrieve", root,
	function(data)
		for k, v in pairs(data) do
			RadarBlip.ServerBlips[k] = HUDRadar:getSingleton():addBlip(unpack(v))
		end
	end
)
