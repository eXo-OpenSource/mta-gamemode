-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(Item)

function ItemBarricade:constructor()
end

function ItemBarricade:destructor()

end

function ItemBarricade:use(player)
	if player:isFactionDuty() then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self then return end
				if (position - player:getPosition()).length > 20 then
					player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
					return
				end

				local worldItem = self:place(player, position, rotation)
				player:getInventory():removeItem(self:getName(), 1)
			end
		)
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end

function ItemBarricade:onClick(player, worldItem)

end
