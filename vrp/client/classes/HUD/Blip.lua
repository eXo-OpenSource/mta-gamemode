-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: client/classes/HUD/Blip.lua
-- * PURPOSE: HUD radar blip class
-- *
-- ****************************************************************************
Blip = inherit(Object)
Blip.ServerBlips = {}
Blip.Blips = {}
Blip.AttachedBlips = {}
Blip.DisplayTexts = {}

addRemoteEvents{"blipCreate", "blipUpdate", "blipDestroy", "blipsRetrieve"}

function Blip:constructor(imagePath, worldX, worldY, streamDistance, color, optionalColor)
	self.m_ID = #Blip.Blips + 1
	self.m_RawImagePath = imagePath
	self.m_ImagePath = HUDRadar:getSingleton():makePath(imagePath, true)
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_WorldZ = false
	self.m_Size = Blip.getDefaultSize()
	self.m_StreamDistance = streamDistance or 100

	self.m_Color = color and tocolor(unpack(color)) or tocolor(255, 255, 255)
	self.m_OptionalColor = optionalColor and tocolor(unpack(optionalColor)) or tocolor(255, 255, 255)

	Blip.Blips[self.m_ID] = self

	HUDRadar:syncBlips()
end

function Blip:destructor()
	local index = table.find(Blip.Blips, self)
	if self.m_ID and Blip.Blips[self.m_ID] then
		index = self.m_ID
	else
		index = table.find(Blip.Blips, self)	
	end

	if index then
		if self.m_DisplayText then --remove blip from display text list
			table.removevalue(Blip.DisplayTexts[self.m_Category][self.m_DisplayText], self)
			if #Blip.DisplayTexts[self.m_Category][self.m_DisplayText] == 0 then 
				Blip.DisplayTexts[self.m_Category][self.m_DisplayText] = nil
			end
			CustomF11Map:getSingleton():updateBlipList()
		end
		self:detach()
		Blip.Blips[index] = nil
	end
	HUDRadar:syncBlips()
end

function Blip:getImagePath()
	return self.m_ImagePath
end

function Blip:setImagePath(path)
	self.m_RawImagePath = path
	self:updateDesignSet()

	return self
end

function Blip:getPosition(vec)
	return vec and Vector3(self.m_WorldX, self.m_WorldY, self.m_WorldZ or 0) or self.m_WorldX, self.m_WorldY, self.m_WorldZ
end

function Blip:setPosition(x, y, z)
	self.m_WorldX, self.m_WorldY, self.m_WorldZ = x, y, z or false

	return self
end

function Blip:setZ(z)
	self.m_WorldZ = z
end

function Blip:getZ()
	return self.m_WorldZ
end

function Blip:getSize()
	return self.m_Size
end

function Blip:setSize(size)
	self.m_Size = size

	return self
end

function Blip:getStreamDistance()
	return self.m_StreamDistance
end

function Blip:setStreamDistance(distance)
	self.m_StreamDistance = distance

	return self
end

function Blip:updateDesignSet()
	self.m_ImagePath = HUDRadar:getSingleton():makePath(self.m_RawImagePath, true)
end

function Blip:setColor(color)
	self.m_Color = color and tocolor(unpack(color))

	return self
end

function Blip:getColor()
	return self.m_Color
end

function Blip:setOptionalColor(color)
	self.m_OptionalColor = color and tocolor(unpack(color))

	return self
end

function Blip:getOptionalColor()
	return self.m_OptionalColor
end


function Blip:attachTo(element)
	if Blip.AttachedBlips[self] then table.remove(Blip.AttachedBlips, table.find(self)) end
	Blip.AttachedBlips[self] = element
end

function Blip:attach(element)
	return self:attachTo(element)
end

function Blip:getAttachedElement()
	return Blip.AttachedBlips[self]
end

function Blip:detach()
	if Blip.AttachedBlips[self] then
		Blip.AttachedBlips[self] = nil
	end
end

function Blip:setDisplayText(text, category)
	if text and not self.m_DisplayText then 
		local category = category or BLIP_CATEGORY.Default
		self.m_DisplayText = text
		self.m_Category = category
		
		if not Blip.DisplayTexts[category] then Blip.DisplayTexts[category] = {} end
		if not Blip.DisplayTexts[category][text] then Blip.DisplayTexts[category][text] = {} end
		table.insert(Blip.DisplayTexts[category][text], self)

		CustomF11Map:getSingleton():updateBlipList()
	end
end

function Blip:getDisplayText()
	return self.m_DisplayText, self.m_Category
end

function Blip.getDefaultSize()
	return 24
end

function Blip.setScaleMultiplier(scale) --F2 setting
	Blip.ms_ScaleMultiplier = scale + 0.5
	core:set("HUD","blipScale",scale + 0.5)
end

function Blip.getScaleMultiplier() 
	if not Blip.ms_ScaleMultiplier then
		Blip.ms_ScaleMultiplier = core:get("HUD","blipScale", 1)
	end
	return Blip.ms_ScaleMultiplier
end

--[[
	data[v.m_Id] = {
			icon 			= v.m_ImagePath,
			x 				= v.m_PosX,
			y 				= v.m_PosY,
			streamDistance 	= v.m_StreamDistance,
			color 			= v.m_Color,
			displayText 	= v.m_DisplayText,
			category 		= v.m_Category,
			attachedElement = v.m_AttachedTo,
		}
	end
]]

function Blip.updateFromServer(id, data)
	if not Blip.ServerBlips[id] then
		Blip.ServerBlips[id] = Blip:new(data.icon, data.x, data.y, data.streamDistance, data.color, data.optionalColor)
	end

	if data.destroy then
		delete(Blip.ServerBlips[id])
		Blip.ServerBlips[id] = nil
		return
	end
	if data.x and data.y then
		Blip.ServerBlips[id]:setPosition(data.x, data.y, data.z)
	elseif data.z then
		Blip.ServerBlips[id]:setZ(data.z)
	end
	if data.optionalColor then
		Blip.ServerBlips[id]:setOptionalColor(data.optionalColor)
	end
	if data.color then
		Blip.ServerBlips[id]:setColor(data.color)
	end
	if data.streamDistance then 
		Blip.ServerBlips[id]:setStreamDistance(data.streamDistance)
	end
	if data.displayText then
		Blip.ServerBlips[id]:setDisplayText(data.displayText, data.category)
	end
	if data.attachedElement then 
		Blip.ServerBlips[id]:attach(data.attachedElement)
	elseif data.detach then
		Blip.ServerBlips[id]:detach()
	end
end

addEventHandler("blipCreate", root,
	function(id, data)
		Blip.updateFromServer(id, data)
	end
)

addEventHandler("blipUpdate", root,
	function(id, data)
		Blip.updateFromServer(id, data)
	end
)

addEventHandler("blipDestroy", root,
	function(id, data)
		Blip.updateFromServer(id, data)
	end
)

addEventHandler("blipsRetrieve", root,
	function(data)
		for id, v in pairs(data) do
			Blip.updateFromServer(id, v)
		end
	end
)