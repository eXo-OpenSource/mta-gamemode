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
	
	self.m_InTarget = false
	self.m_SpawnMoneyFunc = bind(self.spawnMoney, self)
	
	addEventHandler("onPlayerTarget", root,
		function(targettedElement)
			if targettedElement == self and not self.m_InTarget and getPedWeapon(source) ~= 0 then
				setPedAnimation(self, "ped", "handsup", -1, false)
				self.m_InTarget = true
				
				setTimer(self.m_SpawnMoneyFunc, 1000, math.random(1, 5), source)
				setTimer(function() self.m_InTarget = false end, 10*60*1000, 1) -- Todo: Optimize this
			end
		end
	)
end

function ShopNPC:spawnMoney(threatingPlayer)
	-- Todo: Replace by a money pickup
	--> Give money immediately for now
	threatingPlayer:giveMoney(math.random(10, 50))
	
	threatingPlayer:giveKarma(-0.07)
end
