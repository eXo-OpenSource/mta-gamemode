-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsHeroin.lua
-- *  PURPOSE:     Heroin class
-- *
-- ****************************************************************************
DrugsHeroin = inherit(ItemDrugs)
DrugsHeroin.m_ExpireTime = 50 * 1000

function DrugsHeroin:constructor()
end

function DrugsHeroin:destructor()

end

function DrugsHeroin:use( player )
	ItemDrugs.use(self, player)

  	player:triggerEvent("onClientItemUse", "Heroin", DrugsHeroin.m_ExpireTime )
    if isTimer( player.m_HeroinExpireTimer ) then
      killTimer( player.m_HeroinExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_HeroinExpireFunc = bind( DrugsHeroin.expire, self )
    player.m_HeroinExpireTimer = setTimer( player.m_HeroinExpireFunc, DrugsHeroin.m_ExpireTime, 1, player )
	StatisticsLogger:getSingleton():addDrugUse( player, "Heroin" )
end

function DrugsHeroin:expire( player )
  if not isElement(player) or getElementType(player) ~= "player" then return false end
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Heroin" )
end
