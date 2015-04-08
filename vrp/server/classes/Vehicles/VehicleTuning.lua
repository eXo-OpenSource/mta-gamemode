-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleTuning.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuning = inherit(Singleton)
addEvent("vehicleUpgradesBuy", true)

function VehicleTuning:constructor()
    addEventHandler("vehicleUpgradesBuy", root, bind(self.Event_vehicleUpgradesBuy, self))

    -- Create map objects / remove objects
    removeWorldModel(5340, 5.8436832, 2646.542, -2039.1484, 14.05193)
    removeWorldModel(5043, 4.5020704, 1843.3203, -1856.1953, 14.1901)
    removeWorldModel(5779, 5.0575686, 1041.1357, -1025.9763, 32.77094)
    createObject(5340, 2644.8999, -2040, 15.6, 0, 270, 90)
    createObject(5043, 1845.4, -1856.3, 15.6, 0.051, 78.25, 359.755)
    createObject(11326, 2511.3999, -1775.7, 14.9, 0, 0, 180)
    createObject(5779, 1041.4, -1025.2, 35.5, 0, 19, 90)

    -- Create garages
    local garageEntries = {
        Vector3(2644.8999, -2044, 12.6),
        Vector3(1851, -1856.4, 12.4),
        Vector3(2496.3, -1778.8, 12.9),
        Vector3(1041.4, -1017.5, 31.3)
    }

    local colShapeHitFunc = bind(self.EntryColShape_Hit, self)
    for k, position in pairs(garageEntries) do
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, colShapeHitFunc)
    end
end

function VehicleTuning:openFor(player, vehicle)
    player:triggerEvent("vehicleTuningShopEnter", vehicle or player:getPedOccupiedVehicle())
end

function VehicleTuning:closeFor(player)
    player:triggerEvent("vehicleTuningShopExit")
end


function VehicleTuning:EntryColShape_Hit(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle then return end

        local vehicleType = vehicle:getVehicleType()
        if vehicleType == "Automobile" or vehicleType == "Bike" or vehicleType == "Quad" then

            vehicle:setFrozen(true)
            vehicle:setPosition(990.70001, -1032, 2433.5)
            self:openFor(hitElement, vehicle)

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
            overallPrice = overallPrice + getVehicleUpgradePrice(upgradeId)
        end
    end

    if client:getMoney() < overallPrice then
        client:sendError(_("Du hast nicht genügend Geld!", client))
        return
    end

    client:takeMoney(overallPrice)

    for slot, upgradeId in pairs(cartContent) do
        if upgradeId ~= 0 then
            vehicle:addUpgrade(upgradeId)
        else
            vehicle:removeUpgrade(vehicle:getUpgradeOnSlot(upgradeId))
        end
    end
    client:sendSuccess(_("Upgrades gekauft!", client))

    -- Exit
    self:closeFor(client)
    vehicle:setFrozen(false)
    vehicle:setPosition(0, 0, 5)
end
