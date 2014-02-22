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
	
	addEventHandler("onPlayerTarget", root,
		function(targettedElement)
			if targettedElement == self then
				setPedAnimation(self, "ped", "handsup", -1, false)
			end
		end
	)
end
