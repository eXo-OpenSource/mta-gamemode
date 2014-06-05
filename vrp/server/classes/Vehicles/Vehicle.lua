-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)

Vehicle.constructor = pure_virtual -- Use PermanentVehicle / TemporaryVehicle instead
function Vehicle:virtual_constructor()
	addEventHandler("onVehicleExit", self, bind(self.onPlayerExit, self))
	
	self.m_LastUseTime = math.huge
end

function Vehicle:virtual_destructor()
	VehicleManager:getSingleton():removeRef(self, not self:isPermanent())
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
			names[v] = name
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

function Vehicle:onPlayerExit(player)
	self.m_LastUseTime = getTickCount()
end

function Vehicle:getLastUseTime()
	return self:isBeingUsed() and getTickCount() or self.m_LastUseTime
end

function Vehicle:isBeingUsed()
	for k, v in pairs(getVehicleOccupants(self)) do
		return true 
	end
	return false
end

 Vehicle.isPermanent = pure_virtual
 Vehicle.respawn = pure_virtual
