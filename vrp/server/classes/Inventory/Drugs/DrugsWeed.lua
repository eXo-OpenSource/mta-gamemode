-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsWeed.lua
-- *  PURPOSE:     Weed class
-- *
-- ****************************************************************************
DrugsWeed = inherit(ItemDrugs)

function DrugsWeed:constructor()
end

function DrugsWeed:destructor()

end

function DrugsWeed:use( player )
  	player:triggerEvent("onClientItemUse", "Weed" )
end
