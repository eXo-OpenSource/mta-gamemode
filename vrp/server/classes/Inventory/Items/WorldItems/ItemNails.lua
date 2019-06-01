-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemNails.lua
-- *  PURPOSE:     Nails item class
-- *
-- ****************************************************************************
ItemNails = inherit(Item)
ItemNails.Map = {}

local MAX_NAILS = 8

function ItemNails:use(player)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		if self:count() < MAX_NAILS then
			local result = self:startObjectPlacing(player,
				function(item, position, rotation)
					if item ~= self or not position then return end
					if (position - player:getPosition()).length > 20 then
						player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
						return
					end

					local worldItem = FactionWorldItem:new(self, player:getFaction(), position, rotation, false, player)
					worldItem:setFactionSuperOwner(true)
					player:getInventoryOld():removeItem(self:getName(), 1)

					local object = worldItem:getObject()
					ItemNails.Map[#ItemNails.Map+1] = object
					
					object.nails 	= worldItem:attach(createObject(984, position), false, Vector3(0, 90, 0))
					object.nails:setAlpha(0)

					object.col 		= worldItem:attach(createColSphere(position, 4))
					self.m_func 	= bind(self.onColShapeHit, self)

					addEventHandler("onColShapeHit", object.col, self.m_func)
					local pos = player:getPosition()
					FactionState:getSingleton():sendShortMessage(_("%s hat ein Nagelband bei %s/%s hingelegt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
					StatisticsLogger:getSingleton():itemPlaceLogs( player, "Nagelband", pos.x..","..pos.y..","..pos.z)
				end
			)
		else
			player:sendError(_("Es sind bereits %d/%d Nagelbänder ausgelegt!", player, self:count(), MAX_NAILS))
		end
	else
		player:sendError(_("Du bist nicht berechtigt! Das Item wurde abgenommen!", player))
		player:getInventoryOld():removeAllItem(self:getName())
	end
end

function ItemNails:count()
	local count = 0
	for index, cam in pairs(ItemNails.Map) do
		count = count + 1
	end
	return count
end

function ItemNails:onColShapeHit(element, dim)
	if dim then
		if element:getType() == "vehicle" then
			element:setWheelStates(1, 1, 1, 1)
		end
	end
end

function ItemNails:removeFromWorld(player, worlditem)
	local object = worlditem:getObject()
	for index, nails in pairs(ItemNails.Map) do
		if nails == object then
			table.remove(ItemNails.Map, index)
		end
	end
end
