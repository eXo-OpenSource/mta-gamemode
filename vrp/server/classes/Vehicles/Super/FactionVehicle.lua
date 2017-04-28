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
	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
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
		if health <= 300 then
			self:setHealth(health or 1000)
		end
	end
	if color then
		local a, r, g, b = getBytesInInt32(color)
		if factionCarColors[self.m_Faction:getId()] then
			if getElementModel(self) == 420 and faction.m_Id == 2 then
				setVehicleColor(self, 255, 255, 0)
			elseif getElementModel(self) == 560 and faction.m_Id == 1 then
				setVehicleColor(self, 255, 255, 255)
			elseif getElementModel(self) == 407 or getElementModel(self) == 544 and faction.m_Id == 4 then -- Rescue Fire Trucks
				setVehicleColor(self, 255, 0, 0, 255, 255, 255)
			else
				local color = factionCarColors[self.m_Faction:getId()]
				setVehicleColor(self, color.r, color.g, color.b, color.r1, color.g1, color.b1)
			end
		else
			setVehicleColor(self, r, g, b)
		end
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

    addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
    addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
    addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			veh:setHealth(1000)
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

	if self.m_Faction.m_VehicleTexture then
		if self.m_Faction.m_VehicleTexture[self:getModel()] and self.m_Faction.m_VehicleTexture[self:getModel()] then
			local textureData = self.m_Faction.m_VehicleTexture[self:getModel()]
			if textureData.shaderEnabled then
				local texturePath, textureName = textureData.texturePath, textureData.textureName
				if self.m_Decal then texturePath = self.m_Decal end
				if texturePath and #texturePath > 3 then
					self:setTexture(texturePath, textureName)
				end
			end
		end
	end

	if self:getModel() == 544 and self.m_Faction:isRescueFaction() then
		FactionRescue:getSingleton():onLadderTruckSpawn(self)
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
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_faction_vehicles SET Mileage = ?, Color = ? WHERE Id = ?", sql:getPrefix(),
	self:getMileage(), color, self.m_Id)
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
			if player:getInventory():getFreePlacesForItem(itemName) >= 1 then
				self.m_FactionTrunk[itemName] = self.m_FactionTrunk[itemName]-1
				player:getInventory():giveItem(itemName, 1)
				player:sendShortMessage(_("Du hast 1 %s aus dem Fahrzeug in dein Inventar gepackt!", player, itemName))
			else
				player:sendError(_("Kein Platz in deinem Inventar! (%s)", player, itemName))
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
	self:setPosition(self.m_Position)
	self:setRotation(self.m_Rotation)
	if self.m_VehELSObj then
		self.m_VehELSObj:setBlink("off")
	end
	self:resetIndicator()
	self:fix()

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

	return true
end
