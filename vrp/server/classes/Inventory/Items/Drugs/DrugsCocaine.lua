-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsCocaine.lua
-- *  PURPOSE:     Cocaine class
-- *
-- ****************************************************************************
DrugsCocaine = inherit(ItemDrugs)
DrugsCocaine.m_ExpireTime = 60 * 1000

function DrugsCocaine:constructor()
end

function DrugsCocaine:destructor()

end

function DrugsCocaine:use( player )
	ItemDrugs.use(self, player)

  	player:triggerEvent("onClientItemUse", "Kokain", DrugsCocaine.m_ExpireTime )
    if isTimer( player.m_CocaineExpireTimer ) then
      killTimer( player.m_CocaineExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_CocaineExpireFunc = bind( DrugsCocaine.expire, self )
    player.m_CocaineExpireTimer = setTimer( player.m_CocaineExpireFunc, DrugsCocaine.m_ExpireTime, 1, player )
	StatisticsLogger:getSingleton():addDrugUse( player, "Kokain" )
end




function DrugsCocaine:expire( player )
  if player then
    player.m_DrugOverDose = 0
    player:triggerEvent("onClientItemExpire", "Kokain" )
  end
end
