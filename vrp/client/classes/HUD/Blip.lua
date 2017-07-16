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

function Blip:constructor(imagePath, worldX, worldY, streamDistance, color, color2, defaultSize, defaultColor) --quick workaround
	self.m_ID = #Blip.Blips + 1
	self.m_RawImagePath = imagePath
	self.m_ImagePath = HUDRadar:getSingleton():makePath(imagePath, true)
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_WorldZ = false
	self.m_Alpha = 255
	self.m_Size = Blip.getDefaultSize()
	self.m_StreamDistance = streamDistance or 100
	self.m_DefaultSize = defaultSize or 2
	self.m_DefaultColor = defaultColor or {255,0,0,255}
	if color then
	self.m_Color = tocolor(color)
	elseif color2 then
	self.m_Color = color2
	else
	self.m_Color = tocolor(255, 255, 255, 255)
	end

	Blip.Blips[self.m_ID] = self

	HUDRadar:syncBlips()
end

function Blip:destructor()
	if self.m_ID and Blip.Blips[self.m_ID] then

		self:detach()
		Blip.Blips[self.m_ID] = nil

	else
		local index = table.find(Blip.Blips, self)
		if index then
			self:detach()
			Blip.Blips[index] = nil
		end
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

function Blip:getPosition()
  return self.m_WorldX, self.m_WorldY, self.m_WorldZ
end

function Blip:setPosition(x, y, z)
  self.m_WorldX, self.m_WorldY, self.m_WorldZ = x, y, z or false

  return self
end

function Blip:getAlpha()
  return self.m_Alpha
end

function Blip:setAlpha(alpha)
  self.m_Alpha = alpha

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
  self.m_Color = color

  return self
end

function Blip:getColor()
  return self.m_Color
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

function Blip.getDefaultSize()
	return 24
end

function Blip.setScaleMultiplier(scale) 
	Blip.ms_ScaleMultiplier = scale + 0.5
	core:set("HUD","blipScale",scale + 0.5)
end

function Blip.getScaleMultiplier() 
	if not Blip.ms_ScaleMultiplier then
		Blip.ms_ScaleMultiplier = core:get("HUD","blipScale", 1)
	end
	return Blip.ms_ScaleMultiplier
end

addEvent("blipCreate", true)
addEventHandler("blipCreate", root,
  function(index, path, x, y, streamDistance)
    outputDebug("Creating blip: "..path.." - ID:"..tostring(index))
    Blip.ServerBlips[index] = Blip:new(path, x, y, streamDistance)
  end
)

addEvent("blipDestroy", true)
addEventHandler("blipDestroy", root,
  function(index)
    if Blip.ServerBlips[index] then
	  outputDebug("Destroying blip: "..Blip.ServerBlips[index].m_RawImagePath.." - ID:"..tostring(index))
	  delete(Blip.ServerBlips[index])
      Blip.ServerBlips[index] = nil
    end
  end
)

addEvent("blipsRetrieve", true)
addEventHandler("blipsRetrieve", root,
  function(data, attached)
    for id, v in pairs(data) do
		if not Blip.ServerBlips[id] then
	  		Blip.ServerBlips[id] = Blip:new(unpack(v))
		end
    end
	if attached then
		for id, element in pairs(attached) do
			if Blip.ServerBlips[id] then
				Blip.ServerBlips[id]:attachTo(element)
			end
		end
	end
  end
)

addEvent("blipAttach", true)
addEventHandler("blipAttach", root,
  function(index, element)
    if Blip.ServerBlips[index] then
      outputDebug("Attached blip: "..tostring(index))
      Blip.ServerBlips[index]:attachTo(element)
    end
  end
)
