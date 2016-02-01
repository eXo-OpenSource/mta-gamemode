-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	addEventHandler("onClientPlayerDamage", root, bind(self.Event_onClientPlayerDamage, self))
end

function Guns:destructor()

end

function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	if attacker:getPublicSync("Faction:Duty") and weapon == 23 then -- Taser
		if getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition()) < 10 then
			if attacker == localPlayer then
				triggerServerEvent("onTaser",attacker,source)
			end
		end
		cancelEvent()
	end
end
