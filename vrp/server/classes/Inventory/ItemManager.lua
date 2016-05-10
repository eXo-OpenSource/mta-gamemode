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
		["Radio"] = ItemRadio,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
		["Burger"] = ItemFood,
		["Pizza"] = ItemFood,
		["Pilz"] = ItemFood,
		["Wuerfel"] = ItemDice
	}

	for name, class in pairs(self.m_ClassItems) do
		local instance = class:new()
		instance:setName(name)
		instance:loadItem()
		ItemManager.Map[name] = instance
	end
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getInstance(itemName)
	return ItemManager.Map[itemName]
end
