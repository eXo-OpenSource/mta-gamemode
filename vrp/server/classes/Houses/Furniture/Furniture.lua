-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/Furniture/Furniture.lua
-- *  PURPOSE:     Furnitures base class
-- *
-- ****************************************************************************
Furniture = inherit(Object)

function Furniture:constructor(owner, model, position, rotation, dimension, interior)
	self.m_Element = false
	self.m_Owner = owner
	self.m_Model = model
	self.m_Position = position
	self.m_Rotation = rotation
	self.m_Dimension = dimension
	self.m_Interior = interior
end

function Furniture:destructor()
	if self.m_Element then
		self.m_Element:destroy()
	end
end

function Furniture:load()
	if self.m_Element then return false end
	self.m_Element = createObject(self.m_Model, self.m_Position, self.m_Rotation, false)
end

function Furniture:unload()
	if not self.m_Element then return false end
	self.m_Element:destroy()
	self.m_Element = nil
end

function Furniture:hasAccess(player)
	return self.m_Owner:isValidToEnter(player)
end

function Furniture:getObject()
	return self.m_Element
end
