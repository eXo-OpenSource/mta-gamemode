-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketPlace.lua
-- *  PURPOSE:     Business Marketplace class
-- *
-- ****************************************************************************
MarketPlace = inherit(Object)

function MarketPlace:constructor(id, name, offers, storage, bank, open) 
	self.m_Id = id
	self.m_Clients = {}
	self.m_Open = open
	self.m_Name = name
	self.m_Offers = offers or {}
	self.m_Storage = storage or {}
	self.m_ImaginaryBank = bank or 0
	self.m_Bank = BankServer.get("gameplay.marketplace")
	self:setOpenState(open)
	MarketPlaceManager.Map[id] = self 
end

function MarketPlace:mapOffers()

end

function MarketPlace:destructor()
	self:kickAll()
end

function MarketPlace:show(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:show", self.m_Id, self.m_Offers)
	end
end

function MarketPlace:hide(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:abort", self.m_Id)
	end
end

function MarketPlace:update(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:update", self.m_Id, self.m_Offers)
	end
end

function MarketPlace:updateAll() 
	for client, bool in pairs(self.m_Clients) do
		self:update(client)
	end
end

function MarketPlace:setOpenState(state) 
	self.m_Open = state
	self:kickAll()
end

function MarketPlace:kick(player)
	if player and isElement(player) then
		if self.m_Clients[player] then 
			self:closePlayer(player)
			self.m_Clients[player] = nil
		end
	end
end

function MarketPlace:kickAll()
	for client, bool in pairs(self.m_Clients) do
		self:kick(client)
	end
end

function MarketPlace:addOffer(playerId, offerType, item, quantity, price, itemValue)
	if not playerId or not tonumber(playerId) then return "Kein Spieler gefunden" end
	if not quantity or not tonumber(quantity) or quantity < 1 then return  "Keine Anzahl" end
	if not offerType or not type(offerType) == "string" or not (offerType == "buy" or offerType == "sell") then return "Keine Verkaufsart" end
	if not item or not tonumber(item) then return "Kein Gegenstand" end
	if not price and not tonumber(price) then return "Kein Preis" end
	local player, isOffline = DatabasePlayer.get(playerId)
	itemValue = itemValue and tostring(itemValue) or ""
	local itemName = InventoryManager:getSingleton():getItemNameFromId(item)
	if not itemName then return "Kein Gegenstand gefunden!" end

	if player and not isOffline then

		if offerType == "sell" then
			local itemAmount = player:getInventory():getItemAmount(itemName, nil, itemValue ~= "" and itemValue or nil) 
			if itemAmount >= quantity then
				local check = false
				for i = 1, quantity do
					check = player:getInventory():removeItem(itemName, 1, itemValue ~= "" and itemValue or nil)
					if check then 
						self:add(item, itemValue)
					else 
						return "Nicht genug Gegenstände!"
					end
				end 
			else
				return "Nicht genug Gegenstände!"
			end
		else 
			if not self:giveMoney(player, price*quantity) then
				return "Nicht genug Geld zum kaufen!"
			end
		end
		MarketOffer:new(self, 0, playerId, item, quantity, price, itemValue, offerType) 
	end
end

function MarketPlace:add(item, itemValue)
	if not self.m_Storage[item] then self.m_Storage[item] = {} end
	if not self.m_Storage[item][itemValue] then self.m_Storage[item][itemValue] = 0 end 
	self.m_Storage[item][itemValue] = self.m_Storage[item][itemValue] + 1
end

function MarketPlace:remove(item, itemValue)
	if not self.m_Storage[item] then self.m_Storage[item] = {} end
	if not self.m_Storage[item][itemValue] then self.m_Storage[item][itemValue] = 0 end 
	self.m_Storage[item][itemValue] = self.m_Storage[item][itemValue] + 1
end

function MarketPlace:giveMoney(player, price) 
	local bar = player:getMoney() 
	local bank = player:getBankAccount():getMoney()
	local priorityBar = bar >= bank
	if bar+bank >= price then 
		if bar > price then 
			self:transferMoney(player, self.m_Bank, price, true)
		elseif bank > price then 
			self:transferMoney(player:getBankAccount(), self.m_Bank, price, true)
		else 
			if priorityBar then
				self:transferMoney(player, self.m_Bank, price-bank, true)
				self:transferMoney(player:getBankAccount(), self.m_Bank, bank, true)
				
			else 
				self:transferMoney(player:getBankAccount(), self.m_Bank, price-bar, true)
				self:transferMoney(player, self.m_Bank, bar, true)
			end
		end
		self.m_ImaginaryBank = self.m_ImaginaryBank + price
		return true
	else
		return false
	end
end

function MarketPlace:takeMoney(player, money) 
	if self.m_ImaginaryBank - money >= 0 then
		self.m_ImaginaryBank = self.m_ImaginaryBank - money
		self:transferMoney(self.m_Bank, player, money, false)
		return true
	end
	return false
end

function MarketPlace:transferMoney(sender, receiver, amount, type)
	sender:transferMoney(receiver, amount, ("%s - %s"):format(self:getName(), type and "Marktplatz-Kaufangebot" or "Marktplatz-Kaufangebot Rückzahlung"), "Gameplay", "Marketplace")
end

function MarketPlace:removeOffer(playerId, offerType, item, price, itemValue)
	if not playerId or not tonumber(playerId) then return end
	if not offerType or not type(offerType) == "string" or not (offerType == "buy" or offerType == "sell") then return end
	if not item or not tonumber(item) then return end
	if not price and not tonumber(price) then return "Kein Preis" end
	itemValue = itemValue and tostring(itemValue) or ""
	local itemName = InventoryManager:getSingleton():getItemNameFromId(item)
	if not itemName then return "Kein Gegenstand gefunden!" end
	local player, isOffline = DatabasePlayer.get(playerId)
	if not isOffline then
		local offer = self:getOffer(playerId, item, itemValue, offerType, price) 
		if offer then 
			local quantity = offer:getQuantity()
			if offerType == "sell" then 
				if self:getStorageCount(item, itemValue) - quantity >= 0 then
					for i = 1, quantity do
						self:remove(item, itemValue)
						player:getInventory():giveItem(itemName, 1, itemValue ~= "" and itemValue or nil)
					end
				else 
					return "Es können nicht so viele Gegenstände rausgeholt werden!"
				end
			elseif offerType == "buy" then
				if not self:takeMoney(player, price*quantity) then 
					return "Die Bank hat kein Geld!"
				end
			end
			offer:delete()
		else
			return "Spieler hat keinen Eintrag!"
		end
	else 
		return "Spieler nicht gefunden!"
	end
end

function MarketPlace:getOffer(player, item, value, offerType, price) 
	if self.m_Offers[player] then 
		if self.m_Offers[player][item] then 
			if self.m_Offers[player][item][value] then 
				if self.m_Offers[player][item][value][offerType] then 
					if self.m_Offers[player][item][value][offerType][price] then 
						return self.m_Offers[player][item][value][offerType][price]
					end
				end
			end
		end
	end
	return false
end

--//Todo Automatic-Deal

function MarketPlace:isOpen() return self.m_Open end
function MarketPlace:getId() return self.m_Id end
function MarketPlace:getName() return self.m_Name end
function MarketPlace:getStorageCount(item, value) 
	if not self.m_Storage[item] then 
		return 0
	end
	if not self.m_Storage[item][value] then 
		return 0
	end
	return self.m_Storage[item][value]
end