-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/BarShop.lua
-- *  PURPOSE:     BarShop Class
-- *
-- ****************************************************************************
BarShop = inherit(Shop)

function BarShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	self.m_Type = "Bar"
	self.m_TypeName = "Bar"
	self.m_Items = SHOP_ITEMS["Bar"]

	self.m_StripperPositions = SHOP_BAR_STRIP[self.m_TypeDataName] or false
	self.m_StripperEnabled = false
	self.m_StripperCurrent = {}

	self.m_SoundUrl = ""

	if self.m_Marker then
		self.m_SoundCol = createColSphere(self.m_Marker:getPosition(), 50)
		self.m_SoundCol:setDimension(self.m_Dimension)
		self.m_SoundCol:setInterior(self.m_Interior)
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onBarMarkerHit, self))
	end

	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			if self:isPlayerInBar(player) then
				self:onShopExit(player)
			end
		end
	)
end

function BarShop:onBarMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if self.m_Marker then
			if not self.m_Marker.m_Disable then
				hitElement:triggerEvent("showBarGUI")
				triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
			end
		else
			hitElement:triggerEvent("showBarGUI")
			triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
		end
	end
end

function BarShop:onShopEnter(player)
	if self.m_SoundUrl ~= "" then
		player:triggerEvent("barUpdateMusic", self.m_SoundUrl)
	end
end

function BarShop:onShopExit(player)
	player:triggerEvent("barUpdateMusic")
end

function BarShop:getPlayerInBar()
	return self.m_SoundCol:getElementsWithin("player")
end

function BarShop:isPlayerInBar(player)
	if player and isElement(player) and player:isWithinColShape(self.m_SoundCol) then
		return true
	else
		return false
	end
end

function BarShop:changeMusic(player, stream)

	if not self:isOwnerMember(player) then
		player:sendError(_("Du bist nicht berechtigt!", player))
		-- Todo: Report possible cheat attempt
		return
	end

	self.m_SoundUrl = stream
	for index, playerItem in pairs(self:getPlayerInBar()) do
		if playerItem:getDimension() == self.m_Dimension and playerItem:getInterior() == self.m_Interior then
			playerItem:sendShortMessage(_("%s hat die Musik in der Bar gewechselt!", playerItem, player:getName()))
			playerItem:triggerEvent("barUpdateMusic", self.m_SoundUrl)
		end
	end
end

function BarShop:stopMusic(player)

	if not self:isOwnerMember(player) then
		player:sendError(_("Du bist nicht berechtigt!", player))
		-- Todo: Report possible cheat attempt
		return
	end

	self.m_SoundUrl = ""
	for index, playerItem in pairs(self:getPlayerInBar()) do
		if playerItem:getDimension() == self.m_Dimension and playerItem:getInterior() == self.m_Interior then
			playerItem:sendShortMessage(_("%s hat die Musik in der Bar gestoppt!", playerItem, player:getName()))
			playerItem:triggerEvent("barUpdateMusic")
		end
	end
end

function BarShop:sendShortMessage(msg)
	for index, playerItem in pairs(self:getPlayerInBar()) do
		if playerItem:getDimension() == self.m_Dimension and playerItem:getInterior() == self.m_Interior then
			playerItem:sendShortMessage(msg)
		end
	end
end

function BarShop:startStripper(player)
	if not self:isOwnerMember(player) then
		player:sendError(_("Du bist nicht berechtigt!", player))
		-- Todo: Report possible cheat attempt
		return
	end
	if not self.m_StripperEnabled then
		if self.m_StripperPositions then
			if self:getMoney() >= 15 then
				self:takeMoney(15)
				local skins = self.m_StripperPositions["Skins"]
				for index, tbl in pairs(self.m_StripperPositions) do
					if index ~= "Skins" then
						self:addStripper(index, tbl, skins)
					end
				end

				self.m_StripperTimer = setTimer(function()
					if self:getMoney() >= 15 then
						self:takeMoney(15)
					else
						self:stopStripper(false, true)
					end
				end, 15*60*1000, 0)

				self.m_StripperEnabled = true
				self:sendShortMessage(_("%s hat Stripperinnen für diese Bar engagiert!", player, player:getName()))
			else
				player:sendError(_("Es ist nicht genug Geld in der Bar-Kasse!", player))
			end
		else
			player:sendError(_("Stripperinnen sind in dieser Bar nicht möglich!", player))
		end
	else
		player:sendError(_("Es sind bereits Stripperinnen engagiert!", player))
	end
end

function BarShop:stopStripper(player, force)
	if not force then
		if not self:isOwnerMember(player) then
			player:sendError(_("Du bist nicht berechtigt!", player))
			-- Todo: Report possible cheat attempt
			return
		end
	end

	if self.m_StripperEnabled then
		for id, npc in pairs(self.m_StripperCurrent) do
			npc:destroy()
		end

		self.m_StripperCurrent = {}
		self.m_StripperEnabled = false
		if self.m_StripperTimer and isTimer(self.m_StripperTimer) then killTimer(self.m_StripperTimer) end

		if force then
			self:sendShortMessage("Die Stripperinnen sind gegangen, es war nicht genug Geld in der Bar-Kasse!")
		else
			self:sendShortMessage(_("%s hat Stripperinnen für diese Bar entlassen!", player, player:getName()))
		end
	else
		if not force then
			player:sendError(_("Es sind keine Stripperinnen engagiert!", player))
		end
	end
end

function BarShop:addStripper(id, pos, skins)
	local skin = Randomizer:getRandomTableValue(skins)
	local animation = Randomizer:getRandomTableValue(SHOP_BAR_STRIP_ANIMATIONS)

	local npc = NPC:new(skin, pos["Pos"].x, pos["Pos"].y, pos["Pos"].z, pos["Rot"])

	npc:setImmortal(true)
	npc:setFrozen(true)
	npc:setInterior(self.m_Interior)
	npc:setDimension(self.m_Dimension)
	npc:setAnimation("STRIP", animation,-1, true, false, false)

	self.m_StripperCurrent[id] = npc
end
