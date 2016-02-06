-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/ItemManager.lua
-- *  PURPOSE:     Item manager class
-- *
-- ****************************************************************************
ItemManager = inherit(Singleton)

function ItemManager:constructor()
	self.m_ClassItems = {
		["Barrikade"] = ItemBarricade
	}

	for name, class in pairs(self.m_ClassItems) do
		class:new()
		class:setName(name)
		class:loadItem()
	end
end

function ItemManager:getFromName(itemName)
	return self.m_ClassItems[itemName]
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end
