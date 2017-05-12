-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Guns/Guns.lua
-- *  PURPOSE:     Server Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	local weaponSkills = {"std","pro","poor"}

	for index,skill in pairs(weaponSkills) do
		-- Taser:
		setWeaponProperty (23, skill, "weapon_range", 10 )
		setWeaponProperty (23, skill, "maximum_clip_ammo", 9999 )
		setWeaponProperty (23, skill, "anim_loop_stop", 0 )
	end

	addRemoteEvents{"onTaser", "onClientDamage", "onClientKill", "onClientWasted", "gunsLogMeleeDamage","Guns:toggleWeapon"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
	addEventHandler("onClientDamage", root, bind(self.Event_onClientDamage, self))
	addEventHandler("gunsLogMeleeDamage", root, bind(self.Event_logMeleeDamage, self))
	addEventHandler("Guns:toggleWeapon", root, bind(self.Event_ToggleWeapon, self))
	--addEventHandler("onPlayerWeaponSwitch", root, bind(self.Event_WeaponSwitch, self))

end


function Guns:destructor()

end

function Guns:Event_WeaponSwitch( pw, cw) --// sync bug fix "schlagbug"
	local slot = getSlotFromWeapon(cw)
	if slot >= 2 and slot <= 6 then
		giveWeapon(source, cw, 0)
	end
end

function Guns:Event_onTaser(target)
	if not (client:getFaction() and client:getFaction():isStateFaction() and client:isFactionDuty()) then return end -- Report possible cheat attempt
	if getDistanceBetweenPoints3D(client.position, target.position) > 10 then return end
	if client.vehicle or target.vehicle then return end
	
	client:giveAchievement(65)

	target:setAnimation("crack", "crckdeth2",-1,true,true,false)
	toggleAllControls(target,false)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	target.isTasered = true
	setElementData(target, "isTasered", true)
	setTimer ( function(target)
		setElementData(target, "isTasered", false)
		target:setAnimation()
		target:setFrozen(false)
		toggleAllControls(target,true)
		target.isTasered = false
	end, 15000, 1, target )
end

function Guns:Event_onClientDamage(target, weapon, bodypart, loss)
	if getPedWeapon(client) ~= weapon then return end -- Todo: Report possible cheat attempt
	--if getDistanceBetweenPoints3D(client.position, target.position) > 200 then return end -- Todo: Report possible cheat attempt
	
	local attacker = client
	if weapon == 34 and bodypart == 9 then
		if not target.m_SupMode and not attacker.m_SupMode then
			local hasHelmet = target.m_Helmet
			if hasHelmet then 
				local isProtectingHeadShot = hasHelmet:getData("isProtectingHeadshot")
				if isProtectingHeadShot then 
					local inventory = target:getInventory()
					if inventory then
						local itemCount = inventory:getItemAmount("Einsatzhelm")
						if itemCount > 0 then 
							local isProtect = math.random(1,8)
							if isProtect == 1 then
								inventory:removeItem("Einsatzhelm", 1)
								destroyElement(hasHelmet)
								target:meChat(true, "wird von einer Kugel am Helm getroffen, welcher zerspringt!")
								target.m_IsWearingHelmet = false
								target.m_Helmet = false
								target:setData("isFaceConcealed", false)
								outputChatBox("Dein Schuss zerstörte den Helm von "..getPlayerName(target).." !", source, 200,200,0)
								target:triggerEvent("clientBloodScreen")
								return
							end
						end
					end
				end
			end
			target:triggerEvent("clientBloodScreen")
			target:setHeadless(true)
			StatisticsLogger:getSingleton():addKillLog(attacker, target, weapon)
			if not target:getData("isInDeathMatch") then
				target:setReviveWeapons()
			end
			target:kill(attacker, weapon, bodypart)
		end
	else
		if not target.m_SupMode and not attacker.m_SupMode then
			target:triggerEvent("clientBloodScreen")
			local basicDamage = WEAPON_DAMAGE[weapon]
			local multiplier = DAMAGE_MULTIPLIER[bodypart] and DAMAGE_MULTIPLIER[bodypart] or 1
			local realLoss = basicDamage*multiplier
			self:damagePlayer(target, realLoss, attacker, weapon, bodypart)
		end
	end
end

function Guns:Event_logMeleeDamage(target, weapon, bodypart, loss)
	StatisticsLogger:getSingleton():addDamageLog(client, target, weapon, bodypart, loss)
end

function Guns:Event_onClientKill(kill, weapon, bodypart, loss)

end

function Guns:Event_ToggleWeapon( oldweapon )
	if oldweapon then 
		if client then 
			if not client.m_WeaponStorage then client.m_WeaponStorage = {} end 
			local slot = getSlotFromWeapon(oldweapon) 
			if client.m_WeaponStorage[slot] then
				local weaponInStorage, ammoInStorage = unpack(client.m_WeaponStorage[slot])
				if getSlotFromWeapon(weaponInStorage) == slot then
					if weaponInStorage and ammoInStorage then
						client.m_WeaponStorage[slot] = {oldweapon, getPedTotalAmmo(client,slot)}
						giveWeapon(client, weaponInStorage, ammoInStorage, true)
						if weaponInStorage == 23 then 
							client:meChat(true, "zieht seinen Taser.")
							setTimer(setPedAnimation, 1000, 1, client, false)
						end
						setPedAnimation(client, "shop", "shp_gun_threat", 500, false, false, false)
					end
				end
			end
		end
	end
end

function Guns:setWeaponInStorage(player, weapon, ammo)
	if weapon and player then 
		if not player.m_WeaponStorage then 
			player.m_WeaponStorage = {}
		end
		player.m_WeaponStorage[getSlotFromWeapon(weapon)] = {weapon, ammo}
		setElementData(player, "hasSecondWeapon", true)
	else 
		if not player.m_WeaponStorage then 
			player.m_WeaponStorage = {}
		end
		for i = 1,10 do 
			player.m_WeaponStorage[i] = {false, false}
			setElementData(player, "hasSecondWeapon", false)
		end
	end
end

function Guns:getWeaponInStorage( player, slot)
	if player and slot then 
		if not player.m_WeaponStorage then 
			player.m_WeaponStorage = {}
			return false, false
		end
		if player.m_WeaponStorage then 
			if not player.m_WeaponStorage[slot] then 
				return false, false
			end
			local weaponInStorage, ammoInStorage = unpack(player.m_WeaponStorage[slot])
			if weaponInStorage and ammoInStorage then 
				return weaponInStorage, ammoInStorage
			end
		end
	end
	return false, false
end

function Guns:damagePlayer(player, loss, attacker, weapon, bodypart)
	local armor = getPedArmor ( player )
	local health = getElementHealth ( player )
	if armor > 0 then
		if armor >= loss then
			player:setArmor(armor-loss)
		else
			loss = math.abs(armor-loss)
			player:setArmor(0)

			if health - loss <= 0 then
				StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
				if not player:getData("isInDeathMatch") then
					player:setReviveWeapons()
				end
				player:kill(attacker, weapon, bodypart)
			else
				player:setHealth(health-loss)
			end
		end
	else
		if player:getHealth()-loss <= 0 then
			StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
			if not player:getData("isInDeathMatch") then
				player:setReviveWeapons()
			end
			player:kill(attacker, weapon, bodypart)
		else
			player:setHealth(health-loss)
		end
	end
	StatisticsLogger:getSingleton():addDamageLog(attacker, player, weapon, bodypart, loss)
	--StatisticsLogger:getSingleton():addTextLog("damage", ("%s wurde von %s mit Waffe %s am %s getroffen! (Damage: %d)"):format(player:getName(), attacker:getName(), WEAPON_NAMES[weapon], BODYPART_NAMES[bodypart], loss))
end
