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
GUN_CACHE_EMPTY_INTERVAL = 60*1000*2
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
		-- MP5:
		setWeaponProperty(29, skill, "accuracy", 1.4) -- GTA-Std: 1.2000000476837
		-- M4:
		setWeaponProperty(31, skill, "accuracy", 0.9) -- GTA-Std: 0.80000001192093
		setWeaponProperty(31, skill, "weapon_range",105) -- GTA-Std: 90
		-- Tec-9:
		setWeaponProperty(32, skill, "accuracy",1.1999999523163) -- GTA-Std: 1.1000000238419
		-- Rifle:
		setWeaponProperty(33, skill, "weapon_range", 160) -- GTA-Std: 100
		setWeaponProperty(33, skill, "target_range", 160) -- GTA-Std: 55
	end

	addRemoteEvents{"onTaser", "onClientDamage", "onClientKill", "onClientWasted", "gunsLogMeleeDamage"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
	addEventHandler("onClientDamage", root, bind(self.Event_onClientDamage, self))
	addEventHandler("gunsLogMeleeDamage", root, bind(self.Event_logMeleeDamage, self))

	addEventHandler("onPlayerWasted", root,  bind(self.Event_OnWasted, self))
	--addEventHandler("onPlayerWeaponSwitch", root, bind(self.Event_WeaponSwitch, self))
	self.m_DamageLogCache = { }
	setTimer(bind(self.Event_onGunLogCacheTick, self), 5000, 0)
end


function Guns:destructor()
	for id, cacheObj in pairs(self.m_DamageLogCache) do 
		self:forceDamageLogCache(  id ) 
	end
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
		if target and isElement(target) then
			setElementData(target, "isTasered", false)
			target:setAnimation()
			target:setFrozen(false)
			toggleAllControls(target,true, true, false)
			target.isTasered = false
		end
	end, 15000, 1, target )
end

function Guns:Event_onClientDamage(target, weapon, bodypart, loss, isMelee)
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
				if weapon == 25 or weapon == 26 then -- lower dmg for shotguns based on distance (because by default the first shot always does max dmg)
					local dist = getDistanceBetweenPoints3D(attacker.position, target.position)
					local maxDist = getWeaponProperty(weapon, "poor", "weapon_range")*2
					basicDamage = basicDamage*((maxDist-dist)/maxDist)
				elseif isMelee then -- use this variable instead: In case of delayed triggering to the server it may happen that the person runs into the melee-range after a shot and the server wrongly considers it to be in melee-range
					basicDamage = math.random(2, 5)
				end
				local multiplier = DAMAGE_MULTIPLIER[bodypart] and DAMAGE_MULTIPLIER[bodypart] or 1
				local realLoss = basicDamage*multiplier
				self:damagePlayer(target, realLoss, attacker, weapon, bodypart)
			end
		end
	end
end

function Guns:killPed(target, attacker, weapon, bodypart)
	target:kill(attacker, weapon, bodypart)
end


function Guns:Event_OnWasted(totalAmmo, killer, weapon)
	local killer = killer
	if isElement(killer) and getElementType(killer) == "vehicle" then 
		killer = killer.controller
	end
	if killer and isElement(killer) and weapon then
		StatisticsLogger:getSingleton():addKillLog(killer, source, weapon)
	end

	if source:getExecutionPed() then delete(source:getExecutionPed()) end
	
	if not killer or (not source:getData("isInDeathMatch") and not killer:getData("isInDeathmatch") and not source:getData("inWare")) then
		local inv = source:getInventory()
		ExecutionPed:new( source, weapon, bodypart)
		if inv then
			if inv:getItemAmount("Diebesgut") > 0 then
				inv:removeAllItem("Diebesgut")
				outputChatBox("Dein Diebesgut ging verloren...", source, 200,0,0)
			end
		end

		local sourceFaction = source:getFaction()
		if killer and isElement(killer) and sourceFaction and killer:getFaction() and not killer:isDead() then
			local killerFaction = killer:getFaction()
			if sourceFaction.m_Id ~= 4 then
				if sourceFaction:isStateFaction() and source:isFactionDuty() then
					if not killerFaction:isStateFaction() then
						killer:givePoints(15)
					end
				else
					if killerFaction:isStateFaction() then
						outputDebug(killer)
					end
				end
			end

			if sourceFaction:isEvilFaction() and killerFaction:isEvilFaction() then
				if not killer:isInGangwar() then
					if killerFaction:getDiplomacy(sourceFaction) == FACTION_DIPLOMACY["im Krieg"] then
						local bonus = sourceFaction:getMoney() >= FACTION_WAR_KILL_BONUS and FACTION_WAR_KILL_BONUS or sourceFaction:getMoney()
						sourceFaction:transferMoney(killerFaction, bonus, ("Mord von %s an %s"):format(killer:getName(), source:getName()), "Faction", "Kill")
					end
				end
			end
		end
	end
end

function Guns:Event_logMeleeDamage(target, weapon, bodypart, loss)
	--StatisticsLogger:getSingleton():addDamageLog(client, target, weapon, bodypart, loss)
	self:addDamageLog(target, loss, client, weapon, bodypart)
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
				player.m_LossBeforeDead = loss
				self:killPed(player, attacker, weapon, bodypart)
			else
				player:setHealth(health-loss)
			end
		end
	else
		if player:getHealth()-loss <= 0 then
			player.m_LossBeforeDead = loss
			self:killPed(player, attacker, weapon, bodypart)
		else
			player:setHealth(health-loss)
		end
	end
	--StatisticsLogger:getSingleton():addDamageLog(attacker, player, weapon, bodypart, loss)
	--StatisticsLogger:getSingleton():addTextLog("damage", ("%s wurde von %s mit Waffe %s am %s getroffen! (Damage: %d)"):format(player:getName(), attacker:getName(), WEAPON_NAMES[weapon], BODYPART_NAMES[bodypart], loss))
	self:addDamageLog(player, loss, attacker, weapon, bodypart)
end

function Guns:addDamageLog( player, loss, attacker, weapon, bodypart) 
	if self.m_DamageLogCache then 
		local cacheTable = self.m_DamageLogCache[attacker.m_Id] 
		if cacheTable then 
			local cacheWeapon = cacheTable["Weapon"]
			local cacheTarget = cacheTable["Target"]
			if weapon == cacheWeapon and player.m_Id == cacheTarget then 
				cacheTable["TotalLoss"] = cacheTable["TotalLoss"] + loss
				cacheTable["HitCount"] = cacheTable["HitCount"] + 1
			else 
				self:forceDamageLogCache( attacker ) 
				self.m_DamageLogCache[attacker.m_Id]  = {}
				self.m_DamageLogCache[attacker.m_Id]["CacheTime"] = getTickCount() 
				self.m_DamageLogCache[attacker.m_Id]["Timestamp"] = getRealTime().timestamp
				self.m_DamageLogCache[attacker.m_Id]["Weapon"] = weapon 
				self.m_DamageLogCache[attacker.m_Id]["Target"] = player.m_Id
				self.m_DamageLogCache[attacker.m_Id]["TotalLoss"] = loss 
				self.m_DamageLogCache[attacker.m_Id]["HitCount"] = 1
				self.m_DamageLogCache[attacker.m_Id]["Zone"] = StatisticsLogger:getSingleton():getZone(attacker)
			end
		else 
			self:forceDamageLogCache( attacker ) 
			self.m_DamageLogCache[attacker.m_Id]  = {}
			self.m_DamageLogCache[attacker.m_Id]["CacheTime"] = getTickCount() 
			self.m_DamageLogCache[attacker.m_Id]["Timestamp"] = getRealTime().timestamp
			self.m_DamageLogCache[attacker.m_Id]["Weapon"] = weapon 
			self.m_DamageLogCache[attacker.m_Id]["Target"] = player.m_Id
			self.m_DamageLogCache[attacker.m_Id]["TotalLoss"] = loss 
			self.m_DamageLogCache[attacker.m_Id]["HitCount"] = 1
			self.m_DamageLogCache[attacker.m_Id]["Zone"] = StatisticsLogger:getSingleton():getZone(attacker)
		end
	end
end

function Guns:forceDamageLogCache( player ) 
	if self.m_DamageLogCache then 
		local cacheTable, playerId
		if type(player) == "userdata" then 
			cacheTable = self.m_DamageLogCache[player.m_Id] 
			playerId = player.m_Id
		else 
			cacheTable = self.m_DamageLogCache[player] 
			playerId = player
		end
		if cacheTable then 
			local cacheWeapon = cacheTable["Weapon"] 
			local totalLoss = cacheTable["TotalLoss"]
			local hitCount = cacheTable["HitCount"]
			local target = cacheTable["Target"]
			local startTime = cacheTable["Timestamp"]
			local zone = cacheTable["Zone"]
			StatisticsLogger:getSingleton():addDamageLog(player, target, cacheWeapon, startTime, totalLoss, hitCount, zone)
			if self.m_DamageLogCache[playerId]  then 
				self.m_DamageLogCache[playerId] = nil 
			end
		end	
	end
end

function Guns:Event_onGunLogCacheTick() 
	local now = getTickCount() 
	local cacheObj, cacheTime
	for id, cacheObj in pairs(self.m_DamageLogCache) do 
		if now >= cacheObj["CacheTime"] + GUN_CACHE_EMPTY_INTERVAL then 
			self:forceDamageLogCache(  id ) 
		end
	end
end

function giveWeapon( player, weapon, ammo, current)
	local slot = getSlotFromWeapon(weapon)
	local object = getElementData(player, "a:weapon:slot"..slot.."")
	if object then
		if isElement(object) and player and ammo then
			local wId = getElementData(object, "a:weapon:id")	
				if wId ~= weapon then
					triggerEvent("WeaponAttach:onWeaponGive", player, weapon, slot, current, object)
				end
		end
	else
		if player and ammo then
				local currentWeapon = getPedWeapon(player,slot)
				if currentWeapon ~= weapon then
					triggerEvent("WeaponAttach:onWeaponGive", player, weapon, slot, current, object)
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
			local totalAmmo = getPedTotalAmmo (player, slot)
			if not ammo then
				if (wId == weapon ) then
					triggerEvent("WeaponAttach:onWeaponTake", player, weapon, slot)
				end
			else
				if ammo and totalAmmo then
					if ( wId == weapon and (ammo >= totalAmmo)) then
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
