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
	
	

	WeaponManager.WeaponToClass = 
	{
		[34] = SniperRifle:new(), 
		[35] = RocketLauncher:new()
	}

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
	
	if WEAPON_READY_TIME[weapon] then -- both of the following bugs work due to the script beeing latent when detecting wether a player is aiming or not, hence why the fixes for them are connected with confusing checks
		if (getPedControlState(localPlayer, "fire") or getPedControlState(localPlayer, "action")) and not getPedControlState("aim_weapon") then --bug#1 prevent player pressing fire then aiming to override cooldown
			WeaponManager.Weapon[weapon] = {ready = now + WEAPON_READY_TIME[weapon]+700}
		end
		if WeaponManager.WeaponToClass[weapon] and WeaponManager.WeaponToClass[weapon]:getSingleton() then -- bug#2 prevent player pressing both buttons to override cooldown
			if not WeaponManager.WeaponToClass[weapon]:getSingleton():isAiming() then
				WeaponManager.Weapon[weapon] = {ready = now + WEAPON_READY_TIME[weapon]+700}
			end
		end
	end

	if WeaponManager.Weapon[weapon] then 
		if WeaponManager.Weapon[weapon].ready and WeaponManager.Weapon[weapon].ready >= now then 
			toggleControl("fire", false)
			toggleControl("action", false)
		else 
			if (WeaponManager.Weapon[weapon].ready and (WeaponManager.Weapon[weapon].ready <= now)) and not NoDm:getSingleton():isInNoDmZone() and localPlayer:isControlEnabled() then
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
