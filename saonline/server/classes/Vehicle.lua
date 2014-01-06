-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
--registerElementClass("vehicle", Vehicle)

function Vehicle:constructor(Id, owner, keys, color, health)
	self.m_Id = Id
	self.m_Owner = owner
	setElementData(self, "OwnerName", Account.getNameFromId(owner) or "None") -- *hide*
	self.m_Keys = keys or {}
	
	setElementHealth(self, health)
	setVehicleLocked(self, true)
	if color then
		local a, r, g, b = getBytesInInt32(color)
		setVehicleColor(self, r, g, b)
	end
end

function Vehicle:destructor()
	destroyElement(self)
end

function Vehicle.create(owner, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if type(owner) == "userdata" then
		owner = owner:getId()
	end
	if sql:queryExec("INSERT INTO ??_vehicles (Owner, Model, PosX, PosY, PosZ, Rotation, Health, Color) VALUES(?, ?, ?, ?, ?, ?, 1000, 0)", sql:getPrefix(), owner, model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, Vehicle, sql:lastInsertId(), owner, nil, nil, 1000)
		VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function Vehicle:purge()
	if sql:queryExec("DELETE FROM ??_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		destroyElement(self)
		return true
	end
	return false
end

function Vehicle:save()
	local posX, posY, posZ = getElementPosition(self)
	local rotX, rotY, rotZ = getElementRotation(self)
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	
	return sql:queryExec("UPDATE ??_vehicles SET Owner = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, `Keys` = ? WHERE Id = ?", sql:getPrefix(), self.m_Owner, posX, posY, posZ, rotZ, health, color, toJSON(self.m_Keys), self.m_Id)
end

function Vehicle:getId()
	return self.m_Id
end

function Vehicle:setOwner(owner)
	if type(owner) == "userdata" then
		self.m_Owner = owner:getId()
	elseif type(owner) == "number" then
		self.m_Owner = owner
	else
		return false
	end
	self:save()
	return true
end

function Vehicle:getOwner()
	return self.m_Owner
end

function Vehicle:addKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	table.insert(self.m_Keys, player)
end

function Vehicle:removeKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	local index = table.find(self.m_Keys, player)
	if not index then
		return false
	end
	table.remove(self.m_Keys, index)
	return true
end

function Vehicle:hasKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	if self.m_Owner == player then
		return true
	end
	return table.find(self.m_Keys, player)
end

function Vehicle:getKeyNameList()
	local names = {}
	for k, v in ipairs(self.m_Keys) do
		local name = Account.getNameFromId(v)
		if name then
			table.insert(names, name)
		end
	end
	return names
end

function Vehicle:setLocked(state)
	-- Todo: Play lock animation (flashing lights)

	return setVehicleLocked(self, state)
end

function Vehicle:isLocked()
	return isVehicleLocked(self)
end
