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
  	player:triggerEvent("onClientItemUse", "Weed", WEED_EXPIRETIME )
    if isTimer( player.m_WeedExpire ) then
      killTimer( player.m_WeedExpire )
      player.m_DrugOverdose = player.m_DrugOverdose + 1
    end
    player.m_WeedExpire = bind( DrugsWeed.expire, self )
    setTimer( player.m_WeedExpire, WEED_EXPIRETIME, 1, player )
end

function DrugsWeed:expire( player )
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Weed" )
end
