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
	addRemoteEvents{"onClientBreakItem"}
	self.m_ClassItems = {
		["Barrikade"] = ItemBarricade,
		["Blitzer"] = ItemSpeedCam,
		["Nagel-Band"] = ItemNails,
		["Radio"] = ItemRadio,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
		["Burger"] = ItemFood,
		["Pizza"] = ItemFood,
		["Pilz"] = ItemFood,
		["Zigarette"] = ItemFood,
		["Wuerfel"] = ItemDice,
		["Weed-Samen"] = PlantWeed,
		["Kanne"] = ItemCan,
		["Handelsvertrag"] = ItemSellContract,
		["Ausweis"] = ItemIDCard,
		["Benzinkanister"] = ItemFuelcan,
		["Reparaturkit"] = ItemRepairKit,
		["Bier"] = ItemAlcohol
	}

	self.m_Properties = {
	["Barrikade"] = {true} --// breakable,
}
	self.m_SpecialItems = {
		["Mautpass"] = true,
		["Kanne"] = true
	}

	for name, class in pairs(self.m_ClassItems) do
		local breakable = false
		if self.m_Properties[name] then
			breakable = true
		end
		local instance = class:new( )
		instance:setName(name)
		instance:loadItem()
		instance.m_Breakable = breakable
		ItemManager.Map[name] = instance
	end
	addEventHandler("onClientBreakItem",root, bind(self.Event_onItemBreak,self))
end

function ItemManager:Event_onItemBreak(wObj)
	if client then
		if wObj then
			if wObj.m_Super then
				if wObj.m_Super.m_Breakable then
					delete( wObj.m_Super )
				end
			end
		end
	end
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getInstance(itemName)
	return ItemManager.Map[itemName]
end
