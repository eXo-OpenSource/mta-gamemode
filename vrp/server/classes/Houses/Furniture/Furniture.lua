-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/Furniture/Furniture.lua
-- *  PURPOSE:     Furnitures base class
-- *
-- ****************************************************************************
Furniture = inherit(Object)

function Furniture:constructor(owner, item, model, position, rotation, dimension, interior, data)
	self.m_WorldItem = false
	self.m_Owner = owner
	self.m_Model = model
	self.m_Position = position
	self.m_Rotation = rotation
	self.m_Dimension = dimension
	self.m_Interior = interior
	self.m_Item = item
	--self.m_DataHolder = ItemHolder:new(data)
end

function Furniture:destructor()
	--[[ gets called automatically
	if self.m_WorldItem then
		delete(self.m_WorldItem)
	end
	--]]
end

function Furniture:isInside()
	return true
end

function Furniture:load()
	if self.m_WorldItem then return false end
	self.m_WorldItem = FurnitureWorldItem:new(self.m_Item, self.m_Owner, self.m_Position, self.m_Rotation, false, {getName = function() return self.m_Owner:getName() end})
	self.m_WorldItem:setFurnitureInstance(self)

	local object = self.m_WorldItem:getObject()
	object:setDimension(self.m_Dimension)
	object:setInterior(self.m_Interior)
end

function Furniture:unload()
	if not self.m_WorldItem then return false end
	delete(self.m_WorldItem)
	self.m_WorldItem = false
end

function Furniture:setPosition(position)
	self.m_Position = position
end

function Furniture:setRotation(rotation)
	self.m_Rotation = rotation
end

function Furniture:forceUpdate() -- must be called after movement, otherwise the object is invisible
	if self.m_WorldItem then
		local object = self.m_WorldItem:getObject()
		object:setDimension(0)
		object:setInterior(0)

		nextframe(function()
			object:setDimension(self.m_Dimension)
			object:setInterior(self.m_Interior)
		end)
	end
end

function Furniture:hasAccess(player)
	return self.m_Owner:isValidToEnter(player)
end

function Furniture:getObject()
	return self.m_WorldItem:getObject()
end
