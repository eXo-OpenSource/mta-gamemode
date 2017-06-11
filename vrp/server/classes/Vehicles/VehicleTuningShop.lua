-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleTuningShop.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuningShop = inherit(Singleton)
addEvent("vehicleUpgradesBuy", true)
addEvent("vehicleUpgradesAbort", true)

function VehicleTuningShop:constructor()
    addEventHandler("vehicleUpgradesBuy", root, bind(self.Event_vehicleUpgradesBuy, self))
    addEventHandler("vehicleUpgradesAbort", root, bind(self.Event_vehicleUpgradesAbort, self))

    -- Create map objects / remove objects
    removeWorldModel(5340, 5.8436832, 2646.542, -2039.1484, 14.05193)
    removeWorldModel(5043, 4.5020704, 1843.3203, -1856.1953, 14.1901)
    removeWorldModel(5779, 5.0575686, 1041.1357, -1025.9763, 32.77094)
    createObject(5340, 2644.8999, -2040, 15.6, 0, 270, 90)
    createObject(5043, 1845.4, -1856.3, 15.6, 0.051, 78.25, 359.755)
    createObject(11326, 2511.3999, -1775.7, 14.9, 0, 0, 180)
    createObject(5779, 1041.4, -1025.2, 35.5, 0, 19, 90)
    setGarageOpen(10, true)
	setGarageOpen(33, true)

    -- Create garages
    self.m_GarageInfo = {
        -- Entrance - Exit (pos, rot) - Interior
        {
            Vector3(1041.4, -1017.5, 31.3), -- LS Temple
            {Vector3(1041.9, -1031.5, 31.8), 180},
            Vector3(953.59998, -983.09998, 2454.8999) -- TODO: Add Toxsi's garage here
        }
    }

    for garageId, info in pairs(self.m_GarageInfo) do
        local position = info[1]
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, bind(self.EntryColShape_Hit, self, garageId))

        Blip:new("TuningGarage.png", position.x, position.y,root,600)
    end

    -- Register quit hook that moves the player out of the garage before saving
    Player.getQuitHook():register(
        function(player)
            -- Check if he is in a garage
            local vehicle = player:getOccupiedVehicle()
            if player.m_VehicleTuningGarageId and vehicle then
                self:closeFor(player, vehicle, true)
            end
        end
    )
end

function VehicleTuningShop:openFor(player, vehicle, garageId)
    player:triggerEvent("vehicleTuningShopEnter", vehicle or player:getPedOccupiedVehicle())

    vehicle:setFrozen(true)
    player:setFrozen(true)
    local position = self.m_GarageInfo[garageId][3]
    vehicle:setPosition(position)
    setTimer(function() warpPedIntoVehicle(player, vehicle) end, 500, 1)
    player.m_VehicleTuningGarageId = garageId

	player.m_WasBuckeled = getElementData(player, "isBuckeled")
end

function VehicleTuningShop:closeFor(player, vehicle, doNotCallEvent)
    if not doNotCallEvent then
        player:triggerEvent("vehicleTuningShopExit")
    end

    local garageId = player.m_VehicleTuningGarageId
    if garageId then
        local position, rotation = unpack(self.m_GarageInfo[garageId][2])
        if vehicle then
            vehicle:setFrozen(false)
            vehicle:setPosition(position)
            vehicle:setRotation(0, 0, rotation)
        end

        player:setPosition(position) -- Set player position also as it will not be updated automatically before quit
        player:setFrozen(false)
        player.m_VehicleTuningGarageId = nil

        -- Hackfix for MTA issue #4658
        if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
            teleportPlayerNextToVehicle(player, vehicle)
            warpPedIntoVehicle(player, vehicle)
        end

		if player.m_WasBuckeled then
			player.m_SeatBelt = vehicle
			setElementData(player, "isBuckeled", true)
		end
    end
end


function VehicleTuningShop:EntryColShape_Hit(garageId, hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle or hitElement:getOccupiedVehicleSeat() ~= 0 then return end

        if instanceof(vehicle, CompanyVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Firmenwagen darf nicht getunt werden!", hitElement))
              return
          end
		elseif instanceof(vehicle, FactionVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Fraktions-Wagen darf nicht getunt werden!", hitElement))
              return
          end
        elseif instanceof(vehicle, GroupVehicle) then
            if not vehicle:canBeModified() then
                hitElement:sendError(_("Dein Leader muss das Tunen von Fahrzeugen aktivieren! Im Firmen/Gangmenü unter Leader!", hitElement))
                return
            end
        elseif vehicle:isPermanent() then
            if vehicle:getOwner() ~= hitElement:getId() then
                hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge tunen!", hitElement))
                return
            end
        else
            hitElement:sendWarning(_("Achtung! Du tunst gerade ein temporäres Fahrzeug!", hitElement))
        end

        -- Remove occupants
        for seat, player in pairs(vehicle:getOccupants() or {}) do
            if seat ~= 0 then
                player:removeFromVehicle()
            end
        end

        local vehicleType = vehicle:getVehicleType()
        if vehicleType == VehicleType.Automobile or vehicleType == VehicleType.Bike then
            self:openFor(hitElement, vehicle, garageId)
        else
            hitElement:sendError(_("Mit diesem Fahrzeugtyp kannst du die Tuningwerkstatt nicht betreten!", hitElement))
        end
    end
end

function VehicleTuningShop:Event_vehicleUpgradesBuy(cartContent)
    local vehicle = client:getOccupiedVehicle()
    if not vehicle then return end

    -- Calculate price
    local overallPrice = 0
    for slot, upgradeId in pairs(cartContent) do
        if upgradeId ~= 0 then
            local price = getVehicleUpgradePrice(upgradeId)
            -- Search for part price if not available
           	if not price then
				price = getVehicleUpgradePrice(slot)
				if not price then
					price = 0
				else
					if not tonumber(price) then
						price = 0
					end
				end
			else
				if not tonumber(price) then
					price = getVehicleUpgradePrice(slot)
					if not price then
						price = 0
					else
						if not tonumber(price) then
							price = 0
						end
					end
				end
			end

            overallPrice = overallPrice + price
        end
    end

    if client:getMoney() < overallPrice then
        client:sendError(_("Du hast nicht genügend Geld!", client))
        return
    end

    client:takeMoney(overallPrice, "Tuningshop")

    for slot, upgradeId in pairs(cartContent) do
        if type(slot) == "number" and slot >= 0 then
            if upgradeId ~= 0 then
                vehicle:addUpgrade(upgradeId)
            else
                vehicle:removeUpgrade(vehicle:getUpgradeOnSlot(slot))
            end
        else
			--outputChatBox(slot..": "..tostring(upgradeId))
			if slot ~= "Texture" then
				vehicle.m_Tunings:saveTuning(slot, upgradeId)
			else
				vehicle.m_Tunings:addTexture(upgradeId, "vehiclegrunge256")
			end
        end
    end
	vehicle.m_Tunings:saveGTATuning()
	vehicle.m_Tunings:applyTuning()

    client:sendSuccess(_("Upgrades gekauft!", client))

	if instanceof(vehicle, PermanentVehicle, true) or instanceof(vehicle, GroupVehicle, true) then
		vehicle:save()
	end

    -- Exit
    self:closeFor(client, vehicle)
end

function VehicleTuningShop:Event_vehicleUpgradesAbort()
    self:closeFor(client, client:getOccupiedVehicle())
end
