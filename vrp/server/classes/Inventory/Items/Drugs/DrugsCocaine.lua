-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsCocaine.lua
-- *  PURPOSE:     Cocaine class
-- *
-- ****************************************************************************
DrugsCocaine = inherit(ItemDrugs)

function DrugsCocaine:constructor()
end

function DrugsCocaine:destructor()

end

function DrugsCocaine:use( player )
  	player:triggerEvent("onClientItemUse", "Kokain", COCAINE_EXPIRETIME )
    if isTimer( player.m_CocaineExpireTimer ) then
      killTimer( player.m_CocaineExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_CocaineExpireFunc = bind( DrugsCocaine.expire, self )
    player.m_CocaineExpireTimer = setTimer( player.m_CocaineExpireFunc, COCAINE_EXPIRETIME, 1, player )
	StatisticsLogger:getSingleton():addDrugUse( player, "Kokain" )
end




function DrugsCocaine:expire( player )
  if player then
    player.m_DrugOverDose = 0
    player:triggerEvent("onClientItemExpire", "Kokain" )
  end
end
