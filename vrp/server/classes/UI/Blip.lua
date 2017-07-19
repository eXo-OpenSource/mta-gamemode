-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/Blip.lua
-- *  PURPOSE:     Blip manager
-- *
-- ****************************************************************************
Blip = inherit(Object)
Blip.Map = {}




--[[
	visibleTo:
	{
		faction = id or {id1, id2},
		factionType = type or {type2, type2},
		company = id or {id1, id2},
		group = id or {id1, id2},
	},
	or
	element or {ele1, ele2}
]]

function Blip:constructor(imagePath, x, y, visibleTo, streamDistance, color, optionalColor)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	self.m_VisibleTo = visibleTo or root
	self.m_StreamDistance = streamDistance or 400
	self.m_Color = color or {255, 255, 255}
	self.m_OptionalColor = optionalColor or {255, 255, 255}

	self.m_Id = #Blip.Map + 1
	Blip.Map[self.m_Id] = self

	if type(self.m_VisibleTo) == "table" then
		for i,v in pairs(self.m_VisibleTo) do
			if isElement(v) then break end -- don't do anything if its a table full of players
			if type(v) == "table" then -- multiple ids ( faction = {1,2})
				for __, id in pairs(self.m_VisibleTo[v]) do self.m_VisibleTo[v][id] = true end
			else -- single id (faction = 1)
				local id = self.m_VisibleTo[v]
				self.m_VisibleTo[v] = {[id] = true}
			end
		end
	end

	local data = {
			icon 			= self.m_ImagePath,
			x 				= self.m_PosX,
			y 				= self.m_PosY,
			streamDistance 	= self.m_StreamDistance,
			color 			= self.m_Color,
			optionalColor 	= self.m_OptionalColor,
		}
	self:updateClient("Create", data)
end

function Blip:destructor()
	Blip.Map[self.m_Id] = nil
	self:updateClient("Destroy", {destroy = true})
end

function Blip:isVisibleForPlayer(player)
	if self.m_VisibleTo == root then return true end
	if self.m_VisibleTo == player then return true end

	local fac = player:getFaction()
	if fac then
		if self.m_VisibleTo["faction"] and self.m_VisibleTo["faction"][fac:getId()] then
			return true
		elseif self.m_VisibleTo["factionType"] and self.m_VisibleTo["factionType"][fac:getType()] then
			return true
		end
	end

	local comp = player:getCompany()
	if comp and self.m_VisibleTo["company"] and self.m_VisibleTo["company"][comp:getId()] then
		return true
	end

	local group = player:getGroup()
	if group and self.m_VisibleTo["group"] and self.m_VisibleTo["group"][group:getId()] then
		return true
	end

	for i,v in pairs(self.m_VisibleTo) do
		if v == player then return true end -- visibleTo is a table full of players
	end

	return false
end

function Blip:setStreamDistance(distance)
	self.m_StreamDistance = distance
	self:updateClient("Update", {streamDistance = distance})
end

function Blip:setPosition(vPos)
	self.m_PosX = vPos.x
	self.m_PosY = vPos.y
	self.m_PosZ = vPos.z
	self:updateClient("Update", {x = vPos.x, y = vPos.y, z = vPos.z})
end

function Blip:setZ(z)
	self.m_PosZ = z
	self:updateClient("Update", {z = z})
end

function Blip:setColor(color)
	self.m_Color = color
	self:updateClient("Update", {color = self.m_Color})
end

function Blip:getColor()
	return self.m_Color
end

function Blip:setOptionalColor(color)
	self.m_OptionalColor = color
	self:updateClient("Update", {optionalColor = self.m_OptionalColor})
end

function Blip:getOptionalColor()
	return self.m_OptionalColor
end

function Blip:attach(element)
	self.m_AttachedTo = element
	self:updateClient("Update", {attachedElement = element})
end

function Blip:detach()
	self.m_AttachedTo = nil
	self:updateClient("Update", {detach = true})
end

function Blip:setDisplayText(text, category)
	if self.m_DisplayText then return end
	self.m_DisplayText = text
	self.m_Category = category or BLIP_CATEGORY.Default
	self:updateClient("Update", {displayText = text, category = self.m_Category})
end

function Blip:updateClient(type, data)
	if self.m_VisibleTo == root then
		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "blip"..type, root, self.m_Id, data)
	else
		for i,player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
			if self:isVisibleForPlayer(player) then
				player:triggerEvent("blip"..type, root, self.m_Id, data)
			end
		end
	end
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in pairs(Blip.Map) do
		data[v.m_Id] = {
			icon 			= v.m_ImagePath,
			x 				= v.m_PosX,
			y 				= v.m_PosY,
			z				= v.m_PosZ,
			streamDistance 	= v.m_StreamDistance,
			color 			= v.m_Color,
			optionalColor 	= v.m_OptionalColor,
			displayText 	= v.m_DisplayText,
			category 		= v.m_Category,
			attachedElement = v.m_AttachedTo,
		}
	end
	player:triggerEvent("blipsRetrieve", data)
end
