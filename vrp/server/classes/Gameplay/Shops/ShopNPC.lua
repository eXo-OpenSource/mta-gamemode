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

	addEventHandler("onPlayerTarget", root,
		function(targettedElement)
			if isElement(self) then
				if targettedElement == self and not self.m_InTarget and source:getWeapon() ~= 0 then
					self:setAnimation("ped", "handsup", -1, false)
					self.m_InTarget = true

					if self.onTargetted then
						self:onTargetted(source)
					end

					-- Block inTarget for a while | TODO: Optimize this
					setTimer(function() self.m_InTarget = false self:setAnimation(nil) end, 30*1000, 1)
				end
			end
		end
	)

	self:toggleWanteds(true)
end
