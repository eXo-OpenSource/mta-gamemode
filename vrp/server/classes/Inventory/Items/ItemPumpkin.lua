-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemPumpkin.lua
-- *  PURPOSE:     Pumpkin class
-- *
-- ****************************************************************************
ItemPumpkin = inherit(Item)

function ItemPumpkin:constructor()

    self.m_Model = 1935
	self.m_Pumpkins = {}
	WearableHelmet.objectTable["Kürbis"] = {1935, 0.05, 0, 0.8, 0, 180, "Kürbis", true}
	--model, zOffset, yOffset, scale, rotX, rotZ
end

function ItemPumpkin:destructor()

end

function ItemPumpkin:use(...)
	ItemManager:getSingleton():getInstance("Helm"):use(...)
end

function ItemPumpkin:addObject(Id, pos, rot, interior, dimension)
    self.m_Pumpkins[Id] = createObject(self.m_Model, pos, rot)
    self.m_Pumpkins[Id]:setInterior(interior)
    self.m_Pumpkins[Id]:setDimension(dimension)
	self.m_Pumpkins[Id].Id = Id
	self.m_Pumpkins[Id].Type = "Pumpkin"
    self.m_Pumpkins[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Pumpkins[Id], bind(self.onPumpkinClick, self))
	return self.m_Pumpkins[Id]
end

function ItemPumpkin:onPumpkinClick(button, state, player)
    if source.Type ~= "Pumpkin" then return end
	if button == "left" and state == "down" then
        if source:getModel() == self.m_Model then
            if player:getInventory():getFreePlacesForItem("Kürbis") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Kürbis", 1)
                player:sendInfo(_("Du hast einen Kürbis gesammelt!", player))

				player:giveAchievement(88) -- Finde dein erstes Kürbis

				if player:getInventory():getItemAmount("Kürbis") >= 50 then
					player:giveAchievement(89) -- Kürbissammler
				end
            else
                player:sendError(_("Du kannst nicht soviele Kürbisse tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Kürbis")))
            end
        end
    end
end
