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

function Blip:constructor(imagePath, worldX, worldY, streamDistance, color)
  self.m_ID = #Blip.Blips + 1
  self.m_RawImagePath = imagePath
  self.m_ImagePath = HUDRadar:getSingleton():makePath(imagePath, true)
  self.m_WorldX = worldX
  self.m_WorldY = worldY
  self.m_Alpha = 255
  self.m_Size = 24
  self.m_StreamDistance = streamDistance or 800

  if color then
    self.m_Color = tocolor(color)
  else
    self.m_Color = tocolor(255, 255, 255, 255)
  end

  Blip.Blips[self.m_ID] = self
  local m_String = BlipConversion[imagePath]
  if m_String then
    self.DefaultBlips[self.m_ID] = createBlip( worldX, worldY, 1,m_String, 1, 255, 255, 255, 255, 0, streamDistance)
  end
end

function Blip:destructor()
  if self.m_ID and Blip.Blips[self.m_ID] then
    Blip.Blips[self.m_ID]:dettach()
    Blip.Blips[self.m_ID] = nil
    if self.DefaultBlips[self.m_ID] then
      destroyElement( self.DefaultBlips[self.m_ID] )
    end
  else
    local index = table.find(Blip.Blips, self)
    if index then
      Blip.Blips[idx]:dettach()
      Blip.Blips[idx] = nil
      if self.DefaultBlips[idx] then
        destroyElement( self.DefaultBlips[idx] )
      end
    end
  end

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
  return self.m_WorldX, self.m_WorldY
end

function Blip:setPosition(x, y)
  self.m_WorldX, self.m_WorldY = x, y

  return self
end

function Blip:getAlpha()
  return self.m_Alpha
end

function Blip:setAlpha(alpha)
  self.m_Alpha = alpha

  return self
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

function Blip:dettach()
  if Blip.AttachedBlips[self] then
    Blip.AttachedBlips[self] = nil
  end
end

addEvent("blipCreate", true)
addEventHandler("blipCreate", root,
  function(index, path, x, y, streamDistance)
    outputDebug("Creating blip: "..tostring(index))
    Blip.ServerBlips[index] = Blip:new(path, x, y, streamDistance)
  end
)

addEvent("blipDestroy", true)
addEventHandler("blipDestroy", root,
  function(index)
    if Blip.ServerBlips[index] then
      outputDebug("Destroying blip: "..tostring(index))
      delete(Blip.ServerBlips[index])
      Blip.ServerBlips[index] = nil
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

addEvent("blipAttach", true)
addEventHandler("blipAttach", root,
  function(index, element)
    if Blip.ServerBlips[index] then
      outputDebug("Attached blip: "..tostring(index))
      Blip.ServerBlips[index]:attachTo(element)
    end
  end
)
