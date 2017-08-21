FurnitureWorldItem = inherit(WorldItem)

function FurnitureWorldItem:setFurnitureInstance(instance)
	self.m_FurnitureInstance = instance
end

function FurnitureWorldItem:hasPlayerPermissionTo(player, action)
	if WorldItem.hasPlayerPermissionTo(self, player, action) then return true end -- check for admin
	return self.m_FurnitureInstance:hasAccess(player)
end

function FurnitureWorldItem:onCollect(...)
	local result = WorldItem.onCollect(self, ...)
	if self.m_FurnitureInstance:isInside() then
		self.m_FurnitureInstance.m_Owner:removeInsideFurniture(self.m_Object)
	end

	return result
end

function FurnitureWorldItem:onDelete(...)
	local result = WorldItem.onDelete(self, ...)
	if self.m_FurnitureInstance:isInside() then
		self.m_FurnitureInstance.m_Owner:removeInsideFurniture(self.m_Object)
	end

	return result
end

function FurnitureWorldItem:onMove(...)
	return WorldItem.onMove(self, ..., function(position, rotation)
		self.m_FurnitureInstance:setPosition(position)
		self.m_FurnitureInstance:setRotation(rotation)
		self.m_FurnitureInstance:forceUpdate()
	end)
end
