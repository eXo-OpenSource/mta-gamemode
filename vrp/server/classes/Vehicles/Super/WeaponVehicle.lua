-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/WeaponVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
WeaponVehicle = inherit(Vehicle)
addRemoteEvents{"weaponVehicleHit"}

addEventHandler("weaponVehicleHit", root, function(target)
	if instanceof(source, WeaponVehicle) then
		source.m_LastHit = target
		target.m_LastHitBy = source
	end
end)

function WeaponVehicle:constructor()
	self:setFuel(self.m_Fuel or 100)
    self:setFuelDisabled(true)
	self.m_Temporary = true
    self:setData("hasWeapon", true, true)
    self:setData("weaponState", true, true)
    self:setData("weaponVisible", true, true)
	self:setCanBreak(false)
	self:setAlwaysDamageable(true)
	self:setData("disableCollisionCheck", true, true)

	self.m_OnEnter = bind(self.Event_onEnter, self)
	self.m_OnExit = bind(self.Event_onExit, self)
	self.m_OnFire = bind(self.Event_onFire, self)

	addEventHandler("onVehicleEnter", self, self.m_OnEnter)
	addEventHandler("onVehicleExit", self, self.m_OnExit)

	VehicleManager:getSingleton():addRef(self, true)
end

function WeaponVehicle:destructor()
	removeEventHandler("onVehicleEnter", self, self.m_OnEnter)
	removeEventHandler("onVehicleExit", self, self.m_OnExit)
    --VehicleManager:getSingleton():removeRef(self, true) (Vehicle.lua:45)
end

function WeaponVehicle:Event_onEnter(player, seat, jacked)
	if player:getType() == "player" and seat == 0 then
		bindKey(player, "mouse1", "both", self.m_OnFire)
		bindKey(player, "lctrl", "both", self.m_OnFire)
	end
end

function WeaponVehicle:Event_onExit(player, seat, jacked)
	if player:getType() == "player" and seat == 0 then
		unbindKey(player, "mouse1", "both", self.m_OnFire)
		unbindKey(player, "lctrl", "both", self.m_OnFire)
		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleFireWeapon", self, false)
	end
end

function WeaponVehicle:Event_onFire(player, key, keyState)
	if isElement(self) and self:getData("weaponState") then
   		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleFireWeapon", self, keyState == "down")
	end
end

function WeaponVehicle.create(model, position, rotation)
	rotation = tonumber(rotation) or 0
	local vehicle = createVehicle(model, position, rotation)
	if vehicle then
		enew(vehicle, WeaponVehicle)
	end
	return vehicle
end

function WeaponVehicle:isPermanent()
	return false
end

function WeaponVehicle:getWeapon()
	return self:getData("weapon")
end

function WeaponVehicle:setWeapon(model, offset, rotation)
	local offset = {x = offset.x, y = offset.y, z = offset.z}
	local rotation = {x = rotation.x, y = rotation.y, z = rotation.z}
    self:setData("weapon", model, true)
    self:setData("weaponOffset", offset, true)
    self:setData("weaponRotation", rotation, true)

    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetWeapon", self, model, offset, rotation)
end

function WeaponVehicle:removeWeapon()
    self:setData("weapon", nil, true)
    self:setData("weaponOffset", nil, true)
    self:setData("weaponRotation", nil, true)

    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetWeapon", self, nil, nil, nil)
end

function WeaponVehicle:enableWeapon()
    self:setData("weaponState", true, true)
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetState", self, true, self:getData("weaponVisible"))
end

function WeaponVehicle:disableWeapon()
    self:setData("weaponState", false, true)
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetState", self, false, self:getData("weaponVisible"))
end

function WeaponVehicle:showWeapon()
    self:setData("weaponVisible", true, true)
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetState", self, self:getData("weaponState"), true)
end

function WeaponVehicle:hideWeapon()
    self:setData("weaponVisible", false, true)
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "weaponVehicleSetState", self, self:getData("weaponState"), false)
end

function WeaponVehicle:respawn()
	-- Remove
	if not self.m_DisableRespawn == true then
		destroyElement(self)
	end
end

function WeaponVehicle:disableRespawn(state)
	self.m_DisableRespawn = state
end
