VehicleWeapon = inherit(Singleton)
addRemoteEvents{"weaponVehicleSetWeapon", "weaponVehicleFireWeapon", "weaponVehicleSetState"}

-- https://wiki.multitheftauto.com/wiki/OnClientWeaponFire

function VehicleWeapon:constructor()
    self.m_onWeaponFire = bind(self.Event_onWeaponFire, self)
    self.m_onVehicleDestroy = bind(self.Event_onVehicleDestroy, self)
    
	self.m_HitPath = fileExists("_custom/files/audio/hitsound.wav") and "_custom/files/audio/hitsound.wav" or "files/audio/hitsound.wav"

    addEventHandler("weaponVehicleSetWeapon", root, bind(self.Event_setWeapon, self))
    addEventHandler("weaponVehicleFireWeapon", root, bind(self.Event_fireWeapon, self))
    addEventHandler("weaponVehicleSetState", root, bind(self.Event_setState))
    addEventHandler("onClientElementStreamIn", root, bind(self.Event_onStreamIn, self))
    addEventHandler("onClientElementStreamOut", root, bind(self.Event_onStreamOut, self))
end

function VehicleWeapon:Event_setWeapon(weapon, offset, rotation)
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end

    local streamedIn = false
    for k, vehicle in ipairs(getElementsByType("vehicle", root, true)) do
        if vehicle == source then
            streamedIn = true
            break
        end
    end

    if streamedIn then
        self:setWeapon(source, weapon, offset, rotation)
    end
end

function VehicleWeapon:Event_onVehicleDestroy()
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end

    if source.m_Weapon then
        destroyElement(source.m_Weapon)
        source.m_Weapon = nil
        removeEventHandler("onClientElementDestroy", vehicle, self.m_onVehicleDestroy)
    end
end

function VehicleWeapon:Event_onStreamIn()
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end

    self:setWeapon(source, source:getData("weapon"), source:getData("weaponOffset"), source:getData("weaponRotation"))
end

function VehicleWeapon:Event_onStreamOut()
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end
    
    if source.m_Weapon then
        destroyElement(source.m_Weapon)
        source.m_Weapon = nil
        removeEventHandler("onClientElementDestroy", vehicle, self.m_onVehicleDestroy)
    end
end

function VehicleWeapon:Event_fireWeapon(fire)
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end

    if source.m_Weapon then
        source.m_Weapon:setState(fire and "firing" or "ready")
    end
end

function VehicleWeapon:Event_setState(state, visible)
    if source:getType() ~= "vehicle" or not source:getData("hasWeapon") then return end

    if source.m_Weapon then
        if not state then
            source.m_Weapon:setState("ready")
        end

        if visible then
            source.m_Weapon:setAlpha(255)
        else
            source.m_Weapon:setAlpha(0)
        end
    end
end

function VehicleWeapon:Event_onWeaponFire(element, posX, posY, posZ, normalX, normalY, normalZ, materialType, lighting, pieceHit)
    if not element then return end
    if element:getType() ~= "player" and element:getType() ~= "ped" and element:getType() ~= "vehicle" then return end
    
    if source.m_Vehicle:isSyncer() then
        if core:get("Sounds", "HitBell", true) then
            playSound(self.m_HitPath or "files/audio/hitsound.wav")
        end

        if element.lastDamagedBy ~= source.m_Vehicle then
            triggerServerEvent("weaponVehicleHit", source.m_Vehicle, element)
        end
    end

    element.lastDamagedBy = source.m_Vehicle
end

function VehicleWeapon:setWeapon(vehicle, weapon, offset, rotation)
    if vehicle:getType() ~= "vehicle" or not vehicle:getData("hasWeapon") then return end

    if vehicle.m_Weapon then
        removeEventHandler("onClientWeaponFire", vehicle.m_Weapon, self.m_onWeaponFire)
        destroyElement(vehicle.m_Weapon)
        vehicle.m_Weapon = nil
        removeEventHandler("onClientElementDestroy", vehicle, self.m_onVehicleDestroy)
    end

    if weapon then
        vehicle.m_Weapon = createWeapon(weapon, vehicle.position)
        vehicle.m_Weapon:setInterior(vehicle.interior)
        vehicle.m_Weapon:setDimension(vehicle.dimension)
        vehicle.m_Weapon:attach(vehicle, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z)
        vehicle.m_Weapon.m_Vehicle = vehicle
        addEventHandler("onClientWeaponFire", vehicle.m_Weapon, self.m_onWeaponFire)
        addEventHandler("onClientElementDestroy", vehicle, self.m_onVehicleDestroy)

        if weapon == "minigun" then
            vehicle.m_Weapon:setProperty("fire_rotation", 0, -30, 0)
        end

        if not vehicle:getData("weaponVisible") then
            vehicle.m_Weapon:setAlpha(0)
        end
    end
end
