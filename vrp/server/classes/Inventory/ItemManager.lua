-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/ItemManager.lua
-- *  PURPOSE:     Item manager class
-- *
-- ****************************************************************************
ItemManager = inherit(Singleton)
addRemoteEvents{"onClientBreakItem"}

function ItemManager.get(name)
	local id = ItemManager.getId(name)
	return ItemManager:getSingleton().m_Items[id]
end

function ItemManager.getId(name)
	if type(name) == "string" then
		return ItemManager:getSingleton().m_ItemIdToName[name]
	end
	return name
end

function ItemManager.getById(id)
	return ItemManager:getSingleton().m_Items[id]
end

function ItemManager:constructor()
	self.m_Items = {}
	self.m_ItemIdToName = {}
	self.m_Categories = {}
	self.m_CategoryIdToName = {}

	self:loadItems()
	self:loadCategories()

	addEventHandler("onClientBreakItem", root, bind(self.Event_onItemBreak,self))
end

function ItemManager:destructor()
end

function ItemManager:loadItems()
	local result = sql:queryFetch("SELECT i.*,c.TechnicalName AS Category, c.Name AS CategoryName FROM ??_items i INNER JOIN ??_item_categories c ON c.Id = i.CategoryId", sql:getPrefix(), sql:getPrefix())
	self.m_Items = {}
	self.m_ItemIdToName = {}

	for _, row in ipairs(result) do
		self.m_Items[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			CategoryId = row.CategoryId;
			Category = row.Category;
			CategoryName = row.CategoryName;
			Class = row.Class;
			Name = row.Name;
			Description = row.Description;
			Icon = row.Icon;
			Size = row.Size;
			ModelId = row.ModelId;
			MaxDurability = row.MaxDurability;
			DurabilityDestroy = row.DurabilityDestroy == 1;
			Consumable = row.Consumable == 1;
			Tradeable = row.Tradeable == 1;
			Expireable = row.Expireable == 1;
			IsUnique = row.IsUnique == 1;
			IsStackable = row.IsStackable == 1;
			Throwable = row.Throwable == 1;
			Breakable = row.Breakable == 1;
		}

		self.m_ItemIdToName[row.TechnicalName] = row.Id
	end
end

function ItemManager:loadCategories()
	local result = sql:queryFetch("SELECT * FROM ??_item_categories", sql:getPrefix())
	self.m_Categories = {}
	self.m_CategoryIdToName = {}

	for _, row in ipairs(result) do
		self.m_Categories[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			Name = row.Name;
		}

		self.m_CategoryIdToName[row.TechnicalName] = row.Id
	end
end

function ItemManager:Event_onItemBreak()
	if source and isElement(source) then
		if source.m_Super and source.m_Super.m_Breakable then
			delete(source.m_Super)
		end
	end
end

--[[
ItemManager = inherit(Singleton)
ItemManager.Map = {}

function ItemManager:constructor()
	addRemoteEvents{"onClientBreakItem"}
	self.m_ClassItems = {
--		["Keypad"] = ItemKeyPad,
		["Tor"] = ItemDoor,
		["Einrichtung"] = ItemFurniture,
		["Eingang"] = ItemEntrance,
		["Transmitter"] = ItemTransmitter,
		["Barrikade"] = ItemBarricade,
		["Warnkegel"] = ItemBarricade,
		["Sky Beam"] = ItemSkyBeam,
		["Blitzer"] = ItemSpeedCam,
		["Nagel-Band"] = ItemNails,
		["Radio"] = ItemRadio,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
--		["Burger"] = ItemFood,
--		["Lebkuchen"] = ItemFood,
--		["Wuerstchen"] = ItemFood,

--		["Kuheuter mit Pommes"] = ItemFood,
--		["Zombie-Burger"] = ItemFood,
--		["Suessigkeiten"] = ItemFood,
--		["Zuckerstange"] = ItemFood,
--		["Pizza"] = ItemFood,
--		["Pilz"] = ItemFood,
--		["Zigarette"] = ItemFood,
--		["Donut"] = ItemFood,
--		["Keks"] = ItemFood,
--		["Apfel"] = ItemFood,
--		["KöderDummy"] = ItemFood,
		["Donutbox"] = ItemDonutBox,
		["Osterei"] = ItemEasteregg;
		["Kürbis"] = ItemPumpkin;
		["Taser"] = ItemTaser;
		["SLAM"] = ItemSlam;
		["Rauchgranate"] = ItemSmokeGrenade;
		["DefuseKit"] = ItemDefuseKit;

		["Bambusstange"] = ItemFishing,
		["Angelrute"] = ItemFishing,
		["Profi Angelrute"] = ItemFishing,
		["Legendäre Angelrute"] = ItemFishing,
		["Kleine Kühltasche"] = ItemFishing,
		["Kühltasche"] = ItemFishing,
		["Kühlbox"] = ItemFishing,
		["Köder"] = ItemFishing,
		["Leuchtköder"] = ItemFishing,
		["Pilkerköder"] = ItemFishing,
		["Schwimmer"] = ItemFishing,
		["Spinner"] = ItemFishing,
		["Fischlexikon"] = ItemFishing,

		["Wuerfel"] = ItemDice,
		["Weed-Samen"] = Plant,
		["Apfelbaum-Samen"] = Plant,
		["Blumen-Samen"] = Plant,
		["Kanne"] = ItemCan,
		["Handelsvertrag"] = ItemSellContract,
		["Ausweis"] = ItemIDCard,
		["Benzinkanister"] = ItemFuelcan,
		["Reparaturkit"] = ItemRepairKit,
		["Medikit"] = ItemHealpack,
		--Alcohol
		["Bier"] = ItemAlcohol,
		["Whiskey"] = ItemAlcohol,
		["Sex on the Beach"] = ItemAlcohol,
		["Pina Colada"] = ItemAlcohol,
		["Monster"] = ItemAlcohol,
		["Shot"] = ItemAlcohol,
		["Cuba-Libre"] = ItemAlcohol,
		["Gluehwein"] = ItemAlcohol,

		--Firework
		["Rakete"] = ItemFirework,
		["Rohrbombe"] = ItemFirework,
		["Raketen Batterie"] = ItemFirework,
		["Römische Kerze"] = ItemFirework,
		["Römische Kerzen Batterie"] = ItemFirework,
		["Kugelbombe"] = ItemFirework,
		["Böller"] = ItemFirework,

		--//Wearables
		["Helm"] = WearableHelmet,
		["Motorcross-Helm"] = WearableHelmet,
		["Pot-Helm"] = WearableHelmet,
		["Gasmaske"] = WearableHelmet,
		["Stern"] = WearableHelmet,
		["Einsatzhelm"] = WearableHelmet,
		["Hasenohren"] = WearableHelmet,
		["Weihnachtsmütze"] = WearableHelmet,
		["Kevlar"] = WearableShirt,
		["Tragetasche"] = WearableShirt,
		["Swatschild"] = WearablePortables,
		["Kleidung"] = WearableClothes,

	}

	self.m_Properties = {
		["Barrikade"] = {true}, --// breakable,
		["Warnkegel"] = {true}, --// breakable,
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

function ItemManager:updateOnQuit()

end

function ItemManager:Event_onItemBreak()
	if source and isElement(source) then
		if source.m_Super and source.m_Super.m_Breakable then
			delete(source.m_Super)
		end
	end
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getInstance(itemName)
	return ItemManager.Map[itemName]
end
]]
