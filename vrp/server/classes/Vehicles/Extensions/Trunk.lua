-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Trunk.lua
-- *  PURPOSE:     Vehicle Trunk class
-- *
-- ****************************************************************************
Trunk = inherit(Object)
Trunk.Map = {}
Trunk.ItemSlots = 4
Trunk.WeaponSlots = 2

addRemoteEvents{"trunkAddItem", "trunkAddWeapon", "trunkTake"}

function Trunk.create()
	local item = {}
	local weapon = {}

	for i=1, Trunk.ItemSlots do
		item[i] = {["Item"] = "none", ["Amount"] = 0}
	end
	for i=1, Trunk.WeaponSlots do
		weapon[i] = {["WeaponId"] = 0, ["Amount"] = 0}
	end

	local row = sql:queryFetchSingle("INSERT INTO ??_vehicle_trunks (ItemSlot1, ItemSlot2, ItemSlot3, ItemSlot4, WeaponSlot1, WeaponSlot2) VALUES (?,?,?,?,?,?);",
	sql:getPrefix(), toJSON(item[1]), toJSON(item[2]), toJSON(item[3]), toJSON(item[4]), toJSON(weapon[1]), toJSON(weapon[2]))

	return sql:lastInsertId()
end

function Trunk.load(Id)
	local Id = Id
	if Trunk.Map[Id] then return Trunk.Map[Id] end
	if Id == 0 then	Id = Trunk.create()	end

	local row = sql:queryFetchSingle("SELECT * FROM ??_vehicle_trunks WHERE Id = ?;", sql:getPrefix(), Id)
	if row and Id > 0 then
		Trunk.Map[row.Id] = Trunk:new(row.Id, row.ItemSlot1, row.ItemSlot2, row.ItemSlot3, row.ItemSlot4, row.WeaponSlot1, row.WeaponSlot2)
		return Trunk.Map[row.Id]
	else
		Trunk.load(0)
	end
end

function Trunk.getFromId(id)
	return Trunk.Map[id]
end

addEventHandler("trunkAddItem", root, function(trunkId, item, amount, value)
	if Trunk.getFromId(trunkId) then
		Trunk.getFromId(trunkId):addItem(client, item, amount, value)
	else
		client:sendError("Internal Error - Trunk not found")
	end
end)

addEventHandler("trunkAddWeapon", root, function(trunkId, weaponId, muni)
	if Trunk.getFromId(trunkId) then
		Trunk.getFromId(trunkId):addWeapon(client, weaponId, muni)
	else
		client:sendError("Internal Error - Trunk not found")
	end
end)

addEventHandler("trunkTake", root, function(trunkId, type, slot)
	if Trunk.getFromId(trunkId) then
		if type == "weapon" then
			Trunk.getFromId(trunkId):takeWeapon(client, slot)
		elseif type == "item" then
			Trunk.getFromId(trunkId):takeItem(client, slot)
		end
	else
		client:sendError("Internal Error - Trunk not found")
	end
end)



function Trunk:constructor(Id, ItemSlot1, ItemSlot2, ItemSlot3, ItemSlot4, WeaponSlot1, WeaponSlot2)
	self.m_Id = Id
	self.m_ItemSlot = {}
	self.m_ItemSlot[1] = fromJSON(ItemSlot1)
	self.m_ItemSlot[2] = fromJSON(ItemSlot2)
	self.m_ItemSlot[3] = fromJSON(ItemSlot3)
	self.m_ItemSlot[4] = fromJSON(ItemSlot4)
	self.m_WeaponSlot = {}
	self.m_WeaponSlot[1] = fromJSON(WeaponSlot1)
	self.m_WeaponSlot[2] = fromJSON(WeaponSlot2)
end

function Trunk:destructor()
  self:save()
end

function Trunk:save()
	return sql:queryExec("UPDATE ??_vehicle_trunks SET ItemSlot1 = ?, ItemSlot2 = ?, ItemSlot3 = ?, ItemSlot4 = ?, WeaponSlot1 = ?, WeaponSlot2 = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_ItemSlot[1]), toJSON(self.m_ItemSlot[2]), toJSON(self.m_ItemSlot[3]), toJSON(self.m_ItemSlot[4]), toJSON(self.m_WeaponSlot[1]), toJSON(self.m_WeaponSlot[2]), self.m_Id)
end

function Trunk:addItem(player, item, amount, value)
	for index, slot in pairs(self.m_ItemSlot) do
		if slot["Item"] == "none" then
			if player:getInventory():getItemAmount(item) >= amount then
				player:getInventory():removeItem(item, amount, value)
				slot["Item"] = item
				slot["Amount"] = amount
				slot["Value"] = value
				player:sendInfo(_("Du hast %d %s in den Kofferraum (Slot %d) gelegt!", player, amount, item, index))
				self:refreshClient(player)
				StatisticsLogger:getSingleton():addVehicleTrunkLog(self.m_Id, player, "insert", "item", item, amount, index)
				return
			elseabb
				player:sendError(_("Du hast nicht genug %s!", player, item))
			end
		end
	end
	player:sendError(_("Du hast keinen freien Item-Slot in diesem Kofferraum!", player))
end

function Trunk:takeItem(player, slot)
	if self.m_ItemSlot[slot] then
		if self.m_ItemSlot[slot]["Item"] ~= "none" then
			--if self.m_ItemSlot[slot]["Amount"] > 0 then
				local item = self.m_ItemSlot[slot]["Item"]
				local amount = self.m_ItemSlot[slot]["Amount"]
				if player:getInventory():getFreePlacesForItem(item) >= amount then
					self.m_ItemSlot[slot]["Item"] = "none"
					self.m_ItemSlot[slot]["Amount"] = 0
					player:getInventory():giveItem(item, amount, self.m_ItemSlot[slot]["Value"])
					self.m_ItemSlot[slot]["Value"] = ""
					player:sendInfo(_("Du hast %d %s aus deinem Kofferraum (Slot %d) genommen!", player, amount, item, slot))
					self:refreshClient(player)
					StatisticsLogger:getSingleton():addVehicleTrunkLog(self.m_Id, player, "take", "item", item, amount, slot)
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

function Trunk:takeWeapon(player, slot)
	if player:getFaction() and player:isFactionDuty() then
		player:sendError(_("Du darfst im Dienst keine privaten Waffen verwenden!", player))
		return
	end
	if player.disableWeaponStorage then
		player:sendError(_("Du darfst diese Waffe nicht nehmen!", player))
		return
	end

	if self.m_WeaponSlot[slot] then
		if self.m_WeaponSlot[slot]["WeaponId"] > 0 then
			--if self.m_ItemSlot[slot]["Amount"] > 0 then
				local weaponId = self.m_WeaponSlot[slot]["WeaponId"]
				local amount = self.m_WeaponSlot[slot]["Amount"]
				if MIN_WEAPON_LEVELS[weaponId] <= player:getWeaponLevel() then
					if player:getWeapon(getSlotFromWeapon(weaponId)) == 0 then
						self.m_WeaponSlot[slot]["WeaponId"] = 0
						self.m_WeaponSlot[slot]["Amount"] = 0
						player:giveWeapon(weaponId, amount)
						player:sendInfo(_("Du hast eine/n %s mit %d Schuss aus deinem Kofferraum (Slot %d) genommen!", player, WEAPON_NAMES[weaponId], amount, slot))
						self:refreshClient(player)
						StatisticsLogger:getSingleton():addVehicleTrunkLog(self.m_Id, player, "take", "weapon", weaponId, amount, slot)
						return
					else
						player:sendError(_("Du hast bereits eine Waffe dieser Art dabei!", player))
					end
				else
					player:sendError(_("Dein Waffenlevel ist zu niedrig!", player))
				end
			--else
			--	player:sendError("Internal Error Amount to low", player)
			--end
		else
			player:sendError(_("Du hast kein Item in diesem Slot!", player))
		end
	end
end


function Trunk:addWeapon(player, weaponId, muni)
	if player:getFaction() and player:isFactionDuty() then
		player:sendError(_("Du darfst im Dienst keine Waffen einlagern!", player))
		return
	end
	if player.disableWeaponStorage then
		player:sendError(_("Du darfst diese Waffe nicht einlagern!", player))
		return
	end

	for index, slot in pairs(self.m_WeaponSlot) do
		if slot["WeaponId"] == 0 then
			local weaponSlot = getSlotFromWeapon(weaponId)
			if player:getWeapon(weaponSlot) > 0 then
				if player:getTotalAmmo(weaponSlot) >= muni then
					takeWeapon(player, weaponId)
					slot["WeaponId"] = weaponId
					slot["Amount"] = muni
					player:sendInfo(_("Du hast eine/n %s mit %d Schuss in den Kofferraum (Slot %d) gelegt!", player, WEAPON_NAMES[weaponId], muni, index))
					self:refreshClient(player)
					StatisticsLogger:getSingleton():addVehicleTrunkLog(self.m_Id, player, "insert", "weapon", weaponId, muni, index)
					return
				else
					player:sendInfo(_("Du hast nicht genug %s Munition!", player, WEAPON_NAMES[weaponId]))
				end
			else
				player:sendInfo(_("Du hast keine/n %s!", player, WEAPON_NAMES[weaponId]))
			end
		end
	end
	player:sendError(_("Du hast keinen freien Waffen-Slot in diesem Kofferraum!", player))
end

function Trunk:open(player)
	player:triggerEvent("openTrunk")
	self:refreshClient(player)
end

function Trunk:refreshClient(player)
	player:triggerEvent("getTrunkData", self.m_Id, self.m_ItemSlot, self.m_WeaponSlot)
end

function Trunk:getId()
  return self.m_Id
end
