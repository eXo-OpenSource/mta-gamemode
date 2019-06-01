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
			if item ~= self or not position then return end

			local worldItem = PlayerWorldItem:new(self, player, position, rotation, false, player)
			StatisticsLogger:getSingleton():itemPlaceLogs( player, "Radio", position.x..","..position.y..","..position.z) 
			player:getInventoryOld():removeItem(self:getName(), 1)
			addEventHandler("itemRadioChangeURL", worldItem:getObject(),
				function(url)
					if worldItem:hasPlayerPermissionTo(client, WorldItem.Action.Move) then
						triggerClientEvent("itemRadioChangeURLClient", worldItem:getObject(), url)
					end
				end
			)
			addEventHandler("itemRadioStopSound", worldItem:getObject(),
				function(url)
					if worldItem:hasPlayerPermissionTo(client, WorldItem.Action.Move) then
						triggerClientEvent("itemRadioRemove", worldItem:getObject())
					end
				end
			)
		end
	)
end

function ItemRadio:removeFromWorld(player, worldItem)
	triggerClientEvent("itemRadioRemove", worldItem:getObject())
end
