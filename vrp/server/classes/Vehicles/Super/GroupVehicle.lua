-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/GroupVehicle.lua
-- *  PURPOSE:     Group Vehicle class
-- *
-- ****************************************************************************
GroupVehicle = inherit(PermanentVehicle)

-- This function converts a normal (User/PermanentVehicle) to an GroupVehicle
function GroupVehicle.convertVehicle(vehicle, group)
	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
			local id = vehicle:getId()
			local premium = vehicle.m_Premium and vehicle.m_Owner or 0

			sql:queryExec("UPDATE ??_vehicles SET SalePrice = 0, Premium = ? WHERE Id = ?", sql:getPrefix(), premium, id)

			VehicleManager:getSingleton():removeRef(vehicle)
			vehicle.m_Owner = group:getId()
			vehicle.m_OwnerType = VehicleTypes.Group

			vehicle:save()
			destroyElement(vehicle)
			local veh = VehicleManager:getSingleton():createVehicle(id)

			return true, veh
			--[[
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local milage = vehicle:getMileage()
			local fuel = vehicle:getFuel()
			local tuningJSON = vehicle.m_Tunings:getJSON()
			local premium = vehicle:isPremiumVehicle() and vehicle:getOwner() or 0
			local dimension = 0
			local interior = 0
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()

			if vehicle:purge() then
				local vehicle = GroupVehicle.create(Group, model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, milage, fuel, trunkId, tuningJSON, premium, dimension, interior)
				vehicle:setHealth(health)

				return vehicle:save(), vehicle
			end]]
		end
	end

	return false
end

function GroupVehicle:constructor(data)
	self.m_Group = GroupManager:getFromId(data.OwnerId)
	setElementData(self, "OwnerName", self.m_Group:getName())
	setElementData(self, "OwnerType", "group")
	setElementData(self, "GroupType", self.m_Group:getType())

	if self.m_Group.m_Vehicles then
		table.insert(self.m_Group.m_Vehicles, self)
	end

	if data.SalePrice > 0 then
		self:setForSale(true, data.SalePrice)
	else
		self:setForSale(false, 0)
	end


	addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			if isElement(veh) then
				veh:respawn(true)
			end
		end, 10000, 1, source)
	end)
	--[[
	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
	]]
end

function GroupVehicle:destructor()

end

function GroupVehicle:getId()
	return self.m_Id
end

function GroupVehicle:getGroup()
  return self.m_Group
end
--[[
function GroupVehicle.create(Group, model, posX, posY, posZ, rotX, rotY, rotZ, milage, fuel, trunkId, tuningJSON, premium)
	if sql:queryExec("INSERT INTO ??_vehicles (OwnerId, OwnerType, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, TrunkId, Tunings, Premium) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", sql:getPrefix(), Group:getId(), VehicleTypes.Group, model, posX, posY, posZ, rotX, rotY, rotZ, trunkId, tuningJSON, premium) then
		return VehicleManager:getSingleton():createVehicle(sql:lastInsertId())
	end
	return false
end]]

function GroupVehicle:purge()
	if sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
		destroyElement(self)
		return true
	end
	return false
end

--[[ -> use save function of PermanentVehicle
function GroupVehicle:save()
	local health = getElementHealth(self)
	if self.m_Trunk then self.m_Trunk:save() end

	return sql:queryExec("UPDATE ??_vehicles SET `Group` = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, RotT = ?, Health = ?, PositionType = ?, Mileage = ?, Fuel = ?, TrunkId = ?, TuningsNew = ?, ForSale = ?, SalePrice = ? WHERE Id = ?", sql:getPrefix(),
   		self.m_Group:getId(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, health, self.m_PositionType, self:getMileage(), self:getFuel(), self.m_Trunk and self.m_Trunk:getId() or 0, self.m_Tunings:getJSON(), self.m_ForSale and 1 or 0, self.m_SalePrice or 0, self.m_Id)
end
]]

function GroupVehicle:isGroupPremiumVehicle()
	return self:isPremiumVehicle()
end

function GroupVehicle:hasKey(player)
  if self:isPermanent() then
    if player:getGroup() == self:getGroup() then
      return true
    end
  end

  return false
end

function GroupVehicle:addKey(player)
  return false
end

function GroupVehicle:removeKey(player)
  return false
end

function GroupVehicle:canBeModified()
  return self:getGroup():canVehiclesBeModified()
end

function GroupVehicle:respawn(force)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getGroup():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	if self.m_RespawnHook:call(self) then
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


	self:setEngineState(false)
	self:setPosition(self.m_SpawnPos)
	self:setRotation(self.m_SpawnRot)
	setElementDimension(self, self.m_SpawnDim or 0)
	setElementInterior(self, self.m_SpawnInt or 0)
	setVehicleOverrideLights(self, 1)
	self:setSirensOn(false)
	self:setFrozen(true)
	self:toggleELS(false)
	self:toggleDI(false)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:resetIndicator()
	self:fix()
	self:setForSale(self.m_ForSale, self.m_SalePrice)
	if not force then
		self:getGroup():sendShortMessage("Euer Fahrzeug ["..self.getNameFromModel(self:getModel()).."] wurde respawnt!")
	else 
		self:getGroup():sendShortMessage("Euer Fahrzeug ["..self.getNameFromModel(self:getModel()).."] wurde respawnt (administrativ)!")
	end
	if self.m_Magnet then
		detachElements(self.m_Magnet)
		self.m_Magnet:attach(self, 0, 0, -1.5)

		self.m_MagnetHeight = -1.5
		self.m_MagnetActivated = false
	end

	return true
end

function GroupVehicle:isForSale()
	return self.m_ForSale
end

function GroupVehicle:setForSale(sale, price)
	if sale then
		self.m_ForSale = true
		self.m_SalePrice = tonumber(price)
		self.m_DisableToggleEngine = true
		self.m_DisableToggleHandbrake = true
		self:setFrozen(true)
	else
		self.m_ForSale = false
		self.m_SalePrice = 0
		self.m_DisableToggleEngine = false
		self.m_DisableToggleHandbrake = false
	end
	setElementData(self, "forSale", self.m_ForSale, true)
	setElementData(self, "forSalePrice", tonumber(self.m_SalePrice), true)
end

function GroupVehicle:getVehicleTaxForGroup() -- some vehicles may not need taxation in groups, but if owned private
	if self:isGroupPremiumVehicle() then return 0 end
	if self:isForSale() and self:getSalePrice() <= 500000 then return 0 end
	if self:getPositionType() == VehiclePositionType.Mechanic then return 0 end
	return self:getTax()
end

function GroupVehicle:getSalePrice()
	return self.m_SalePrice
end

function GroupVehicle:buy(player)
	if self.m_ForSale then
		if self.m_SalePrice >= 0 and player:getBankMoney() >= self.m_SalePrice then
			if #player:getVehicles() < math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
				local group = self:getGroup()
				local price = self.m_SalePrice
				if player:transferBankMoney(group, price, "Firmen-Fahrzeug Kauf", "Group", "VehicleSell") then
					triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
					local status, newVeh = PermanentVehicle.convertVehicle(self, player, group)
					StatisticsLogger:getSingleton():addVehicleTradeLog(newVeh, player, 0, price, "group")
					group:sendShortMessage(_("%s hat ein Fahrzeug für %d$ gekauft! (%s)", player, player:getName(), price, newVeh:getName()))
					player:sendInfo(_("Das Fahrzeug ist nun in deinem Besitz!", player))
					group:addLog(player, "Fahrzeugverkauf", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." für "..price.." gekauft!")
					removeElementData(newVeh, "forSale")
					removeElementData(newVeh, "forSalePrice")
				else
					player:sendError(_("Es ist ein Fehler aufgetreten!", player))
				end
			else
				player:sendError(_("Du hast keinen freien Fahrzeug-Slot! Erhöhe dein Fahrzeuglevel! (%d/%d)", player, #player:getVehicles(), math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel())))
			end
		else
			player:sendError(_("Du hast nicht genug Geld dabei! (%d$)", player, self.m_SalePrice))
		end
	else
		player:sendError(_("Dieses Fahrzeug steht nicht zum verkauf!", player))
	end
end

function GroupVehicle:onEnter()
	return true -- otherwise last driver will not added
end

function GroupVehicle:sendOwnerMessage(msg)
	self.m_Group:sendShortMessage(msg)
end
