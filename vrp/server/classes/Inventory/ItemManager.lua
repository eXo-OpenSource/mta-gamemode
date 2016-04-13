-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/ItemManager.lua
-- *  PURPOSE:     Item manager class
-- *
-- ****************************************************************************
ItemManager = inherit(Singleton)
ItemManager.Map = {}

function ItemManager:constructor()
	self.m_ClassItems = {
		["Barrikade"] = ItemBarricade,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
		["Burger"] = ItemFood
	}

	for name, class in pairs(self.m_ClassItems) do
		local instance = class:new()
		instance:setName(name)
		instance:loadItem()
		ItemManager.Map[name] = instance
	end
end

function ItemManager:getFromName(itemName)
	return self.m_ClassItems[itemName]
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getClass(itemName)
	return ItemManager.Map[itemName]
end
