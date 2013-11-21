-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
registerElementClass("vehicle", Vehicle)

function Vehicle:constructor(Id, owner, keys)
	self.m_Id = Id
	self.m_Owner = owner
	self.m_Keys = keys or {}
end

function Vehicle:destructor()
	destroyElement(self)
end

function Vehicle.create(owner, model, posX, posY, posZ, rotation)
	if type(owner) == "userdata" then
		owner = owner:getId()
	end
	if sql:queryExec("INSERT INTO ??_vehicles (Owner, Model, PosX, PosY, PosZ, Rotation) VALUES(?, ?, ?, ?, ?, ?)", sql:getPrefix(), owner, model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, Vehicle, sql:lastInsertId(), owner)
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
	
	return sql:queryExec("UPDATE ??_vehicles SET PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, `Keys` = ? WHERE Id = ?", sql:getPrefix(), posX, posY, posZ, rotZ, toJSON(self.m_Keys), self.m_Id)
end

function Vehicle:getId()
	return self.m_Id
end

function Vehicle:setOwner(owner)
	if type(owner) == "userdata" then
		self.m_Owner = owner:getCharacterId()
	elseif type(owner) == "number" then
		self.m_Owner = owner
	else
		return false
	end
	-- Todo: Save
	return true
end

function Vehicle:getOwner()
	return self.m_Owner
end

function Vehicle:addKey(player)
	if type(player) == "userdata" then
		player = player:getCharacterId()
	end
	table.insert(self.m_Keys, player)
end

function Vehicle:removeKey(player)
	if type(player) == "userdata" then
		player = player:getCharacterId()
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
		player = player:getCharacterId()
	end
	if self.m_Owner == player then
		return true
	end
	return table.find(self.m_Keys, player)
end
