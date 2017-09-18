-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsShroom.lua
-- *  PURPOSE:     Shroom class
-- *
-- ****************************************************************************
DrugsShroom = inherit(ItemDrugs)

function DrugsShroom:constructor()
    self.m_Path = ":vrp_data/mushrooms.dat"
    self.m_Mushrooms = {}
	self.m_MagicModel = 1947
    self.m_NormalModel = 1882
    self.m_Models = {self.m_MagicModel, self.m_NormalModel}
end

function DrugsShroom:destructor()

end

function DrugsShroom:use( player )
	ItemDrugs.use(self, player)

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
	StatisticsLogger:getSingleton():addDrugUse( player, "Shrooms" )
end

function DrugsShroom:expire( player )
  if not isElement(player) or getElementType(player) ~= "player" then return false end
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Shrooms" )
end

function DrugsShroom:addObject(Id, pos)
	local model = self.m_Models[math.random(1, #self.m_Models)]
	self.m_Mushrooms[Id] = createObject(model, pos)
	self.m_Mushrooms[Id].Id = Id
	self.m_Mushrooms[Id].Type = "Mushroom"
    self.m_Mushrooms[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Mushrooms[Id], bind(self.onMushroomClick, self))
	return self.m_Mushrooms[Id]
end

function DrugsShroom:onMushroomClick(button, state, player)
	if source.Type ~= "Mushroom" then return end

	if button == "left" and state == "down" then
        if source:getModel() == self.m_MagicModel then
            if player:getInventory():getFreePlacesForItem("Shrooms") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Shrooms", 1)
                player:sendInfo(_("Du hast einen seltenen Magic-Mushroom gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Shrooms tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Shrooms")))
            end
        elseif source:getModel() == self.m_NormalModel then
            if player:getInventory():getFreePlacesForItem("Pilz") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Pilz", 1)
                player:sendInfo(_("Du hast einen Pilz gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Pilze tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Pilz")))
            end
        end
    end
end
