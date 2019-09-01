-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/DoorWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
DoorWorldItem = inherit(PlayerWorldItem)
DoorWorldItem.Map = {}

function DoorWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local faction = player:getFaction()
	local int = player:getInterior()
	local dim = player:getDimension()
	-- (item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
	-- FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
	-- (itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
	BarricadeWorldItem:new(placingInfo.itemData, player:getId(), player:getId(), DbElementType.Player, position, rotation, dim, int, false, "", {}, true, false)
end

function DoorWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    DoorWorldItem.Map[self.m_Id] = self

	local object = self:getObject()

	addEventHandler("onClientBreakItem", object, function()
		source.m_Super:onDelete()
	end)

	if object.model == 1238 then --Cone

		self.m_BindKeyClick = bind(self.Event_toggleBlinkingLight, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		addEventHandler("worldItemToggleBlinkingLight", object, function()
			self:toggleBlinkingLight(source, client)
		end)
	end
end

function BarricadeWorldItem:destructor()
	if self:getObject().m_LightTimer then
		self:toggleBlinkingLight(self:getObject())
	end
end

function BarricadeWorldItem:Event_toggleBlinkingLight()
	local object = self:getObject()

	if not (object.m_LightTimer and isTimer(object.m_LightTimer)) then
		object.m_Marker = createMarker(object.position, "corona", 0.3, 200, 100, 0, 255)
		object.m_Marker:attach(object, 0, 0, 0.5)
		object.m_LightTimer = setTimer(function()
			if object.m_MarkerVisible then
				object.m_Marker:setColor(200, 100, 0, 0)
			else
				object.m_Marker:setColor(200, 100, 0, 255)
			end
			object.m_MarkerVisible = not object.m_MarkerVisible
		end, 500, 0)
		if client then client:sendShortMessage(_("Licht angeschaltet", client), nil, nil, 1000) end
	else
		if (object.m_LightTimer and isTimer(object.m_LightTimer)) then killTimer(object.m_LightTimer) end
		if isElement(object.m_Marker) then object.m_Marker:destroy() end
		object.m_LightTimer = nil
		object.m_MarkerVisible = nil
		object.m_Marker = nil
		if client then client:sendShortMessage(_("Licht ausgeschaltet", client), nil, nil, 1000) end
	end
end
