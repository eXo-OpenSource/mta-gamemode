-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemEasteregg.lua
-- *  PURPOSE:     Eastereggs class
-- *
-- ****************************************************************************
ItemEasteregg = inherit(Item)

function ItemEasteregg:constructor()
    self.m_Model = 1933
	self.m_Eastereggs = {}
end

function ItemEasteregg:destructor()

end

function ItemEasteregg:use( player )

end

function ItemEasteregg:addObject(Id, pos, rot, interior, dimension)
    self.m_Eastereggs[Id] = createObject(self.m_Model, pos, rot)
    self.m_Eastereggs[Id]:setInterior(interior)
    self.m_Eastereggs[Id]:setDimension(dimension)
	self.m_Eastereggs[Id].Id = Id
	self.m_Eastereggs[Id].Type = "Easteregg"
    self.m_Eastereggs[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Eastereggs[Id], bind(self.onEastereggClick, self))
	return self.m_Eastereggs[Id]
end

function ItemEasteregg:onEastereggClick(button, state, player)
    if source.Type ~= "Easteregg" then return end
	if button == "left" and state == "down" then
        if source:getModel() == self.m_Model then
            if player:getInventory():getFreePlacesForItem("Osterei") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Osterei", 1)
                player:sendInfo(_("Du hast ein Osterei gesammelt!", player))

				player:giveAchievement(88) -- Finde dein erstes Osterei

				if player:getInventory():getItemAmount("Osterei") >= 50 then
					player:giveAchievement(89) -- Ostereisammler
				end
            else
                player:sendError(_("Du kannst nicht soviele Ostereier tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Osterei")))
            end
        end
    end
end
