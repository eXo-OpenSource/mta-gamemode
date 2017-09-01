-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Factions/Depot.lua
-- *  PURPOSE:     Depot class
-- *
-- ****************************************************************************
Depot = inherit(Object)
Depot.Map = {}

function Depot.initalize()
	addRemoteEvents{"itemDepotAdd", "itemDepotTake"}

	addEventHandler("itemDepotAdd", root, function(id, item, amount)
		if Depot.Map[id] then
			Depot.Map[id]:addItem(client, item, amount)
		end
	end)

	addEventHandler("itemDepotTake", root, function(id, slotId)
		if Depot.Map[id] then
			Depot.Map[id]:takeItem(client, slotId)
		end
	end)
end
--//
function Depot.load(Id, Owner, type)
	if Depot.Map[Id] then return Depot.Map[Id] end
	if Id == 0 then
		sql:queryExec("INSERT INTO ??_depot (OwnerType) VALUES (?)", sql:getPrefix(), type or "GroupProperty")
		Id = sql:lastInsertId()
		Owner:setDepotId(Id)
	end

	local row = sql:queryFetchSingle("SELECT Weapons, Items FROM ??_depot WHERE Id = ?;", sql:getPrefix(), Id)
	if not row then
		return
	end
	local weapons = row.Weapons or ""
	local items = row.Items or ""
	local DepotSave = false
	if string.len(weapons) < 5 then
		weapons = {}
		for i=1,45 do
			weapons[i] = {}
			weapons[i]["Id"] = i
			weapons[i]["Waffe"] = 0
			weapons[i]["Munition"] = 0
		end
		weapons = toJSON(weapons)
		DepotSave = true
		outputDebugString("Creating new Weapon-Table for Depot "..Id)
	end
	if string.len(items) < 5 then
		items = {}
		for i=1,6 do
			items[i] = {}
			items[i]["Item"] = 0
			items[i]["Amount"] = 0
		end
		items = toJSON(items)
		DepotSave = true
		outputDebugString("Creating new Item-Table for Depot "..Id)
	end

	Depot.Map[Id] = Depot:new(Id, weapons, items)

	if DepotSave == true then Depot.Map[Id]:save() end

	return Depot.Map[Id]
end

function Depot:constructor(Id, weapons, items)
	self.m_Id = Id
	self.m_Weapons = fromJSON(weapons)
	self.m_Items = fromJSON(items)
end

function Depot:destructor()
  self:save()
end

function Depot:save()
	return sql:queryExec("UPDATE ??_depot SET Weapons = ?, Items = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_Weapons), toJSON(self.m_Items), self.m_Id)
end

function Depot:getId()
  return self.m_Id
end

function Depot:getWeaponTable()
  return self.m_Weapons
end

function Depot:getWeapon(id)
	return self.m_Weapons[id]["Waffe"],self.m_Weapons[id]["Munition"]
end

function Depot:takeWeaponD(id,amount)
	self.m_Weapons[id]["Waffe"] = self.m_Weapons[id]["Waffe"]-amount
end

function Depot:takeMagazineD(id,amount)
	self.m_Weapons[id]["Munition"] = self.m_Weapons[id]["Munition"] - amount
end

function Depot:addWeaponD(id,amount)
	self.m_Weapons[id]["Waffe"] = self.m_Weapons[id]["Waffe"] + amount
end

function Depot:addMagazineD(id,amount)
	self.m_Weapons[id]["Munition"] = self.m_Weapons[id]["Munition"] + amount
end

function Depot:showItemDepot(player)
	player:triggerEvent("ItemDepotOpen")
	player:triggerEvent("ItemDepotRefresh", self.m_Id, self.m_Items)
end

function Depot:getPlayerWeapons(player)
	local playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(player,i) > 0 then
			playerWeapons[getPedWeapon(player,i)] = true
		end
	end
	return playerWeapons
end

function Depot:takeWeaponsFromDepot(player,weaponTable)
	local playerWeapons = self:getPlayerWeapons(player)
	outputChatBox("Du hast folgende Waffen und Magazine aus dem Lager genommen:",player,255,255,255)
	local ammoStorage = {}
	local weaponStorage = {}
	local bIsStorageWeapon = false
	local isInVariable = false
	local weaponInStorage, ammoInStorage = Guns:getWeaponInStorage( player, 2)
	local weaponBeforeEquip = getPedWeapon(player, 2)
	local ammoBeforeEquip = getPedTotalAmmo(player, 2)
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				local clipAmmo = getWeaponProperty(weaponID, "pro", "maximum_clip_ammo") or 1
				if typ == "Waffe" then
					if self.m_Weapons[weaponID]["Waffe"] >= amount then
						slot = getSlotFromWeapon(weaponID)
						if slot == 2 then
							isInVariable = false
							for i = 1, #weaponStorage do
								if weaponStorage[i] == weaponID then
									isInVariable = true
								end
							end
							if not isInVariable then
								weaponStorage[#weaponStorage+1] = weaponID
								ammoStorage[weaponID] = clipAmmo
							end
						end
						outputChatBox(amount.." "..WEAPON_NAMES[weaponID],player,255,125,0)
						giveWeapon(player,weaponID, clipAmmo)
						self:takeWeaponD(weaponID,amount)
					else
						outputChatBox("Es sind nicht genug "..WEAPON_NAMES[weaponID].." im Lager! ("..amount..")",player,255,0,0)
					end
				elseif typ == "Munition" then
					playerWeapons = self:getPlayerWeapons(player)
					if playerWeapons[weaponID] then
						if self.m_Weapons[weaponID]["Munition"] >= amount then
							self:takeMagazineD(weaponID,amount)
							bIsStorageWeapon = false
							for i = 1, #weaponStorage do
								if weaponStorage[i] == weaponID then
									bIsStorageWeapon = true
								end
							end
							if bIsStorageWeapon then
								ammoStorage[weaponID] = ammoStorage[weaponID]+amount*clipAmmo
							end
							if weaponID == 25 then amount = amount * 6 end
							if weaponID == 33 then amount = amount * 5 end
							if weaponID == 34 then amount = amount * 4 end
							giveWeapon(player, weaponID, amount*clipAmmo)
							outputChatBox(amount.." "..WEAPON_NAMES[weaponID].." Magazin/e",player,255,125,0)
						else
							outputChatBox("Es sind nicht genug "..WEAPON_NAMES[weaponID].." Magazine im Lager! ("..amount..")",player,255,0,0)
						end
					else
						outputChatBox("Du hast keine "..WEAPON_NAMES[weaponID].." für ein Magazin!",player,255,0,0)
					end
				end
			end
		end
	end
	if weaponStorage and ammoInStorage and weaponBeforeEquip and ammoBeforeEquip then
		if #weaponStorage >= 2 then
			if weaponInStorage == weaponStorage[1] then
				local weapon, ammo = getPedWeapon(player, 2)
				if weapon == weaponStorage[1] and weapon ~= weaponBeforeEquip then
					Guns:getSingleton():setWeaponInStorage(player, weaponStorage[1], ammoStorage[weaponStorage[1]])
					giveWeapon(player, weaponBeforeEquip, ammoBeforeEquip, true)
					outputChatBox("Du hast eine Zweitwaffe dabei, wechsel zwischen diesen mit Rechtsklick (Gedrückt) +X", player, 200, 200, 0)
				else
					Guns:getSingleton():setWeaponInStorage(player, weaponBeforeEquip, ammoBeforeEquip)
					giveWeapon(player, weaponStorage[1], ammoStorage[weaponStorage[1]], true)
					outputChatBox("Du hast eine Zweitwaffe dabei, wechsel zwischen diesen mit Recktsklick (Gedrückt) +X", player, 200, 200, 0)
				end
			end
		end
	elseif weaponStorage then
		if #weaponStorage >= 2 then
			outputChatBox("Du hast eine Zweitwaffe dabei, wechsel zwischen diesen mit Rechtsklick (Gedrückt) +X", player, 200, 200, 0)
			Guns:getSingleton():setWeaponInStorage(player, weaponStorage[1], ammoStorage[weaponStorage[1]])
		end
	end
	self:save()
end



function Depot:addItem(player, item, amount)
	for i=1, 6 do
		if not self.m_Items[i] then self.m_Items[i] = {} self.m_Items[i]["Item"] = 0 self.m_Items[i]["Amount"] = 0  end
		if self.m_Items[i]["Item"] == 0 then
			if player:getInventory():getItemAmount(item) >= amount then
				player:getInventory():removeItem(item, amount)
				self.m_Items[i]["Item"] = item
				self.m_Items[i]["Amount"] = amount
				player:sendInfo(_("Du hast %d %s ins Depot (Slot %d) gelegt!", player, amount, item, i))
				player:triggerEvent("ItemDepotRefresh", self.m_Id, self.m_Items)
				StatisticsLogger:getSingleton():addItemDepotLog(player, self.m_Id, item, amount)
				return
			else
				player:sendError(_("Du hast nicht genug %s!", player, item))
				return
			end
		end
	end
	player:sendError(_("Es gibt keinen freien Item-Slot in diesem Depot!", player))
end

function Depot:takeItem(player, slotId)
	if self.m_Items[slotId] then
		if self.m_Items[slotId]["Item"] ~= 0 then
			--if self.m_Items[slotId]["Amount"] > 0 then
				local item = self.m_Items[slotId]["Item"]
				local amount = self.m_Items[slotId]["Amount"]
				if player:getInventory():getFreePlacesForItem(item) >= amount then
					self.m_Items[slotId]["Item"] = 0
					self.m_Items[slotId]["Amount"] = 0
					player:getInventory():giveItem(item, amount)
					player:sendInfo(_("Du hast %d %s aus dem Depot (Slot %d) genommen!", player, amount, item, slotId))
					player:triggerEvent("ItemDepotRefresh", self.m_Id, self.m_Items)
					StatisticsLogger:getSingleton():addItemDepotLog(player, self.m_Id, item, -amount)
					return
				else
					player:sendError(_("Du hast nicht genug Platz in deinem Inventar!", player))
				end
			--else
			--	player:sendError("Internal Error Amount to low", player)
			--end
		else
			player:sendError(_("Du hast kein Item in diesem Slot!", player))
		end
	end
end
