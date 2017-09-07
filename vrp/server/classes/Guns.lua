-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Guns/Guns.lua
-- *  PURPOSE:     Server Gun Class
-- *
-- ****************************************************************************

_giveWeapon = giveWeapon
_takeWeapon = takeWeapon
_takeAllWeapons = takeAllWeapons
Guns = inherit(Singleton)

function Guns:constructor()
	local weaponSkills = {"std","pro","poor"}

	for index,skill in pairs(weaponSkills) do
		-- Taser:
		setWeaponProperty(23, skill, "weapon_range", 10 )
		setWeaponProperty(23, skill, "maximum_clip_ammo", 9999 )
		setWeaponProperty(23, skill, "anim_loop_stop", 0 )
		-- Deagle:
		setWeaponProperty(24, skill, "target_range",45) -- GTA-Std: 35
		setWeaponProperty(24, skill, "weapon_range",45) -- GTA-Std: 35
		setWeaponProperty(24, skill, "accuracy",1.2) -- GTA-Std: 1.25
		-- Uzi:
		setWeaponProperty(28, skill, "accuracy",1.1000000238419) -- GTA-Std: 1.1000000238419
		-- MP5:
		setWeaponProperty(29, skill, "accuracy", 1.4) -- GTA-Std: 1.2000000476837
		-- M4:
		setWeaponProperty(31, skill, "accuracy", 0.9) -- GTA-Std: 0.80000001192093
		setWeaponProperty(31, skill, "weapon_range",105) -- GTA-Std: 90
		-- Tec-9:
		setWeaponProperty(32, skill, "weapon_range",50) -- GTA-Std: 35
		setWeaponProperty(32, skill, "target_range",50) -- GTA-Std: 35
		setWeaponProperty(32, skill, "accuracy",1.1999999523163) -- GTA-Std: 1.1000000238419
		-- Rifle:
		setWeaponProperty(33, skill, "weapon_range", 160) -- GTA-Std: 100
		setWeaponProperty(33, skill, "target_range", 160) -- GTA-Std: 55
	end

	addRemoteEvents{"onTaser", "onClientDamage", "onClientKill", "onClientWasted", "gunsLogMeleeDamage"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
	addEventHandler("onClientDamage", root, bind(self.Event_onClientDamage, self))
	addEventHandler("gunsLogMeleeDamage", root, bind(self.Event_logMeleeDamage, self))
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
	toggleAllControls(target,false, true, false)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	target.isTasered = true
	setElementData(target, "isTasered", true)
	setTimer ( function(target)
		setElementData(target, "isTasered", false)
		target:setAnimation()
		target:setFrozen(false)
		toggleAllControls(target,true, true, false)
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
								outputChatBox("Dein Schuss zerstörte den Helm von "..getPlayerName(target).."!", source, 200,200,0)
								target:triggerEvent("clientBloodScreen")
								return
							end
						end
					end
				end
			end
			target:triggerEvent("clientBloodScreen")
			target:setHeadless(true)
			self:killPed(target, attacker, weapon, bodypart)
		end
	else
		if target and attacker and isElement(target) and isElement(attacker) then
			if not target.m_SupMode and not attacker.m_SupMode then
				target:triggerEvent("clientBloodScreen")
				local basicDamage = WEAPON_DAMAGE[weapon]
				local multiplier = DAMAGE_MULTIPLIER[bodypart] and DAMAGE_MULTIPLIER[bodypart] or 1
				local realLoss = basicDamage*multiplier
				self:damagePlayer(target, realLoss, attacker, weapon, bodypart)
			end
		end
	end
end

function Guns:killPed(target, attacker, weapon, bodypart)
	StatisticsLogger:getSingleton():addKillLog(attacker, target, weapon)
	if not target:getData("isInDeathMatch") then
		target:setReviveWeapons()
	end
	target:kill(attacker, weapon, bodypart)
	if not target:getData("isInDeathMatch") then
		if target:getFaction() and target:getFaction():isEvilFaction() and attacker:getFaction() and attacker:getFaction():isEvilFaction() then
			local attackerFaction = attacker:getFaction()
			local targetFaction = target:getFaction()
			if not attacker:isInGangwar() then
				if attackerFaction:getDiplomacy(targetFaction) == FACTION_DIPLOMACY["im Krieg"] then
					local bonus = targetFaction:getMoney() >= FACTION_WAR_KILL_BONUS and FACTION_WAR_KILL_BONUS or targetFaction:getMoney()
					targetFaction:takeMoney(bonus, ("Mord von %s an %s"):format(attacker:getName(), target:getName()))
					attackerFaction:giveMoney(bonus, ("Mord von %s an %s"):format(attacker:getName(), target:getName()))
				end
			end
		end
	end
end

function Guns:Event_logMeleeDamage(target, weapon, bodypart, loss)
	StatisticsLogger:getSingleton():addDamageLog(client, target, weapon, bodypart, loss)
end

function Guns:Event_onClientKill(kill, weapon, bodypart, loss)

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
				self:killPed(player, attacker, weapon, bodypart)
			else
				player:setHealth(health-loss)
			end
		end
	else
		if player:getHealth()-loss <= 0 then
			self:killPed(player, attacker, weapon, bodypart)
		else
			player:setHealth(health-loss)
		end
	end
	StatisticsLogger:getSingleton():addDamageLog(attacker, player, weapon, bodypart, loss)
	--StatisticsLogger:getSingleton():addTextLog("damage", ("%s wurde von %s mit Waffe %s am %s getroffen! (Damage: %d)"):format(player:getName(), attacker:getName(), WEAPON_NAMES[weapon], BODYPART_NAMES[bodypart], loss))
end

function giveWeapon( player, weapon, ammo, current)
	local slot = getSlotFromWeapon(weapon)
	local object = getElementData(player, "a:weapon:slot"..slot.."")
	if object then
		if isElement(object) and player and ammo then
			local wId = getElementData(object, "a:weapon:id")
			if ammo ~= 0 then
				if wId ~= weapon then
					triggerEvent("WeaponAttach:onWeaponGive", player, weapon, slot, current, object)
				end
			end
		end
	else
		if player and ammo then
			if ammo ~= 0 then
				local currentWeapon = getPedWeapon(player,slot)
				if currentWeapon ~= weapon then
					triggerEvent("WeaponAttach:onWeaponGive", player, weapon, slot, current, object)
				end
			end
		end
	end
	local result = _giveWeapon(player, weapon, ammo, current)
	return result
end

function takeWeapon( player, weapon, ammo)
	local slot = getSlotFromWeapon(weapon)
	local object = getElementData(player, "a:weapon:slot"..slot.."")
	if object then
		if isElement(object) then
			local wId = getElementData(object, "a:weapon:id")
			local tAmmo = getPedTotalAmmo (player, slot)
			if not ammo then
				if (wId == weapon ) then
					triggerEvent("WeaponAttach:onWeaponTake", player, weapon, slot)
				end
			else
				if ammo and tAmmo then
					if ( wId == weapon and (ammo >= tAmmo)) then
						triggerEvent("WeaponAttach:onWeaponTake", player, weapon, slot)
					end
				end
			end
		end
	end
	local result = _takeWeapon(player, weapon, ammo)
	return result
end

function takeAllWeapons( player )
	if player then
		if getElementHealth(player) > 0 then
			triggerEvent("WeaponAttach:removeAllWeapons", player)
		end
	end
	local result = _takeAllWeapons( player )
	return result
end
