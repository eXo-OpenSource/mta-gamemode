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
		addEventHandler("onVehicleExit", self, bind(self.onExit, self))
    --addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
    addEventHandler("onVehicleExplode", self, function()
		setTimer(function(veh)
			veh:respawn(true)
			PoliceAnnouncements:getSingleton():setSirenState(veh, "inactive")
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
				if not player:getFaction() or player:getFaction().m_Id ~= 3 or player:getFaction():getPlayerRank(player) == 0 then
					cancelEvent()
				end
			end
		end)
	end

	if (self.getFaction and self:isStateVehicle() and self:getModel() == 497) or (self.getFaction and (self:isRescueVehicle() and (self:getModel() == 417 or self:getModel() == 487)))  then 
		self:setInfrared(true)
	end

	if self:getModel() == 427 or self:getModel() == 528 or self:getModel() == 601 then -- Enforcer, FBI Truck and SWAT tank
		self:setMaxHealth(1500, true)
		self:setDoorsUndamageable(true)
	end
	
	self:setPlateText((self.m_Faction.m_ShorterName .. " " .. ("000000" .. tostring(self.m_Id)):sub(-5)):sub(0,8))

	self:setLocked(false) -- Unlock faction vehicles
	self.m_SpawnDim = data.Dimension 
	self.m_SpawnInt = data.Interior

	if self.getFaction and self:isStateVehicle() and (getVehicleType(self) == VehicleType.Automobile or getVehicleType(self) == VehicleType.Bike) then 
		local count = 1 
		if VehicleManager:getSingleton().m_FactionVehicles[self:getFaction():getId()] then 
			count = #VehicleManager:getSingleton().m_FactionVehicles[self:getFaction():getId()] + 1
		end
		VehicleManager:getSingleton():addVehicleMark(self, ("%s-%s"):format(count, FACION_STATE_VEHICLE_MARK[self:getFaction():getId()]))
	end
	if self.getFaction and self:isRescueVehicle() and (getVehicleType(self) == VehicleType.Automobile or getVehicleType(self) == VehicleType.Bike) then 
		local count = 1 
		if VehicleManager:getSingleton().m_FactionVehicles[self:getFaction():getId()] then 
			count = #VehicleManager:getSingleton().m_FactionVehicles[self:getFaction():getId()] + 1
		end
		VehicleManager:getSingleton():addVehicleMark(self, ("%s-%s"):format(count, FACION_STATE_VEHICLE_MARK[self:getFaction():getId()]))
	end
	
	addEventHandler("onElementDestroy", self, function() 
		VehicleManager:getSingleton():removeVehicleMark(self)
	end)

end

function FactionVehicle:destructor()
	if self.m_VehELSObj then
		self.m_VehELSObj:delete()
	end
	if self:isStateVehicle() then 
		VehicleManager:getSingleton():removeVehicleMark(self)
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

function FactionVehicle:isRescueVehicle()
  	return self.m_Faction:isRescueFaction()
end

function FactionVehicle:onStartEnter(player, seat)

end

function FactionVehicle:onEnter(player, seat)
	if self:getModel() == 425 or self:getModel() == 520 or self:getModel() == 432 then
		if not player:getFaction() or not player:isFactionDuty() or (player:getFaction() and player:getFaction():getId() ~= self:getOwner()) then
			player:sendError(_("Du bist kein Soldat im Dienst!", player))
			removePedFromVehicle(player)
			local x,y,z = getElementPosition(player)
			setElementPosition(player,x,y,z)
			return false
		end
	end
	return true
end

function FactionVehicle:onExit(player, seat)
	if seat == 0 then
		PoliceAnnouncements:getSingleton():setSirenState(source, "inactive")
	end
end
--[[
function FactionVehicle:onEnter(player, seat)
	if seat == 0 then
		if player:getFaction() then
			if not player:isFactionDuty() then
				if self.m_Faction:isStateFaction() or self.m_Faction:isRescueFaction() then 
					player:sendError(_("Du bist nicht im Dienst!", player))
				elseif self.m_Faction:isEvilFaction() then
					player:sendError(_("Du trägst nicht die Fraktionsfarben!", player))
				end
				removePedFromVehicle(player)
				local x,y,z = getElementPosition(player)
				setElementPosition(player,x,y,z)
				return false
			end
			local pFac = player:getFaction()
			local vFac = self.m_Faction
			local vFacAllyAllow = vFac:checkAlliancePermission(pFac, "vehicles")
			if pFac == vFac or vFacAllyAllow or (pFac:isStateFaction() and vFac:isStateFaction()) then 
				return true
			else
				player:sendError(_("Dieses Fahrzeug gehört nicht zu deiner Fraktion!", player))
			end
		else
			player:sendError(_("Dieses Fahrzeug kann nur von Fraktionsmitgliedern gefahren werden!", player))
		end
		removePedFromVehicle(player)
		local x,y,z = getElementPosition(player)
		setElementPosition(player,x,y,z)
	end
end
]]
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
	local price = FactionState:getSingleton().m_Items[itemName]*amount
	local isEquipment = false
	if FACTION_TRUNK_SWAT_ITEMS[itemName] then 
		isEquipment = true
	end
	if FACTION_TRUNK_MAX_ITEMS[itemName] then
		if FACTION_TRUNK_MAX_ITEMS[itemName] >= self.m_FactionTrunk[itemName]+amount then
			if inventory then
				if not player:getInventory():removeItem(itemName, amount) then
					player:sendError(_("Du hast keine %d Stk. von diesem Item dabei! (%s)", player, amount, itemName))
					return
				end 
			end
			local minRank, forFaction = 0, 0
			if FACTION_TRUNK_SWAT_ITEM_PERMISSIONS[itemName] then 
				minRank, forFaction = unpack(FACTION_TRUNK_SWAT_ITEM_PERMISSIONS[itemName])
			end
			if player:getFaction():getPlayerRank(player) >= minRank then
				if not forFaction or forFaction == 0 or forFaction == player:getFaction():getId() then
					if not isEquipment then
						self.m_FactionTrunk[itemName] = self.m_FactionTrunk[itemName]+amount
						player:sendShortMessage(_("Du hast %d %s in das Fahrzeug geladen!", player, amount, itemName))
						self:setData("factionTrunk", self.m_FactionTrunk, true)
					else 
						player:getFaction():getDepot():addEquipment(player, itemName, amount, true)
						player:sendShortMessage(_("Du hast %d %s gekauft! Diese wurden ins Lager abgelegt!", player, amount, itemName))
					end
					if price > 0 and not inventory then 
						player:getFaction().m_BankAccount:transferMoney(FactionState:getSingleton().m_BankAccountServer, price, "SWAT-Equipment", "Faction")
						player:getFaction():sendShortMessage(("%s hat %d %s gekauft!"):format(player:getName(), amount, itemName))
						player:getFaction():addLog(player, "Item", ("hat %d %s für $%s gekauft!"):format(amount, itemName, price))
					end
				else 
					if forFaction and forFaction > 0 then
						player:sendError(_("Nur Mitglieder des %s dürfen dies beladen!", player, FactionManager:getSingleton():getFromId(forFaction) and FactionManager:getSingleton():getFromId(forFaction):getName()))
					end
				end
			else 
				player:sendError(_("Du kannst dieses Item nicht kaufen!", player))
			end
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
				player:getFaction():addLog(player, "Item", ("hat %s in den %s (%s) gelegt!"):format(itemName, self:getName(), self:getPlateText()))
			end
		else
			player:sendError(_("Dieses Item ist nicht mehr im Fahrzeug! (%s)", player, itemName))
		end
	else
		player:sendError("Ungültiges Element!")
	end
end

function FactionVehicle:respawn(force, ignoreCooldown)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getFaction():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end
	
	if not ignoreCooldown then
		if self.m_LastDrivers[#self.m_LastDrivers] then
			local lastDriver = getPlayerFromName(self.m_LastDrivers[#self.m_LastDrivers])
			if lastDriver and (not lastDriver:getFaction() or lastDriver:getFaction() and lastDriver:getFaction() ~= self:getFaction()) then
				if self.m_LastUseTime and getTickCount() - self.m_LastUseTime < 300000 then
					return false
				end
			end
		end
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
	self:setInterior(self.m_SpawnInt or 0)
	self:setDimension(self.m_SpawnDim or 0)
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
	self.m_LastRespawn = getTickCount()
	return true
end

function FactionVehicle:sendOwnerMessage(msg)
	self:getFaction():sendShortMessage(msg)
end