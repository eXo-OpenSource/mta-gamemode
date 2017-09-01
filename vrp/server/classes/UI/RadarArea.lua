-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/RadarArea.lua
-- *  PURPOSE:     RadarArea manager
-- *
-- ****************************************************************************
RadarArea = inherit(Object)
RadarArea.Map = {}

function RadarArea:constructor(x, y, width, height, color)
	self.m_PosX, self.m_PosY = x, y
	self.m_Width, self.m_Height = width, height
	self.m_Color = color
	self.m_Id = #RadarArea.Map + 1
	RadarArea.Map[self.m_Id] = self

	for k, player in pairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:triggerEvent("radarAreaCreate", self.m_Id, self.m_PosX, self.m_PosY, self.m_Width, self.m_Height, self.m_Color)
		end
	end
end

function RadarArea:destructor()
	outputDebug("deleted radar area")
	RadarArea.Map[self.m_Id] = nil
	triggerClientEvent("radarAreaDestroy", resourceRoot, self.m_Id)
end

function RadarArea:setFlashing(state)
	triggerClientEvent("radarAreaFlash", resourceRoot, self.m_Id, state)
end

function RadarArea.sendAllToClient(player)
	local data = {}
	for id, v in pairs(RadarArea.Map) do
		data[#data + 1] = {id, v.m_PosX, v.m_PosY, v.m_Width, v.m_Height, v.m_Color}
	end
	player:triggerEvent("radarAreasRetrieve", data)
end
