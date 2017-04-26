-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/Blip.lua
-- *  PURPOSE:     Blip manager
-- *
-- ****************************************************************************
Blip = inherit(Object)
Blip.Map = {}

function Blip:constructor(imagePath, x, y, visibleTo, streamDistance)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	self.m_VisibleTo = visibleTo or root
	self.m_StreamDistance = streamDistance or 400
	self.m_Color = Vector4(255, 255, 255, 255)

	self.m_Id = #Blip.Map + 1
	Blip.Map[self.m_Id] = self

	if type(self.m_VisibleTo) == "table" then
		local type, object = unpack(self.m_VisibleTo)
		self.m_VisibleType = type
		self.m_VisibleObject = object
		self.m_VisibleTo = object:getOnlinePlayers()
	end

	self:sendToClient()
end

function Blip:sendToClient()
	local visible = self.m_VisibleTo == root and getElementsByType("player") or self.m_VisibleTo

	if type(visible) == "table" then
		for k, player in pairs(visible) do
			if player:isLoggedIn() then
				player:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY, self.m_StreamDistance)
				if self.m_AttachedTo then
					player:triggerEvent("blipAttach", self.m_Id, self.m_AttachedTo)
				end
			end
		end
	else
		self.m_VisibleTo:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY, self.m_StreamDistance)
		if self.m_AttachedTo then
			self.m_VisibleTo:triggerEvent("blipAttach", self.m_Id, self.m_AttachedTo)
		end
	end
end

function Blip:destructor()
	Blip.Map[self.m_Id] = nil

	local visible = self.m_VisibleTo == root and getElementsByType("player") or self.m_VisibleTo

	if type(visible) == "table" then
		for k, player in pairs(visible) do
			if player:isLoggedIn() then
				player:triggerEvent("blipDestroy", self.m_Id)
			end
		end
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

function Blip:attach(element)
	self.m_AttachedTo = element
	self:updateClient()
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in pairs(Blip.Map) do
		if v.m_VisibleTo == root then
			data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY, v.m_StreamDistance, v.m_Color}
		elseif v.m_VisibleType then
			if v.m_VisibleType == "faction" and player:getFaction() == v.m_VisibleObject then
				data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY, v.m_StreamDistance, v.m_Color}
			elseif v.m_VisibleType == "company" and player:getCompany() == v.m_VisibleObject then
				data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY, v.m_StreamDistance, v.m_Color}
			elseif v.m_VisibleType == "group" and player:getGroup() == v.m_VisibleObject then
				data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY, v.m_StreamDistance, v.m_Color}
			end
		end
	end
	player:triggerEvent("blipsRetrieve", data)
end
