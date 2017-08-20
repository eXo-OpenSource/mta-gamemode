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
				local new = {}
				for __, id in pairs(self.m_VisibleTo[i]) do new[id] = true end
				self.m_VisibleTo[i] = new
			else -- single id (faction = 1)
				local id = self.m_VisibleTo[i]
				self.m_VisibleTo[i] = {[id] = true}
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
	if not self.m_VisibleTo then return false end
	if self.m_VisibleTo == root then return true end
	if self.m_VisibleTo == player then return true end
	if isElement(self.m_VisibleTo) then return false end -- visibleTo is an element which is not the player, so skip it
	if not isElement(player) then return false end -- blips who were visible to a player which does no longer exist

	local fac = player:getFaction()
	if fac then
		if self.m_VisibleTo["faction"] and self.m_VisibleTo["faction"][fac:getId()] then
			if self.m_VisibleTo["duty"] and (fac:getType() ~= "Evil" and not player:isFactionDuty()) then return false end -- duty check not for evil factions
			return true
		elseif self.m_VisibleTo["factionType"] and self.m_VisibleTo["factionType"][fac:getType()] then
			if self.m_VisibleTo["duty"] and (fac:getType() ~= "Evil" and not player:isFactionDuty()) then return false end
			return true
		end
	end

	local comp = player:getCompany()
	if comp and self.m_VisibleTo["company"] and self.m_VisibleTo["company"][comp:getId()] then
		if self.m_VisibleTo["duty"] and not player:isCompanyDuty() then return false end
		return true
	end

	local group = player:getGroup()
	if group and self.m_VisibleTo["group"] and self.m_VisibleTo["group"][group:getId()] then
		return true
	end

	if type(self.m_VisibleTo) == "table" then
		for i,v in pairs(self.m_VisibleTo) do
			if v == player then return true end -- visibleTo is a table full of players
		end
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

function Blip:getPosition(vec)
	local x, y, z
	if self:getAttachedElement() then
		x, y, z = getElementPosition(self:getAttachedElement())
	else
		x, y, z = self.m_WorldX, self.m_WorldY, self.m_WorldZ or 0
	end
	if vec then
		x = Vector3(x, y, z)
		y, z = nil, nil
	end
	return x, y, z
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

function Blip:getAttachedElement()
	return Blip.AttachedBlips[self]
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

	return self
end

function Blip:updateClient(type, data)
	if self.m_VisibleTo == root then
		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "blip"..type, resourceRoot, self.m_Id, data)
	else
		local players = {}
		for i,player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
			if self:isVisibleForPlayer(player) then
				table.insert(players, player)
			end
		end
		triggerClientEvent(players, "blip"..type, resourceRoot, self.m_Id, data)
	end
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in pairs(Blip.Map) do
		if v:isVisibleForPlayer(player) then
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
	end
	player:triggerEvent("blipsRetrieve", data)
end
