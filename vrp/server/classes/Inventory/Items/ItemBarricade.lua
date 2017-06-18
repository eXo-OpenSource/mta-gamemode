-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(Item)
addRemoteEvents{"worldItemToggleConeLight"}


function ItemBarricade:constructor( )

end

function ItemBarricade:destructor()

end

function ItemBarricade:use(player)
	if player:isFactionDuty() then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self or not position then return end
				local item = item
				self.m_WorldItem = FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
				self.m_WorldItem:setFactionSuperOwner(true)
				addEventHandler("onClientBreakItem", self.m_WorldItem.m_Object, function()
					source.m_Super:onDelete()
				end)
				if self:getModelId() == 1238 then
					addEventHandler("worldItemToggleConeLight", self.m_WorldItem.m_Object, function()
						self:toggleConeLight(source, client)
					end)
				end

				player:getInventory():removeItem(self:getName(), 1)
			end
		)
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end

function ItemBarricade:toggleConeLight(object, player)
	if not (object.m_LightTimer and isTimer(object.m_LightTimer)) then
		object.m_LightTimer = setTimer(function()
			if object.m_MarkerVisible then
				object.m_Marker:destroy()
			else
				object.m_Marker = createMarker(object.position, "corona", 0.3, 200, 100, 0, 255)
				object.m_Marker:attach(object, 0, 0, 0.5)
			end
			object.m_MarkerVisible = not object.m_MarkerVisible
		end, 500, 0)
		if player then player:sendShortMessage(_("Licht angeschaltet", player), nil, nil, 1000) end
	else
		if (object.m_LightTimer and isTimer(object.m_LightTimer)) then killTimer(object.m_LightTimer) end
		if isElement(object.m_Marker) then object.m_Marker:destroy() end
		object.m_LightTimer = nil
		object.m_MarkerVisible = nil
		object.m_Marker = nil
		if player then player:sendShortMessage(_("Licht ausgeschaltet", player), nil, nil, 1000) end
	end
end


function ItemBarricade:removeFromWorld(player, worlditem, object)
	if object.m_LightTimer then
		self:toggleConeLight(object, player)
	end
end