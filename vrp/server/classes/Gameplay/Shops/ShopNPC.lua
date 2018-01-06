-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     Shop NPC class (peds in shops)
-- *
-- ****************************************************************************
ShopNPC = inherit(NPC)

function ShopNPC:constructor(skinId, x, y, z, rotation)
	NPC.constructor(self, skinId, x, y, z, rotation)
	self:setFrozen(true)
	self.m_InTarget = false

	self:toggleWanteds(true)
end

addEventHandler("onPlayerTarget", root,
function(targettedElement)
	if isElement(targettedElement) and getElementType(targettedElement) == "ped" and instanceof(targettedElement, ShopNPC) then
		if not targettedElement.m_InTarget and source:getWeapon() ~= 0 then
			targettedElement:setAnimation("ped", "handsup", -1, false)
			targettedElement.m_InTarget = true

			if targettedElement.onTargetted then
				source:sendWarning(_("Du überfällst den NPC in 5 Sekunden, wenn du weiter auf ihn zielst!", source))
				local targetTimer = setTimer(function(player)
					if player:getTarget() == targettedElement then
						targettedElement:onTargetted(player)
					end
				end, 5000, 1, source)
			end


			-- Block inTarget for a while | TODO: Optimize this
			setTimer(function(player)
				if not isElement(player) or getElementType(player) ~= "player" or player:getTarget() == false then
					targettedElement.m_InTarget = false
					targettedElement:setAnimation(nil)
					killTimer(sourceTimer)
					if targetTimer and isTimer(targetTimer) then
						killTimer(targetTimer)
					end
				end
			end, 3*1000, 0, source)

		end
	end
end
)
