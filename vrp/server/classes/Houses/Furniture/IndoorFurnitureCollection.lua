-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/Furniture/IndoorFurnitureCollection.lua
-- *  PURPOSE:     IndoorFurnitureCollection class
-- *
-- ****************************************************************************
IndoorFurnitureCollection = inherit(FurnitureCollection)

function IndoorFurnitureCollection:constructor()
	self.m_Counter = 0
end

function IndoorFurnitureCollection:destructor()

end

function IndoorFurnitureCollection:increment()
	if self.m_Counter == 0 then
		self:load()
	end
	self.m_Counter = self.m_Counter + 1
end

function IndoorFurnitureCollection:decrement()
	self.m_Counter = self.m_Counter - 1
	if self.m_Counter <= 0 then
		self:unload()
		self.m_Counter = 0
	end
end
