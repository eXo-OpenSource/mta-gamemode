-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsShroom.lua
-- *  PURPOSE:     Shroom class
-- *
-- ****************************************************************************
DrugsShroom = inherit(ItemDrugs)

function DrugsShroom:constructor()
end

function DrugsShroom:destructor()

end

function DrugsShroom:use( player )
  	player:triggerEvent("onClientItemUse", "Shrooms", SHROOM_EXPIRETIME )
    if isTimer( player.m_ShroomExpireTimer ) then
      killTimer( player.m_ShroomExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_ShroomExpireFunc = bind( DrugsShroom.expire, self )
    player.m_ShroomExpireTimer = setTimer( player.m_ShroomExpireFunc, SHROOM_EXPIRETIME, 1, player )
end

function DrugsShroom:expire( player )
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Shrooms" )
end
