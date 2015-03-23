-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(PlaceableItem)
addEvent("itemRadioChangeURL", true)

function ItemRadio:constructor()

end

function ItemRadio:destructor()

end

function ItemRadio:use(inventory, player, slot)
	local result = self:startObjectPlacing(player,
		function(item, position, rotation)
			if item ~= self then return end
			if (position - player:getPosition()).length > 20 then
				player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))

				-- Add item to the inventory again
				inventory:addItemByItem(self)

				return
			end

			local worldItem = inventory:placeItem(self, slot, player, position, rotation)
			addEventHandler("itemRadioChangeURL", worldItem:getObject(),
				function(url)
					setElementData(source, "url", url)
					triggerClientEvent("itemRadioChangeURL", source, url) -- send url twice so that we do not get in trouble with packet ordering
				end
			)
		end
	)

	if not result then
		-- Add item to the inventory again
		inventory:addItemByItem(self)
	end
end

function ItemRadio:onClick(player, worldItem)
	if worldItem:getOwner() == player then
		-- TODO: It might be better to do this clientside to avoid the relay
		-- TODO: Also it might be better to generalise this API a bit (there are probably lots of items which use item mouse menus)
		triggerClientEvent(player, "itemRadioMenu", worldItem:getObject())
	else
		player:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", player))
	end
end
