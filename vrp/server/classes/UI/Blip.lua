-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/Blip.lua
-- *  PURPOSE:     Blip manager
-- *
-- ****************************************************************************
Blip = inherit(Object)
Blip.Map = {}

function Blip:constructor(imagePath, x, y, visibleTo)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	self.m_VisibleTo = visibleTo or root
	self.m_StreamDistance = 800
	self.m_Color = Vector4(255, 255, 255, 255)

	self.m_Id = #Blip.Map + 1
	Blip.Map[self.m_Id] = self

	self:sendToClient()
end

function Blip:sendToClient()

	if self.m_VisibleTo == root then
		for k, player in pairs(getElementsByType("player")) do
			if player:isLoggedIn() then
				player:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY, self.m_StreamDistance)
			end
		end
	else
		self.m_VisibleTo:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY, self.m_StreamDistance)
	end
end

function Blip:destructor()
	Blip.Map[self.m_Id] = nil

	if self.m_VisibleTo == root then
		triggerClientEvent("blipDestroy", root, self.m_Id)
	else
		self.m_VisibleTo:triggerEvent("blipDestroy", self.m_Id)
	end
end

function Blip:updateClient()
	if self.m_VisibleTo == root then
		triggerClientEvent("blipDestroy", root, self.m_Id)
	else
		self.m_VisibleTo:triggerEvent("blipDestroy", self.m_Id)
	end

	self:sendToClient()
end

function Blip:setStreamDistance(distance)
	self.m_StreamDistance = distance
	self:updateClient()
end

function Blip:setColor(color)
	self.m_Color = color
	self:updateClient()
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in pairs(Blip.Map) do
		if v.m_VisibleTo == root then
			data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY, v.m_StreamDistance, v.m_Color}
		end
	end
	player:triggerEvent("blipsRetrieve", data)
end
