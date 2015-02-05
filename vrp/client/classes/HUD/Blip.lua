-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/Blip.lua
-- *  PURPOSE:     HUD radar blip class
-- *
-- ****************************************************************************
Blip = inherit(Object)
Blip.ServerBlips = {}

function Blip:constructor(imagePath, worldX, worldY, streamDistance)
	if type(worldX) ~= "number" or type(worldY) ~= "number" then
		outputDebug(debug.traceback())
		
		-- Hack: Prevent error messages (for debugging purposes)
		worldX, worldY = 0, 0
	end

	self.m_RawImagePath = imagePath
	self.m_ImagePath = HUDRadar:getSingleton():makePath(imagePath, true)
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_Alpha = 255
	self.m_Size = 24
	self.m_StreamDistance = streamDistance or math.huge
	
	-- Temporary workaround (Todo: Replace this by an own implementation)
	exports.customblips:createCustomBlip(worldX, worldY, 16, 16, self.m_ImagePath, self.m_StreamDistance == math.huge and 99999 or self.m_StreamDistance)
	
	-- Add the blip to the radar
	HUDRadar:getSingleton():addBlip(self)
end

function Blip:destructor()
	-- Remove the blip from the radar
	HUDRadar:getSingleton():removeBlip(self)
end

function Blip:getImagePath()
	return self.m_ImagePath
end

function Blip:setImagePath(path)
	self.m_RawImagePath = path
	self:updateDesignSet()
end

function Blip:getPosition()
	return self.m_WorldX, self.m_WorldY
end

function Blip:setPosition(x, y)
	self.m_WorldX, self.m_WorldY = x, y
end

function Blip:getAlpha()
	return self.m_Alpha
end

function Blip:setAlpha(alpha)
	self.m_Alpha = alpha
end

function Blip:getSize()
	return self.m_Size
end

function Blip:setSize(size)
	self.m_Size = size
end

function Blip:getStreamDistance()
	return self.m_StreamDistance
end

function Blip:setStreamDistance(distance)
	self.m_StreamDistance = distance
end

function Blip:updateDesignSet()
	self.m_ImagePath = HUDRadar:getSingleton():makePath(self.m_RawImagePath, true)
end

addEvent("blipCreate", true)
addEventHandler("blipCreate", root,
	function(index, path, x, y)
		Blip.ServerBlips[index] = Blip:new(path, x, y)
	end
)

addEvent("blipDestroy", true)
addEventHandler("blipDestroy", root,
	function(index)
		if Blip.ServerBlips[index] then
			delete(Blip.ServerBlips[index])
		end
	end
)

addEvent("blipsRetrieve", true)
addEventHandler("blipsRetrieve", root,
	function(data)
		for k, v in pairs(data) do
			Blip.ServerBlips[k] = Blip:new(unpack(v))
		end
	end
)
