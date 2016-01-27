-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(PlaceableItem)

function ItemBarricade:constructor()

end

function ItemBarricade:destructor()

end

function ItemBarricade:use(inventory, player, slot)
	local result = self:startObjectPlacing(player,
		function(item, position, rotation)
			if item ~= self then return end
			if (position - player:getPosition()).length > 20 then
				player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
				return
			end

			local worldItem = inventory:placeItem(self, slot, player, position, rotation)
		end
	)
end

function ItemBarricade:onClick(player, worldItem)

end
