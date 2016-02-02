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

	addRemoteEvents{"onTaser"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
end

function Guns:destructor()

end

function Guns:Event_onTaser(target)
	target:setAnimation("crack", "crckdeth2",-1,true,true,false)
	target:setFrozen(true)
	toggleAllControls(target,false)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	setTimer ( function(target)
		target:setAnimation()
		target:setFrozen(false)
		toggleAllControls(target,true)
	end, 15000, 1, target )
end
