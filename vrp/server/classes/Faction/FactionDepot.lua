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
	addRemoteEvents{"itemDepotAdd", "itemDepotTake", "equipmentDepotAdd", "equipmentDepotTake"}

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

	addEventHandler("equipmentDepotAdd", root, function(id, item, amount)
		if Depot.Map[id] then
			Depot.Map[id]:addEquipment(client, item, amount)
		end
	end)

	addEventHandler("equipmentDepotTake", root, function(id, item, amount)
		if Depot.Map[id] then
			Depot.Map[id]:takeEquipment(client, item, amount)
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

	local row = sql:queryFetchSingle("SELECT Weapons, Items, Equipments FROM ??_depot WHERE Id = ?;", sql:getPrefix(), Id)
	if not row then
		return
	end
	local weapons = row.Weapons or ""
	local items = row.Items or ""
	local equipments = row.Equipments or ""
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

	if string.len(equipments) < 5 then
		equipments = {}
		for category, data in pairs(ArmsDealer.Data) do 
			if category ~= "Waffen" then
				for product, subdata in pairs(data) do 
					equipments[product] = 0
				end
			end
		end
		equipments = toJSON(equipments)
		DepotSave = true
		outputDebugString("Creating new Equipment-Table for Depot "..Id)
	end

	Depot.Map[Id] = Depot:new(Id, weapons, items, equipments, Owner)

	if DepotSave == true then Depot.Map[Id]:save() end

	return Depot.Map[Id]
end

function Depot:constructor(Id, weapons, items, equipments, owner)
	self.m_Id = Id
	self.m_Weapons = fromJSON(weapons)
	self.m_Items = fromJSON(items)
	self.m_Equipments = fromJSON(equipments)
	self.m_Owner = owner
end

function Depot:destructor()
  self:save()
end

function Depot:save()
	return sql:queryExec("UPDATE ??_depot SET Weapons = ?, Items = ?, Equipments = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_Weapons), toJSON(self.m_Items), toJSON(self.m_Equipments), self.m_Id)
end

function Depot:getId()
  return self.m_Id
end

function Depot:getWeaponTable()
  return self.m_Weapons
end

function Depot:getEquipmentTable()
	return self.m_Equipments
end

function Depot:getWeapon(id)
	return self.m_Weapons[id]["Waffe"],self.m_Weapons[id]["Munition"]
end

function Depot:getEquipmentItem(item)
	return self.m_Equipments[item]
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

function Depot:showEquipmentDepot(player)
	player:getInventory():syncClient()
	player:triggerEvent("ItemEquipmentOpen")
	player:triggerEvent("ItemEquipmentRefresh", self.m_Id, self.m_Equipments, ArmsDealer.Data)
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
	local ammoStorage = {}
	local weaponStorage = {}
	local bIsStorageWeapon = false
	local isInVariable = false
	local weaponInStorage, ammoInStorage = Guns:getWeaponInStorage( player, 2)
	local weaponBeforeEquip = getPedWeapon(player, 2)
	local ammoBeforeEquip = getPedTotalAmmo(player, 2)
	local logData = {} -- ["WeaponName"] = MagCount
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				local clipAmmo = getWeaponProperty(weaponID, "pro", "maximum_clip_ammo") or 1
				if WEAPON_CLIPS[weaponID] then clipAmmo = WEAPON_CLIPS[weaponID] end

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
						if not logData[WEAPON_NAMES[weaponID]] then
							logData[WEAPON_NAMES[weaponID]] = 1
						else
							logData[WEAPON_NAMES[weaponID]] = logData[WEAPON_NAMES[weaponID]] + 1
						end
						if not WEAPON_PROJECTILE[weaponID] then 
							giveWeapon(player,weaponID, NO_MUNITION_WEAPONS[weaponID] and 1 or 0) -- not usable shovel and night vision fix
						else 
							giveWeapon(player,weaponID, amount, true)
						end
						self:takeWeaponD(weaponID,amount)
					else
						player:sendError(_("Es sind nicht genug %s im Lager (%s)!", player, WEAPON_NAMES[weaponID], amount))
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
							giveWeapon(player, weaponID, amount*clipAmmo)
							if not logData[WEAPON_NAMES[weaponID]] then
								logData[WEAPON_NAMES[weaponID]] = amount
							else
								logData[WEAPON_NAMES[weaponID]] = logData[WEAPON_NAMES[weaponID]] + amount
							end
						else
							player:sendError(_("Es sind nicht genug %s-Magazine im Lager (%s)!", player, WEAPON_NAMES[weaponID], amount))
						end
					else
						player:sendError(_("Du hast keine %s für ein Magazin!", player, WEAPON_NAMES[weaponID]))
					end
				end
				if logData.w or logData.m then

				end
			end
		end
	end
	local textForPlayer = "Du hast folgende Waffen aus dem Lager genommen:"
	for i,v in pairs(logData) do
		self.m_Owner:addLog(player, "Waffenlager", ("hat ein/e(n) %s mit %s Magazin(en) aus dem Lager genommen!"):format(i, (v-1)))
		textForPlayer = textForPlayer.."\n"..i
		if v > 1 then
			textForPlayer = textForPlayer.. " mit ".. (v-1) .. " Magazin(en)"
		end
	end
	player:sendInfo(textForPlayer)
	self:save()
end



function Depot:addItem(player, item, amount, giveItemFromServer)
	for i=1, 6 do
		if not self.m_Items[i] then self.m_Items[i] = {} self.m_Items[i]["Item"] = 0 self.m_Items[i]["Amount"] = 0  end
		if self.m_Items[i]["Item"] == 0 then
			if item ~= "Kleidung" then --wtf we cant check if the item has a value wtf wtf wtf - MasterM 2017
				if giveItemFromServer or player:getInventory():removeItem(item, amount) then
					self.m_Items[i]["Item"] = item
					self.m_Items[i]["Amount"] = amount
					player:sendInfo(_("Du hast %d %s ins Depot (Slot %d) gelegt!", player, amount, item, i))
					player:triggerEvent("ItemDepotRefresh", self.m_Id, self.m_Items)
					StatisticsLogger:getSingleton():addItemDepotLog(player, self.m_Id, item, amount)
					self.m_Owner:addLog(player, "Itemlager", ("hat %s  %s in das Lager gelegt!"):format(amount, item))
					return
				else
					player:sendError(_("Du hast nicht genug %s!", player, item))
					return
				end
			else
				player:sendError(_("Du kannst dieses Item nicht einlagern!", player, item))
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
					self.m_Owner:addLog(player, "Itemlager", ("hat %s  %s aus dem Lager genommen!"):format(amount, item))
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

function Depot:addEquipment(player, item, amount, forceSpawn) 
	if not self:checkDistanceFromEquipment(player) then return end
	if self.m_Equipments then 
		local allAmount = amount == -1 and player:getInventory():getItemAmount(item)
		local armsData = ArmsDealer:getSingleton():getItemData(item)
		if not armsData[3] then 
			allAmount = amount == -1 and player:getInventory():getItemAmount(item)
		else 
			allAmount = amount == -1 and getPedTotalAmmo(player, getSlotFromWeapon ( armsData[3]))
		end

		if forceSpawn
		or (armsData[3] and (getPedWeapon(player, getSlotFromWeapon ( armsData[3])) == armsData[3]) and getPedTotalAmmo(player, getSlotFromWeapon ( armsData[3])) >= amount) 
		or (amount > 0 and player:getInventory():removeItem(item, amount)) 
		or (amount==-1 and self:removeAllEquipment(player, item, allAmount)) then
			if not self.m_Equipments[item] then 
				self.m_Equipments[item] = 0
			end
			if amount > 0 then
				self.m_Equipments[item] = self.m_Equipments[item] + amount
				if armsData[3] then 
					if not takeWeapon(player, armsData[3], amount) then 
						self.m_Equipments[item] = self.m_Equipments[item] - amount -- prevent bug-abuse
					end
				end
			else 
				self.m_Equipments[item] = self.m_Equipments[item] + allAmount
				amount = allAmount
				if armsData[3] then 
					if not takeWeapon(player, armsData[3]) then 
						self.m_Equipments[item] = self.m_Equipments[item] - allAmount -- prevent bug-abuse
					end
				end
			end
			StatisticsLogger:getSingleton():addItemDepotLog(player, self.m_Id, item, -amount)
			self.m_Owner:addLog(player, "Itemlager", ("hat %s  %s in das Lager gelegt!"):format(amount, item))
			player:triggerEvent("ItemEquipmentRefresh", self.m_Id, self.m_Equipments, ArmsDealer.Data)
			player:sendInfo(_("Du hast %d %s ins Depot gelegt!", player, amount, item))
			return
		else 
			player:sendError(_("Du hast nicht genug %s!", player, item))
		end
	end
end

function Depot:removeAllEquipment(player, item, amount) -- this executes removeItem x amount since removeAllItem occasionally misses an item in the inventory 
	for i = 1, amount do 
		if not player:getInventory():removeItem(item, 1) then 
			return false
		end
	end
	return true
end

function Depot:takeEquipment(player, item, amount)
	if not self:checkDistanceFromEquipment(player) then return end
	if self.m_Equipments[item] then
		local armsData = ArmsDealer:getSingleton():getItemData(item)
		if armsData[3] or (amount > 0 and self.m_Equipments[item] >= amount) or (amount==-1 and player:getInventory():getFreePlacesForItem(item) >= self.m_Equipments[item] ) then
			if amount > 0 then 
				self.m_Equipments[item] = self.m_Equipments[item] - amount
				if not armsData[3] then 
					if not player:getInventory():giveItem(item, amount) then 
						self.m_Equipments[item] = self.m_Equipments[item] + amount
					end
				else 
					giveWeapon(player, armsData[3], amount)
				end
			elseif amount == -1 then 
				amount = self.m_Equipments[item]
				self.m_Equipments[item] = 0
				if not armsData[3] then
					if not player:getInventory():giveItem(item, amount) then 
						self.m_Equipments[item] = amount
					end
				else 
					giveWeapon(player, armsData[3], amount)
				end
			end
			player:sendInfo(_("Du hast %d %s aus dem Depot genommen!", player, amount, item))
			StatisticsLogger:getSingleton():addItemDepotLog(player, self.m_Id, item, -amount)
			player:triggerEvent("ItemEquipmentRefresh", self.m_Id, self.m_Equipments, ArmsDealer.Data)
			self.m_Owner:addLog(player, "Itemlager", ("hat %s  %s aus dem Lager genommen!"):format(amount, item))
			return
		else
			player:sendError(_("Du hast nicht genug Platz in deinem Inventar!", player))
		end
	end
end

function Depot:checkDistanceFromEquipment(player)
	if player and isElement(player) and player.m_LastEquipmentDepot and isElement(player.m_LastEquipmentDepot) 
	and (player.m_LastEquipmentDepot:getInterior() == player:getInterior()) 
	and (player.m_LastEquipmentDepot:getDimension() == player:getDimension()) then 
		return (player:getPosition() - player.m_LastEquipmentDepot:getPosition()):getLength() < 4 or player:sendError("Zu weit entfernt!")
	end
	return false
end
