-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(Item)
addRemoteEvents{"itemRadioChangeURL", "itemRadioStopSound"}

function ItemRadio:constructor()

end

function ItemRadio:destructor()

end

function ItemRadio:use(player)
	local result = self:startObjectPlacing(player,
		function(item, position, rotation)
			if item ~= self then return end
			if (position - player:getPosition()).length > 20 then
				player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
				return
			end

			local worldItem = self:place(player, position, rotation)
			player:getInventory():removeItem(self:getName(), 1)
			addEventHandler("itemRadioChangeURL", worldItem:getObject(),
				function(url)
					triggerClientEvent("itemRadioChangeURLClient", worldItem:getObject(), url)
				end
			)
			addEventHandler("itemRadioStopSound", worldItem:getObject(),
				function(url)
					triggerClientEvent("itemRadioRemove", worldItem:getObject())
				end
			)
		end
	)
end

function ItemRadio:isCollectAllowed(player, worlditem)
	if worlditem:getOwner() == player or player:getRank() > RANK.Supporter then
		return true
	end
	return false
end

function ItemRadio:onClick(player, worldItem)
	if worldItem:getOwner() == player or player:getRank() > RANK.Supporter then
		-- TODO: It might be better to do this clientside to avoid the relay
		-- TODO: Also it might be better to generalise this API a bit (there are probably lots of items which use item mouse menus)
		triggerClientEvent(player, "itemRadioMenu", worldItem:getObject())
	else
		player:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", player))
	end
end

function ItemRadio:removeFromWorld(player, worldItem)
	triggerClientEvent("itemRadioRemove", worldItem:getObject())
end
