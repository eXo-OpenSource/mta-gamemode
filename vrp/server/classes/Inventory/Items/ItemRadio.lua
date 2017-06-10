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

			local worldItem = PlayerWorldItem:new(self, player, position, rotation, false, player)
			StatisticsLogger:getSingleton():itemPlaceLogs( player, "Radio", position.x..","..position.y..","..position.z) 
			player:getInventory():removeItem(self:getName(), 1)
			addEventHandler("itemRadioChangeURL", worldItem:getObject(),
				function(url)
					if worldItem:getOwner() == player:getId() or player:getRank() > RANK.Supporter then
						triggerClientEvent("itemRadioChangeURLClient", worldItem:getObject(), url)
					else
						client:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", client))
					end
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

function ItemRadio:removeFromWorld(player, worldItem)
	triggerClientEvent("itemRadioRemove", worldItem:getObject())
end
