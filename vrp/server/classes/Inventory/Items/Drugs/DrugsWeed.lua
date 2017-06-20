-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsWeed.lua
-- *  PURPOSE:     Weed class
-- *
-- ****************************************************************************
DrugsWeed = inherit(ItemDrugs)
DrugsWeed.m_HealInterval = 5000
DrugsWeed.m_HealValue = 5
function DrugsWeed:constructor()
end

function DrugsWeed:destructor()

end

function DrugsWeed:use( player )
	ItemDrugs.use(self, player)

  	player:triggerEvent("onClientItemUse", "Weed", WEED_EXPIRETIME )
    if isTimer( player.m_WeedExpireTimer ) then
      killTimer( player.m_WeedExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_WeedExpireFunc = bind( DrugsWeed.expire, self )
    player.m_WeedHealFunc = bind( DrugsWeed.effect, self)
    local healSteps = math.floor( WEED_EXPIRETIME / DrugsWeed.m_HealInterval )
    player.m_WeedExpireTimer = setTimer( player.m_WeedExpireFunc, WEED_EXPIRETIME, 1, player )
    player.m_WeedHealTimer = setTimer( player.m_WeedHealFunc, DrugsWeed.m_HealInterval , healSteps , player )
	StatisticsLogger:getSingleton():addDrugUse( player, "Weed" )
end

function DrugsWeed:expire( player )
  if not isElement(player) or getElementType(player) ~= "player" then return false end
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Weed" )
end

function DrugsWeed:effect( player )
  if not isElement(player) or getElementType(player) ~= "player" then return false end
  local health = getElementHealth( player )
  if health < 100 then
    setElementHealth( player, health + DrugsWeed.m_HealValue )
  end
end
