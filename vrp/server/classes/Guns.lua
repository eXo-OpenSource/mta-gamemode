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

<<<<<<< HEAD
	addRemoteEvents{"onTaser", "onClientDamage", "onClientWasted"}
=======
	addRemoteEvents{"onTaser", "onClientDamage", "onClientKill", "onClientWasted"}
>>>>>>> d5ee044077b6c9c11c559132aff165d1341d4acf
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
	addEventHandler("onClientDamage", root, bind(self.Event_onClientDamage, self))
end

function Guns:destructor()

end

function Guns:Event_onTaser(target)
	target:setAnimation("crack", "crckdeth2",-1,true,true,false)
	toggleAllControls(target,false)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	target.isTasered = true
	setTimer ( function(target)
		target:setAnimation()
		target:setFrozen(false)
		toggleAllControls(target,true)
		target.isTasered = false
	end, 15000, 1, target )
end

function Guns:Event_onClientDamage(target, weapon, bodypart, loss)
	local attacker = client
	if weapon == 34 and bodypart == 9 then
		if not target.m_SupMode and not attacker.m_SupMode then
			target:setHeadless(true)
			StatisticsLogger:getSingleton():addKillLog(attacker, target, weapon)
			target:kill(attacker, weapon, bodypart)
		end
	else
		if not target.m_SupMode and not attacker.m_SupMode then
			local basicDamage = WEAPON_DAMAGE[weapon]
			local multiplier = DAMAGE_MULTIPLIER[bodypart] and DAMAGE_MULTIPLIER[bodypart] or 1
			local realLoss = basicDamage*multiplier
			self:damagePlayer(target, realLoss, attacker, weapon, bodypart)
		end
	end
end

<<<<<<< HEAD
=======
function Guns:Event_onClientKill(kill, weapon, bodypart, loss)

end

>>>>>>> d5ee044077b6c9c11c559132aff165d1341d4acf
function Guns:damagePlayer(player, loss, attacker, weapon, bodypart)
	local armor = getPedArmor ( player )
	local health = getElementHealth ( player )
	if armor > 0 then
		if armor >= loss then
			player:setArmor(armor-loss)
		else
			loss = math.abs(armor-loss)
			player:setArmor(0)
			player:setHealth(health-loss)

			if player:getHealth()-loss <= 0 then
				StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
				player:kill(attacker, weapon, bodypart)
			end
		end
	else
		if player:getHealth()-loss <= 0 then
			StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
			player:kill(attacker, weapon, bodypart)
		end
		player:setHealth(health-loss)
	end
	StatisticsLogger:getSingleton():addTextLog("damage", ("%s wurde von %s mit Waffe %s am %s getroffen! (Damage: %d)"):format(player:getName(), attacker:getName(), WEAPON_NAMES[weapon], BODYPART_NAMES[bodypart], loss))
end
