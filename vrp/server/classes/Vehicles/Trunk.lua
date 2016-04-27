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

addRemoteEvents{"trunkAddItem", "trunkAddWeapon"}

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

addEventHandler("trunkAddItem", root, function(trunkId, item, amount)
	if Trunk.getFromId(trunkId) then
		Trunk.getFromId(trunkId):addItem(client, item, amount)
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

function Trunk:addItem(player, item, amount)
	for index, slot in pairs(self.m_ItemSlot) do
		if slot.Item == "none" then
			slot.Item = item
			slot.Amount = amount
			player:sendInfo(_("Du hast %d %s in den Kofferraum gelegt!", player, amount, item))
			self:refreshClient(player)
			return
		end
	end
	player:sendError(_("Du hast keinen freien Item-Slot in diesem Kofferraum!", player))
end

function Trunk:addWeapon(player, weaponId, muni)
	for index, slot in pairs(self.m_WeaponSlot) do
		if slot.WeaponId == 0 then
			slot.WeaponId = weaponId
			slot.Amount = muni
			self:refreshClient(player)
			player:sendInfo(_("Du hast %d Schuss %s in den Kofferraum gelegt!", player, amount, getWeaponNameFromID(weaponId)))
			return
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
