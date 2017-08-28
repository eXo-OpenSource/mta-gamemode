-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/Furniture/OutdoorFurnitureCollection.lua
-- *  PURPOSE:     OutdoorFurnitureCollection class
-- *
-- ****************************************************************************
OutdoorFurnitureCollection = inherit(IndoorFurnitureCollection)

function OutdoorFurnitureCollection:constructor()
	IndoorFurnitureCollection.constructor(self)
	self:onStreamIn()
end

function OutdoorFurnitureCollection:onStreamIn()
	self:increment()
end

function OutdoorFurnitureCollection:onStreamOut()
	self:decrement()
end

addEvent("outdoorFurnitureStreamIn", true)
addEventHandler("outdoorFurnitureStreamIn", root,
	function()
		if source.m_Super and instanceof(source.m_Super, House, true) then
			source.m_Super.m_OutdoorFurniture:onStreamIn()
		end
	end
)
addEvent("outdoorFurnitureStreamOut", true)
addEventHandler("outdoorFurnitureStreamOut", root,
	function()
		if source.m_Super and instanceof(source.m_Super, House, true) then
			source.m_Super.m_OutdoorFurniture:onStreamOut()
		end
	end
)
