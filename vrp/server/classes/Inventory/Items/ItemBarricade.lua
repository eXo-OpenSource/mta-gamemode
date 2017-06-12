-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(Item)

function ItemBarricade:constructor( )

end

function ItemBarricade:destructor()

end

function ItemBarricade:use(player)
	if player:isFactionDuty() then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self or not position then return end
				
				self.m_WorldItem = FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
				self.m_WorldItem:setFactionSuperOwner(true)
				addEventHandler("onClientBreakItem", self.m_WorldItem.m_Object, function()
					self.m_WorldItem:onDelete()
				end)

				player:getInventory():removeItem(self:getName(), 1)
			end
		)
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end