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


function ItemNails:constructor()
	self.m_RemoveBind = bind(self.removeNail, self)
end

function ItemNails:destructor()

end

function ItemNails:use(player)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		if self:count() < MAX_NAILS then
			local result = self:startObjectPlacing(player,
				function(item, position, rotation)
					if item ~= self then return end
					if (position - player:getPosition()).length > 20 then
						player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
						return
					end

				
					local worldItem = FactionWorldItem:new(self, player:getFaction(), position, rotation, false, player)
					worldItem:setFactionSuperOwner(true)
					player:getInventory():removeItem(self:getName(), 1)

					local object = worldItem:getObject()
					setElementData(object, "earning", 0)
					ItemNails.Map[#ItemNails.Map+1] = object

					object.col = createColSphere(position, 4)
					object.col.object = object
					object.col.worldItem = worldItem
					self.m_func = bind(self.onColShapeHit, self)

					addEventHandler("onColShapeHit", object.col, self.m_func )
					addEventHandler("onColShapeLeave", object.col, bind(self.onColShapeLeave, self) )
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
		player:getInventory():removeItem(self:getName(), 1)
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
    elseif element:getType() == "player" and not element.vehicle then
		if element:getFaction() and element:getFaction():isStateFaction() and element:isFactionDuty() then
			element:sendInfo("Drücke Backspace (<--) um das Nagelband zu entfernen!")
			bindKey(element, "backspace", "down", self.m_RemoveBind, source)
		end
	end
  end
end

function ItemNails:onColShapeLeave(element, dim)
  if dim then
    if element:getType() == "player" then
		if isKeyBound(element, "backspace", "down", self.m_RemoveBind) then
			unbindKey(element, "backspace", "down", self.m_RemoveBind)
		end
	end
  end
end

function ItemNails:removeNail(player, key, state, shape)
	if isElementWithinColShape(player, shape) then
		if shape.worldItem then
			shape.worldItem:onCollect(player)
		end
	else
		unbindKey(player, "backspace", "down", self.m_RemoveBind)
	end
end

function ItemNails:removeFromWorld(player, worlditem)
	local object = worlditem:getObject()
	local col = object.col
	col:destroy()
	for index, cam in pairs(ItemNails.Map) do
		if cam == object then
			table.remove(ItemNails.Map, index)
		end
	end
	unbindKey(player, "backspace", "down", self.m_RemoveBind)
end
