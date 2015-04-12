-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleTuning.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuning = inherit(Singleton)
addEvent("vehicleUpgradesBuy", true)
addEvent("vehicleUpgradesAbort", true)

function VehicleTuning:constructor()
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

    -- Create garages
    self.m_GarageInfo = {
        -- Entrance - Exit (pos, rot) - Interior
        {
            Vector3(2644.8999, -2044, 12.6),
            {Vector3(2644.1, -2035, 13.5), 0},
            Vector3(990.70001, -1032, 2433.5)
        },
        {
            Vector3(1851, -1856.4, 12.4),
            {Vector3(1839.3, -1856.7, 13.2), 90},
            Vector3(1010.9, -982.59998, 2436.1001)
        },
        {
            Vector3(2496.3, -1778.8, 12.9),
            {Vector3(2496.3, -1788, 13.3), 180},
            Vector3(953.59998, -983.09998, 2454.8999)
        },
        {
            Vector3(1041.4, -1017.5, 31.3),
            {Vector3(1041.9, -1031.5, 31.8), 180},
            Vector3(953.59998, -983.09998, 2454.8999) -- TODO: Add Toxsi's garage here
        }
    }
    self.m_DimensionSlots = {}

    for garageId, info in pairs(self.m_GarageInfo) do
        local position = info[1]
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, bind(self.EntryColShape_Hit, self, garageId))

        Blip:new("TuningGarage.png", position.x, position.y)
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

function VehicleTuning:openFor(player, vehicle, garageId)
    player:triggerEvent("vehicleTuningShopEnter", vehicle or player:getPedOccupiedVehicle())

    vehicle:setFrozen(true)
    local position = self.m_GarageInfo[garageId][3]
    vehicle:setPosition(position)
    player.m_VehicleTuningGarageId = garageId

    -- Get a dimension slot and move both player and vehicle to it
    --[[local dimension = #self.m_DimensionSlots + 1
    self.m_DimensionSlots[dimension] = player
    player:setDimension(dimension)
    vehicle:setDimension(dimension)]]
end

function VehicleTuning:closeFor(player, vehicle, doNotCallEvent)
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

        --[[local dimension = table.find(self.m_DimensionSlots, player)
        if dimension then
            if vehicle then
                vehicle:setDimension(0)
            end
            player:setDimension(0)
        end]]

        player:setPosition(position) -- Set player position also as it will not be updated automatically before quit
        player.m_VehicleTuningGarageId = nil
    end
end


function VehicleTuning:EntryColShape_Hit(garageId, hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle then return end

        local vehicleType = vehicle:getVehicleType()
        if vehicleType == "Automobile" or vehicleType == "Bike" or vehicleType == "Quad" then
            self:openFor(hitElement, vehicle, garageId)
        else
            hitElement:sendError(_("Mit diesem Fahrzeugtyp kannst du die Tuningwerkstatt nicht betreten!", hitElement))
        end
    end
end

function VehicleTuning:Event_vehicleUpgradesBuy(cartContent)
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
            end

            overallPrice = overallPrice + price
        end
    end

    if client:getMoney() < overallPrice then
        client:sendError(_("Du hast nicht genügend Geld!", client))
        return
    end

    client:takeMoney(overallPrice)

    for slot, upgradeId in pairs(cartContent) do
        if slot >= 0 then
            if upgradeId ~= 0 then
                vehicle:addUpgrade(upgradeId)
            else
                vehicle:removeUpgrade(vehicle:getUpgradeOnSlot(upgradeId))
            end
        else
            if slot == VehicleSpecialProperty.Color then
                vehicle:setColor(unpack(upgradeId))
            end
        end
    end
    client:sendSuccess(_("Upgrades gekauft!", client))

    -- Exit
    self:closeFor(client, vehicle)
end

function VehicleTuning:Event_vehicleUpgradesAbort()
    self:closeFor(client, client:getOccupiedVehicle())
end
