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
Blip.DefaultBlips = {}
Blip.AttachedBlips = {}

function Blip:constructor(imagePath, worldX, worldY, streamDistance, color, color2, defaultSize, defaultColor) --quick workaround
	self.m_ID = #Blip.Blips + 1
	self.m_RawImagePath = imagePath
	self.m_ImagePath = HUDRadar:getSingleton():makePath(imagePath, true)
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_WorldZ = false
	self.m_Alpha = 255
	self.m_Size = 24
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

	local m_String = BlipConversion[imagePath]
	if m_String and type(m_String) == "number" then
		Blip.DefaultBlips[self.m_ID] = createBlip(worldX, worldY, 1,m_String, 1, 255, 255, 255, 255, 0, streamDistance)
	else
		outputDebug("Missing Standard Blip for "..imagePath)
	end

	HUDRadar:syncBlips()
end

function Blip:destructor()
	if self.m_ID and Blip.Blips[self.m_ID] then

		self:detach()
		Blip.Blips[self.m_ID] = nil

		if Blip.DefaultBlips[self.m_ID] then
		  destroyElement(Blip.DefaultBlips[self.m_ID] )
		end
	else
		local index = table.find(Blip.Blips, self)
		if index then
			self:detach()
			Blip.Blips[index] = nil
			if isElement(Blip.DefaultBlips[index] ) then
				destroyElement( Blip.DefaultBlips[index] )
				Blip.DefaultBlips[index] = nil
			end
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
  if isElement(Blip.DefaultBlips[self.m_ID] ) then
	Blip.DefaultBlips[self.m_ID] = nil
	local r,g,b,a = unpack(self.m_DefaultColor)
	if isElement(Blip.DefaultBlips[self.m_ID]) then destroyElement(Blip.DefaultBlips[self.m_ID]) end
	Blip.DefaultBlips[self.m_ID] = createBlipAttachedTo(element,0,self.m_DefaultSize,r,g,b,a)
  end
end

function Blip:getAttachedElement()
	return Blip.AttachedBlips[self]
end

function Blip:detach()
	if Blip.AttachedBlips[self] then
	  	Blip.AttachedBlips[self] = nil
		if isElement(Blip.DefaultBlips[self.m_ID]) then
			detachElements(Blip.DefaultBlips[self.m_ID])
		end
	end
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
