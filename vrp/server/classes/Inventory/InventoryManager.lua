-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

function InventoryManager:constructor()

	self.m_Slots={
		["Items"] = 14,
		["Objekte"] = 3,
		["Essen"] = 5,
		["Drogen"] = 7,
	}

	self.m_ItemData = {}
	self.m_ItemData = self:loadItems()
	self.Map = {}

	addRemoteEvents{"changePlaces", "onPlayerItemUseServer", "onPlayerSecondaryItemUseServer", "c_stackItems", "throwItem", "c_setItemPlace", "refreshInventory", "requestTrade", "acceptItemTrade", "acceptWeaponTrade", "declineTrade","syncAfterChange"}
	addEventHandler("changePlaces", root, bind(self.Event_changePlaces, self))
	addEventHandler("onPlayerItemUseServer", root, bind(self.Event_onItemUse, self))
	addEventHandler("onPlayerSecondaryItemUseServer", root, bind(self.Event_onItemSecondaryUse, self))
	addEventHandler("c_stackItems", root, bind(self.Event_c_stackItems, self))
	addEventHandler("throwItem", root, bind(self.Event_throwItem, self))
	addEventHandler("c_setItemPlace", root, bind(self.Event_c_setItemPlace, self))
	addEventHandler("refreshInventory", root, bind(self.Event_refreshInventory, self))
	addEventHandler("requestTrade", root, bind(self.Event_requestTrade, self))
	addEventHandler("acceptItemTrade", root, bind(self.Event_acceptItemTrade, self))
	addEventHandler("acceptWeaponTrade", root, bind(self.Event_acceptWeaponTrade, self))
	addEventHandler("declineTrade", root, bind(self.Event_declineTrade, self))
	--/workaround/
	addEventHandler("syncAfterChange", root, bind(self.Event_syncAfterChange, self))

	WearableManager:new()
end

function InventoryManager:destructor()

end

function InventoryManager:getItemData()
	return self.m_ItemData
end

function InventoryManager:getItemDataForItem(itemName)
	return self.m_ItemData[itemName]
end

function InventoryManager:Event_syncAfterChange()
	if client then
		self:getPlayerInventory(client):syncClient()
	end
end

function InventoryManager:loadItems()
	local result = sql:queryFetch("SELECT * FROM ??_inventory_items", sql:getPrefix())
	local itemData = {}
	local itemName
	for i, row in ipairs(result) do
		itemName = row["Objektname"]
		itemData[itemName] = {}
		itemData[itemName]["Name"] = itemName
		itemData[itemName]["Info"] = row["Info"]
		itemData[itemName]["Tasche"] = row["Tasche"]
		itemData[itemName]["Icon"] = row["Icon"]
		itemData[itemName]["Item_Max"] = tonumber(row["max_items"])
		itemData[itemName]["Wegwerf"] = tonumber(row["wegwerfen"])
		itemData[itemName]["Handel"] = tonumber(row["Handel"])
		itemData[itemName]["Stack_max"] = tonumber(row["stack_max"])
		itemData[itemName]["Verbraucht"] = tonumber(row["verbraucht"])
		itemData[itemName]["ModelID"] = tonumber(row["ModelID"])
	end

	return itemData
end

function InventoryManager:loadInventory(player)
	if not self.Map[player] then
		local instance = Inventory:new(player, self.m_Slots, self.m_ItemData,ItemManager:getSingleton():getClassItems())
		self.Map[player] = instance
		return instance
	end
end

function InventoryManager:deleteInventory(player)
	self.Map[player] = nil
end

function InventoryManager:getPlayerInventory(player)
	if self.Map[player] then
		return self.Map[player]
	end
	return false
end

function InventoryManager:Event_changePlaces(bag, oPlace, nPlace)
	self:getPlayerInventory(client):changePlaces(bag, oPlace, nPlace)
end


function InventoryManager:Event_onItemUse(itemid, bag, itemName, place, delete)
	self:getPlayerInventory(client):useItem(itemid, bag, itemName, place, delete)
end

function InventoryManager:Event_onItemSecondaryUse(itemid, bag, itemName, place)
	self:getPlayerInventory(client):useItemSecondary(itemid, bag, itemName, place)
end

function InventoryManager:Event_c_stackItems(newId, oldId, oldPlace)
	self:getPlayerInventory(client):c_stackItems(newId, oldId, oldPlace)
end


function InventoryManager:Event_c_setItemPlace(bag, oldPlace, newPlace)
	self:getPlayerInventory(client):c_setItemPlace(bag, oldPlace, newPlace)
end


function InventoryManager:Event_throwItem(item, bag, id, place, name)
	self:getPlayerInventory(client):throwItem(item, bag, id, place, name)
end

function InventoryManager:Event_refreshInventory()
	self:getPlayerInventory(client):syncClient()
end

function InventoryManager:Event_requestTrade(type, target, item, amount, money)
	if (client:getPosition() - target:getPosition()).length > 10 then
		client:sendError(_("Du bist zuweit von %s entfernt!", client, target.name))
		return false
	end

	if type == "Item" then
		if self:getPlayerInventory(client):getItemAmount(item) >= amount then
			local text = _("%s möchte dir %d %s schenken! Geschenk annehmen?", target, client.name, amount, item)
			if money and money > 0 then
				text = _("%s möchte dir %d %s für %d$ verkaufen! Handel annehmen?", target, client.name, amount, item, money)
			end
			target:triggerEvent("questionBox", text, "acceptItemTrade", "declineTrade", client, target, item, amount, money)
		else
			client:sendError(_("Du hast nicht ausreichend %s!", client, item))
		end
	elseif type == "Weapon" then
		if client.disableWeaponStorage then
			client:sendError(_("Du darfst diese Waffe nicht handeln!", client))
			return
		end
		if client:getFaction() and client:isFactionDuty() then
			client:sendError(_("Du darfst im Dienst keine Waffen weitergeben!", client))
			return
		end

		if target:getWeaponLevel() < MIN_WEAPON_LEVELS[item] then
			client:sendError(_("Das Waffenlevel von %s ist zu niedrig! (Benötigt: %i)", client, target.name, MIN_WEAPON_LEVELS[item]))
			target:sendError(_("Dein Waffenlevel ist zu niedrig! (Benötigt: %i)", target, MIN_WEAPON_LEVELS[item]))
			return
		end

		local text = _("%s möchte dir eine/n %s mit %d Schuss schenken! Geschenk annehmen?", target, client.name, WEAPON_NAMES[item], amount)
		if money and money > 0 then
			text = _("%s möchte dir eine/n %s mit %d Schuss für %d$ verkaufen! Handel annehmen?", target, client.name, WEAPON_NAMES[item], amount, money)
		end
		target:triggerEvent("questionBox", text, "acceptWeaponTrade", "declineTrade", client, target, item, amount, money)
	end
end

function InventoryManager:Event_declineTrade(player, target, item, amount, money)
	target:sendError(_("Du hast das Angebot von %s abglehent!", target, player:getName()))
	player:sendError(_("%s hat den Handel abglehent!", player, target:getName()))
end

function InventoryManager:Event_acceptItemTrade(player, target, item, amount, money)
	if (player:getPosition() - target:getPosition()).length > 10 then
		player:sendError(_("Du bist zuweit von %s entfernt!", player, target.name))
		target:sendError(_("Du bist zuweit von %s entfernt!", target, player.name))
		return false
	end

	if self:getPlayerInventory(player):getItemAmount(item) >= amount then
		if target:getMoney() >= money then
			player:sendInfo(_("%s hat den Handel akzeptiert!", player, target:getName()))
			target:sendInfo(_("Du hast das Angebot von %s akzeptiert und erhälst %d %s für %d$!", target, player:getName(), amount, item, money))
			self:getPlayerInventory(player):removeItem(item, amount)
			self:getPlayerInventory(target):giveItem(item, amount)
			target:takeMoney(money, "Handel")
			player:giveMoney(money, "Handel")
			StatisticsLogger:getSingleton():itemTradeLogs( player, target, item, money)
		else
			player:sendError(_("%s hat nicht ausreichend Geld (%d$)!", player, target:getName(), money))
			target:sendError(_("Du hast nicht ausreichend Geld (%d$)!", target, money))
		end
	else
		target:sendError(_("%s hat nicht mehr ausreichend %s!", target, player:getName(), item))
		player:sendError(_("Du hast nicht mehr ausreichend %s!", player, item))
	end
end

function InventoryManager:Event_acceptWeaponTrade(player, target, weaponId, amount, money)
	if (player:getPosition() - target:getPosition()).length > 10 then
		player:sendError(_("Du bist zuweit von %s entfernt!", player, target.name))
		target:sendError(_("Du bist zuweit von %s entfernt!", target, player.name))
		return false
	end

	if player:getFaction() and player:isFactionDuty() then
		player:sendError(_("Du darfst im Dienst keine Waffen weitergeben!", player))
		return
	end

	if player.disableWeaponStorage then
		player:sendError(_("Du darfst diese Waffe nicht handeln!", player))
		return
	end

	local weaponSlot = getSlotFromWeapon(weaponId)
	if player:getWeapon(weaponSlot) > 0 then
		if player:getTotalAmmo(weaponSlot) >= amount then
			if target:getMoney() >= money then
				player:sendInfo(_("%s hat den Handel akzeptiert!", player, target:getName()))
				target:sendInfo(_("Du hast das Angebot von %s akzeptiert und erhälst eine/n %s mit %d Schuss für %d$!", target, player:getName(), WEAPON_NAMES[weaponId], amount, money))
				player:takeWeapon(weaponId)
				target:giveWeapon(weaponId, amount)
				target:takeMoney(money, "Waffen-Handel")
				player:giveMoney(money, "Waffen-Handel")
			else
				player:sendError(_("%s hat nicht ausreichend Geld (%d$)!", player, target:getName(), money))
				target:sendError(_("Du hast nicht ausreichend Geld (%d$)!", target, money))
			end
		else
			target:sendError(_("%s hat nicht mehr ausreichend Munition!", target, player:getName()))
			player:sendError(_("Du hast nicht mehr ausreichend Munition!", player))
		end
	else
		target:sendError(_("%s hat die Waffe nicht mehr!", target, player:getName()))
		player:sendError(_("Du hast die Waffe nicht mehr!", player))
	end
end
