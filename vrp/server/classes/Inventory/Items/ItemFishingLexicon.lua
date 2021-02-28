-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFishingLexicon.lua
-- *  PURPOSE:     Fishing lexicon item class
-- *
-- ****************************************************************************
ItemFishingLexicon = inherit(ItemNew)

function ItemFishingLexicon:use()
	local player = self.m_Inventory:getPlayer()

	local playerSpeciesCaught = player:getFishSpeciesCaught()
	player:triggerEvent("receiveCaughtFishSpecies", Fishing.Fish, playerSpeciesCaught)
	
	return true, false, false
end
