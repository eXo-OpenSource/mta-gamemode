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
	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
	if #faction:getName() <= 29 then
		setElementData(self, "OwnerName", faction:getName())
	else
		setElementData(self, "OwnerName", faction:getShortName())
	end

	self:setHealth(health)
	if color then
		local a, r, g, b = getBytesInInt32(color)
		if factionCarColors[self.m_Faction:getId()] then
			local color = factionCarColors[self.m_Faction:getId()]
			setVehicleColor(self, color.r, color.g, color.b, color.r1, color.g1, color.b1)
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

		elseif player:getFaction() and player:getFaction():isStateFaction() == true	and self.m_Faction:isStateFaction() == true then

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

function FactionVehicle:respawn(force)
	if self:getHealth() <= 310 and not force then
		self:getFaction():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	-- Teleport to Spawnlocation
	self.m_LastUseTime = math.huge

	if self:getOccupants() then -- For Trailers
		for _, player in pairs(self:getOccupants()) do
			return false
		end
	end

	self:setEngineState(false)
	self:setPosition(self.m_Position)
	self:setRotation(self.m_Rotation)
	self:fix()

	return true
end
