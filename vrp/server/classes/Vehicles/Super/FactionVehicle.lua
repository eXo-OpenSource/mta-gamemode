-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/FactionVehicle.lua
-- *  PURPOSE:     Faction Vehicle class
-- *
-- ****************************************************************************
FactionVehicle = inherit(PermanentVehicle)

function FactionVehicle:constructor(Id, faction, color, health, posionType, tunings, mileage, handlingFaktor, decal)
	self.m_Id = Id
	self.m_Faction = faction
	self.m_PositionType = positionType or VehiclePositionType.World
	self.m_SpawnPos = self:getPosition()
	self.m_SpawnRot = self:getRotation()
	self.m_HandlingFactor = handlingFaktor
	self.m_Decal = #tostring(decal) > 3 and tostring(decal) or false
	if #faction:getName() <= 29 then
		setElementData(self, "OwnerName", faction:getName())
	else
		setElementData(self, "OwnerName", faction:getShortName())
	end
	setElementData(self, "OwnerType", "faction")
	setElementData(self, "StateVehicle", faction:isStateFaction())
	if health then
		if health <= VEHICLE_TOTAL_LOSS_HEALTH then
			self:setBroken(true)
		else
			self:setHealth(health)
		end
	end
	if color and fromJSON(color) then	
		setVehicleColor(self, fromJSON(color))
	elseif factionCarColors[self.m_Faction:getId()] then
		local color = factionCarColors[self.m_Faction:getId()]
		setVehicleColor(self, color.r, color.g, color.b, color.r1, color.g1, color.b1)
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

    addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
    addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
    addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			veh:respawn(true)
		end, 10000, 1, source)
	end)

	if self.m_Faction.m_Vehicles then
		table.insert(self.m_Faction.m_Vehicles, self)
	end

	self:setMileage(mileage)
	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )

	if faction:isStateFaction() then
		if self:getVehicleType() == VehicleType.Automobile then
			self.m_VehELSObj = ELSSystem:new(self)
		end
	end

	if faction:isRescueFaction() then
		if self:getVehicleType() == VehicleType.Automobile then
			self.m_VehELSObj = ELSSystem:new(self)
		end
	end
	if handlingFaktor and handlingFaktor ~= "" then
		local handling = getOriginalHandling(getElementModel(self))
		local tHandlingTable = split(handlingFaktor, ";")
		for k,v in ipairs( tHandlingTable ) do
			local property,faktor = gettok( v, 1, ":"),gettok( v, 2, ":")
			local oldValue = handling[property]
			if oldValue then
				if type( oldValue) == "number" then
					setVehicleHandling(self,property,oldValue*faktor)
				else
					setVehicleHandling(self,property,faktor)
				end
			end
		end
	end

	if decal then
		for i, v in pairs(decal) do
			self:setTexture(v, i)
		end
	end

	if self:getModel() == 544 and self.m_Faction:isRescueFaction() then
		FactionRescue:getSingleton():onLadderTruckReset(self)
	end
	if self:getModel() == 427 or self:getModel() == 528 or self:getModel() == 601 then -- Enforcer, FBI Truck and SWAT tank
		self:setMaxHealth(1500, true)
		self:setDoorsUndamageable(true)
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

function FactionVehicle:onStartEnter(player, seat)

end

function FactionVehicle:onEnter(player, seat)
	if seat == 0 then
		if (self.m_Faction:isStateFaction() == true and player:getFaction() and player:getFaction():isStateFaction() == true) or (self.m_Faction:isRescueFaction() == true and player:getFaction() and player:getFaction():isRescueFaction() == true)  then
			if player:isFactionDuty() then
				return true
			else
				player:sendError(_("Du bist nicht im Dienst!", player))
				removePedFromVehicle(player)
				local x,y,z = getElementPosition(player)
				setElementPosition(player,x,y,z)
				return false
			end
		elseif player:getFaction() == self.m_Faction then
			return true
		else
			player:sendError(_("Du darfst dieses Fahrzeug nicht benutzen!", player))
			removePedFromVehicle(player)
			local x,y,z = getElementPosition(player)
			setElementPosition(player,x,y,z)
			return false
		end
	end
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
	return sql:queryExec("UPDATE ??_faction_vehicles SET Mileage = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ? WHERE Id = ?", 
		sql:getPrefix(), self:getMileage(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, self.m_Id)
end

function FactionVehicle:hasKey(player)
  if self:isPermanent() and self.m_Faction then
    if player:getFaction() and self.m_Faction:isStateFaction() and player:getFaction():isStateFaction() then
		if player:isFactionDuty() then
			return true
		end
	elseif player:getFaction() and self.m_Faction:isRescueFaction() and player:getFaction():isRescueFaction() then
		if player:isFactionDuty() then
			return true
		end
	elseif player:getFaction() and player:getFaction() == self.m_Faction then
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

function FactionVehicle:loadFactionItem(player, itemName, amount, inventory)
	if not self.m_FactionTrunk then self.m_FactionTrunk = {} end
	if not self.m_FactionTrunk[itemName] then self.m_FactionTrunk[itemName] = 0 end
	if FACTION_TRUNK_MAX_ITEMS[itemName] then
		if FACTION_TRUNK_MAX_ITEMS[itemName] >= self.m_FactionTrunk[itemName]+amount then
			if inventory then
				if player:getInventory():getItemAmount(itemName) >= amount then
					player:getInventory():removeItem(itemName, amount)
				else
					player:sendError(_("Du hast keine %d Stk. von diesem Item dabei! (%s)", player, amount, itemName))
					return
				end
			end

			self.m_FactionTrunk[itemName] = self.m_FactionTrunk[itemName]+amount
			player:sendShortMessage(_("Du hast %d %s in das Fahrzeug geladen!", player, amount, itemName))
			self:setData("factionTrunk", self.m_FactionTrunk, true)
		else
			player:sendError(_("In dieses Fahrzeug passen maximal %d Stk. dieses Items! (%s)", player, FACTION_TRUNK_MAX_ITEMS[itemName], itemName))
		end
	else
		player:sendError("Ungültiges Element!")
	end
end

function FactionVehicle:takeFactionItem(player, itemName)
	if self.m_FactionTrunk and self.m_FactionTrunk[itemName] then
		if self.m_FactionTrunk[itemName] >= 1 then
			if player:getInventory():giveItem(itemName, 1) then
				self.m_FactionTrunk[itemName] = self.m_FactionTrunk[itemName]-1
				player:sendShortMessage(_("Du hast 1 %s aus dem Fahrzeug in dein Inventar gepackt!", player, itemName))
			end
		else
			player:sendError(_("Dieses Item ist nicht mehr im Fahrzeug! (%s)", player, itemName))
		end
	else
		player:sendError("Ungültiges Element!")
	end
end

function FactionVehicle:respawn(force)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
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

	setVehicleOverrideLights(self, 1)
	self:setEngineState(false)
	self:setSirensOn(false)
	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:setPosition(self.m_SpawnPos)
	self:setRotation(self.m_SpawnRot)
	if self.m_VehELSObj then
		self.m_VehELSObj:setBlink("off")
	end
	self:resetIndicator()
	self:fix()
	if self:getModel() == 544 and self.m_Faction:isRescueFaction() then
		FactionRescue:getSingleton():onLadderTruckReset(self)
	end

	if self.m_HandlingFactor ~= "" and self.m_HandlingFactor then
		local handling = getOriginalHandling(getElementModel(self))
		local tHandlingTable = split(self.m_HandlingFactor, ";")
		for k,v in ipairs( tHandlingTable ) do
			local property,faktor = gettok( v, 1, ":"),gettok( v, 2, ":")
			local oldValue = handling[property]
			if type( oldValue) == "number" then
				setVehicleHandling(self,property,oldValue*faktor)
			else
				setVehicleHandling(self,property,faktor)
			end
		end
	end

	if self.m_Magnet then
		detachElements(self.m_Magnet)
		self.m_Magnet:attach(self, 0, 0, -1.5)

		self.m_MagnetHeight = -1.5
		self.m_MagnetActivated = false
	end

	return true
end
