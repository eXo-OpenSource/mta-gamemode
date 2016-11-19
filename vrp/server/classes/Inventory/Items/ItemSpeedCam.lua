-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSpeedCam.lua
-- *  PURPOSE:     Speed Cam item class
-- *
-- ****************************************************************************
ItemSpeedCam = inherit(Item)
addRemoteEvents{"ItemSpeedCamRemove"}

function ItemSpeedCam:constructor()

end

function ItemSpeedCam:destructor()

end

function ItemSpeedCam:use(player)
	local result = self:startObjectPlacing(player,
		function(item, position, rotation)
			if item ~= self then return end
			if (position - player:getPosition()).length > 20 then
				player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
				return
			end

			local worldItem = self:place(player, position, rotation)
			player:getInventory():removeItem(self:getName(), 1)

			addEventHandler("ItemSpeedCamRemove", worldItem:getObject(),
				function()
					source:destroy()
				end
			)
		end
	)
end

function ItemSpeedCam:onClick(player, worldItem)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		triggerClientEvent(player, "ItemSpeedCamMenu", worldItem:getObject())
	else
		player:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", player))
	end
end

function ItemSpeedCam:removeFromWorld()
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		WorldItem.Map[source] = false
		source:destroy()
		player:sendError(_("Du hast den Blitzer abgebaut!", player))
	end
end
