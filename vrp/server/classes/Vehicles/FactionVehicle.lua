-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/FactionVehicle.lua
-- *  PURPOSE:     Faction Vehicle class
-- *
-- ****************************************************************************
FactionVehicle = inherit(PermanentVehicle)

function FactionVehicle:constructor(Id, faction, color, health, posionType, tunings, mileage)
	self.m_Id = Id
	self.m_Faction = faction
	self.m_PositionType = positionType or VehiclePositionType.World
	setElementData(self, "OwnerName", faction:getName())

	self:setHealth(health)
	if color then
		local a, r, g, b = getBytesInInt32(color)
		if factionColors[self.m_Faction:getId()] then
			local fR, fB, fG = factionColors[self.m_Faction:getId()].r, factionColors[self.m_Faction:getId()].b, factionColors[self.m_Faction:getId()].g
			setVehicleColor(self, r, g, b, fR, fG, fB)
		else
			setVehicleColor(self, r, g, b)
		end
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

    addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
    addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))

	if self.m_Faction.m_Vehicles then
		table.insert(self.m_Faction.m_Vehicles, self)
	end

	self:setMileage(mileage)
	if faction:isStateFaction() then
			self.m_VehELSObj = ELSSystem:new(self)
	end
end

function FactionVehicle:destructor()
	outputChatBox("destructed")
	if self.m_VehELSObj then
		self.m_VehELSObj:delete()
	end
end

function FactionVehicle:getId()
	return self.m_Id
end

function FactionVehicle:getFaction()
  return self.m_Faction
end

function FactionVehicle:isStateVehicle()
  	return self.m_Faction:isStateFaction()
end

function FactionVehicle:onStartEnter(player,seat)
	if seat == 0 then
		if player:getFaction() == self.m_Faction then

		elseif player:getFaction():isStateFaction() == true	and self.m_Faction:isStateFaction() == true then

		else
			cancelEvent()
			player:sendError(_("Du darfst dieses Fahrzeug nicht benutzen!", player))
		end
	end
end

function FactionVehicle:onEnter(player)
	if player:getFaction() == source.m_Faction then

	end
end

function FactionVehicle:respawn()
	respawnVehicle(self)
end

function FactionVehicle:create(Faction, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_faction_vehicles (Faction, Model, PosX, PosY, PosZ, Rotation, Health, Color) VALUES(?, ?, ?, ?, ?, ?, 1000, 0)", sql:getPrefix(), Faction:getId(), model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, FactionVehicle, sql:lastInsertId(), Faction, nil, 1000)
    VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function FactionVehicle:purge()
	if sql:queryExec("DELETE FROM ??_faction_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end

function FactionVehicle:save()
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_faction_vehicles SET Faction = ?, Mileage = ?, Color = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Faction:getId(), self:getMileage(), color, self.m_Id)
end

function FactionVehicle:hasKey(player)
  if self:isPermanent() then
    if player:getFaction() == self.m_Faction then
      return true
    end
  end

  return false
end

function FactionVehicle:addKey(player)
  return false
end

function FactionVehicle:removeKey(player)
  return false
end

function FactionVehicle:canBeModified()
  --return self:getFaction():canVehiclesBeModified()
  return false
end

function FactionVehicle:respawn()
	-- Set inGarage flag and teleport to private dimension
	self.m_LastUseTime = math.huge
end
