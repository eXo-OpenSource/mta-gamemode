-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Guns/Guns.lua
-- *  PURPOSE:     Server Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	addRemoteEvents{"onTaser"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
end

function Guns:destructor()

end

function Guns:Event_onTaser(target)
	target:setAnimation("crack", "crckdeth2",-1,true,true,false)
	target:setFrozen(true)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	setTimer ( function(target)
		target:setAnimation()
		target:setFrozen(false)
	end, 5000, 1, target )
end
