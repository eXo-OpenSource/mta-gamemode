-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/ElementInfo.lua
-- *  PURPOSE:     ElementInfo manager
-- *
-- ****************************************************************************
ElementInfo = inherit(Object)
ElementInfo.Map = {}

function ElementInfo:constructor(object, text, offset)
	ElementInfo.Map[object] = self
    self.m_Text = text
    self.m_Object = object
    self.m_Offset = offset
	for k, player in pairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:triggerEvent("elementInfoCreate", object, text, offset)
		end
	end
end

function ElementInfo:destructor()
	ElementInfo.Map[self.m_Id] = nil
	triggerClientEvent("elementInfoDestroy", resourceRoot, self.m_Id)
end

function ElementInfo.sendAllToClient(player)
	local data = {}
	for object, class in pairs(ElementInfo.Map) do
		data[object] = {class.m_Text, class.m_Offset}
	end
	player:triggerEvent("elementInfoRetrieve", data)
end
