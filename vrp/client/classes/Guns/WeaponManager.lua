-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/WeaponManager.lua
-- *  PURPOSE:     Manages weapon data
-- *
-- ****************************************************************************

WeaponManager = inherit(Singleton)
WeaponManager.Weapon = {}

function WeaponManager:constructor() 
	RocketLauncher:new()
	SniperRifle:new()

	addEventHandler("onClientPreRender", root, bind(self.update, self))
	addEventHandler("onClientRender", root, bind(self.render, self))
	addEventHandler("onClientPlayerWeaponFire", localPlayer, bind(self.fire, self))
end

function WeaponManager:destructor() 

end

function WeaponManager:fire(weapon, ammo, ammoClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ) 
	if WEAPON_RELOAD_TIME[weapon] then
		WeaponManager.Weapon[weapon] = {ready = getTickCount() + WEAPON_RELOAD_TIME[weapon]}
	end
	if weapon == 35 then 
		RocketLauncher:getSingleton():fire(weapon, ammo, ammoClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)
	end
end

function WeaponManager:update() 
	RocketLauncher:getSingleton():update()
	SniperRifle:getSingleton():update()

	local weapon = localPlayer:getWeapon() 
	local now = getTickCount() 
	
	if WEAPON_READY_TIME[weapon] then
		if getKeyState("mouse1") and not getKeyState("mouse2") then
			WeaponManager.Weapon[weapon] = {ready = now + WEAPON_READY_TIME[weapon]}
		end
	end

	if WeaponManager.Weapon[weapon] then 
		if WeaponManager.Weapon[weapon].ready and WeaponManager.Weapon[weapon].ready >= now then 
			toggleControl("fire", false)
			toggleControl("action", false)
		else 
			if not NoDm:getSingleton():isInNoDmZone() and localPlayer:isControlEnabled() then
				toggleControl("fire", true)
				toggleControl("action", true)
			end
		end
	end
end

function WeaponManager:notify() 

end

function WeaponManager:render() 
	SniperRifle:getSingleton():render()
end

function WeaponManager:isAimingRocketLauncher() 
	return RocketLauncher:getSingleton().m_Aiming
end
