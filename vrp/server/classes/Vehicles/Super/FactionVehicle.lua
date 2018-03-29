-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/FactionVehicle.lua
-- *  PURPOSE:     Faction Vehicle class
-- *
-- ****************************************************************************
FactionVehicle = inherit(PermanentVehicle)

function FactionVehicle:constructor(data)
	self.m_Faction = FactionManager:getFromId(data.OwnerId)
	if #self.m_Faction:getName() <= 29 then
		setElementData(self, "OwnerName", self.m_Faction:getName())
	else
		setElementData(self, "OwnerName", self.m_Faction:getShortName())
	end
	setElementData(self, "OwnerType", "faction")
	setElementData(self, "StateVehicle", self.m_Faction:isStateFaction())

    addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
    --addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
    addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			veh:respawn(true)
		end, 10000, 1, source)
	end)

	if self.m_Faction.m_Vehicles then
		table.insert(self.m_Faction.m_Vehicles, self)
	end

	if self:getModel() == 544 and self.m_Faction:isRescueFaction() then
		FactionRescue:getSingleton():onLadderTruckReset(self)
	end

	if (self:getModel() == 432 or self:getModel() == 520 or self:getModel() == 425) and self.m_Faction:isStateFaction() then
		addEventHandler("onVehicleStartEnter", self, function(player, seat)
			if seat == 0 then
				if not self:isWithinColShape(FactionState:getSingleton().m_ArmySepcialVehicleCol) then
					if player:getFaction().m_Id ~= 3 or player:getFaction():getPlayerRank(player) == 0 then
						cancelEvent()
					end
				end
			end
		end)
	end

	if self:getModel() == 427 or self:getModel() == 528 or self:getModel() == 601 then -- Enforcer, FBI Truck and SWAT tank
		self:setMaxHealth(1500, true)
		self:setDoorsUndamageable(true)
	end
	
	self:setPlateText((self.m_Faction.m_ShorterName .. " " .. ("000000" .. tostring(self.m_Id)):sub(-5)):sub(0,8))

	self:setLocked(false) -- Unlock faction vehicles
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
		elseif player:getFaction() and player:getFaction() == self.m_Faction then
			return true
		elseif player:getFaction() and self.m_Faction:checkAlliancePermission(player:getFaction(), "vehicles") then
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
--[[
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
]]
function FactionVehicle:purge()
	if sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end
--[[
function FactionVehicle:save()
	return sql:queryExec("UPDATE ??_faction_vehicles SET Mileage = ?, Fuel = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ? WHERE Id = ?",
		sql:getPrefix(), self:getMileage(), self:getFuel(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, self.m_Id)
end
]]
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
	elseif player:getFaction() and self.m_Faction:checkAlliancePermission(player:getFaction(), "vehicles") then
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
				if not player:getInventory():removeItem(itemName, amount) then
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

	if self:getOccupants() then
		if table.size(self:getOccupants()) > 0 then
			return false
		end
	else -- Trailers don't have occupants and will return false. If the trailer is towed by a vehicle do not respawn the trailer
		if self.towingVehicle and table.size(self.towingVehicle:getOccupants()) > 0 then
			return false
		end
	end


	setVehicleOverrideLights(self, 1)
	self:setEngineState(false)
	self:setSirensOn(false)
	self:setFrozen(true)
	self:toggleELS(false)
	self:toggleDI(false)
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

function FactionVehicle:sendOwnerMessage(msg)
	self:getFaction():sendShortMessage(msg)
end