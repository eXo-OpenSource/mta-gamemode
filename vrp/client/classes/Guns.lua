-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/Guns.lua
-- *  PURPOSE:     Client Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	addEventHandler("onClientPlayerDamage", localPlayer, bind(self.Event_onClientPlayerDamage, self))
end

function Guns:destructor()

end

function Guns:Event_onClientPlayerDamage(attacker, weapon, bodypart, loss)
	if attacker == localPlayer then
		if attacker:getPublicSync("Faction:Duty") and weapon == 23 then -- Taser
			cancelEvent()
			if getDistanceBetweenPoints3D(attacker:getPosition(),source:getPosition()) < 5 then

				triggerServerEvent("onTaser",attacker,source)
			end
		end
	end
end
