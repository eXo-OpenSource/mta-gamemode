-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketPlace.lua
-- *  PURPOSE:     Business Marketplace class
-- *
-- ****************************************************************************
MarketPlace = inherit(Object)

function MarketPlace:constructor(id, name, storage, bank, open) 
	self.m_Valid = false
	if id > 0 or self:validateName(name) then -- this checks for duplicate names within the database, though a unique-key would have been more handy it would take more work to revert a failed INSERTION 
		self.m_Valid = true
		self.m_Id = id
		self.m_Clients = {}
		self.m_Map = {} -- used for quick access, stores offers unsorted in a general table for quick iteration
		self.m_Open = open or true
		self.m_Name = name
		self.m_Storage = (storage and type(storage) == "string" and fromJSON(storage)) or {}
		self.m_ImaginaryBank = bank or 0
		self.m_Bank = BankServer.get("gameplay.marketplace")
		self:setOpenState(open)
		self:save()
		self:map() -- load and store offers in a sorted table with indexes#
		self.m_DealHandler = MarketDealHandler:new(self, 0)
	end
	if not self.m_Valid then
		if DEBUG then outputDebugString( ("[Marketplace] Could not create Market due to duplicate name (%s)!"):format(name), 2) end
	end
end

function MarketPlace:destructor(save)
	if self:isValid() then
		self:kickAll()
		for id, offer in pairs(self.m_Map) do 
			offer:delete(save)
		end
		if not save then
			sql:queryExec("DELETE FROM ??_marketplaces  WHERE Id = ?", sql:getPrefix(), self.m_Id)
			local result = sql:queryFetchSingle("SELECT COUNT(*) As Count FROM ??_marketplaces", sql:getPrefix())
			if result then 
				if result.Count then 
					if result.Count == 0 then 
						self:truncate()
					end
				end
			end
		else 
			self:save()
		end
		MarketPlaceManager.Map[self:getId()] = nil
	end
end

function MarketPlace:map()
	self.m_Offers = {}
	if self.m_Id > 0 then
		local query = "SELECT * FROM ??_marketplace_offers WHERE MarketId=?"
		local result = sql:queryFetch(query, sql:getPrefix(), self:getId())
		local loadCount = 0
		if result then
			for index, row in pairs(result) do
				local instance = self:loadOffer(row.Id, row.MarketId, row.PlayerId, row.Type, row.Item, row.Quantity, row.Price, row.Value, row.Category, fromboolean(row.Done))
				if instance and instance:isValid() then
					loadCount = loadCount + 1
				else
					instance:delete()
				end
			end
		end
		if DEBUG then outputDebugString( ("[Marketplace] Loaded %s marketplace-offers for (Id: %s)"):format(loadCount, self:getName()), 0, 150, 150, 0) end
	end
end

function MarketPlace:save()
	local query = "INSERT INTO ??_marketplaces (Id, Name, Date) VALUES(?, ?,  NOW()) ON DUPLICATE KEY UPDATE Open=?, Storage=?, Bank=?"
	sql:queryExec(query, sql:getPrefix(), self:getId(), self:getName(), fromboolean(self:isOpen()), toJSON(self:getStorage(), true), self:getBankAmount())
	if self.m_Id == 0 then
		self.m_Id = sql:lastInsertId()
		if DEBUG then outputDebugString( ("[Marketplace] Created market (Name: %s, Id: %s)"):format(self:getName(), self:getId()), 0, 200, 200, 0) end
	else
		if DEBUG then outputDebugString( ("[Marketplace] Updated market (Name: %s, Id: %s)"):format(self:getName(), self:getId()), 0, 200, 200, 0) end
	end
	MarketPlaceManager.Map[self:getId()] = self 
end

function MarketPlace:truncate() 
	sql:queryExec("TRUNCATE ??_marketplaces", sql:getPrefix())
	if DEBUG then outputDebugString( ("[Marketplace] Truncated %s_marketplaces"):format(sql:getPrefix()), 0, 200, 200, 200) end
end

function MarketPlace:show(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:show", self:getId(), self:getMap())
	end
end

function MarketPlace:hide(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:abort", self:getId())
	end
end

function MarketPlace:update(player)
	if player and isElement(player) then 
		player:triggerEvent("Marketplace:update", self:getId(), self:getMap())
	end
end

function MarketPlace:updateAll() 
	self.m_DealHandler:pulse()
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

function MarketPlace:loadOffer(id, marketid, playerId, offerType, item, quantity, price, itemValue, category, done)
	local validOffer = self:validateOffer(playerId, offerType, item, quantity, price)
	if validOffer then
		itemValue = itemValue and tostring(itemValue) or ""
		return MarketOffer:new(id, marketid, playerId, item, quantity, price, itemValue, offerType, category, done)
	end
end

function MarketPlace:addOffer(playerId, offerType, item, quantity, price, itemValue, category)
	local validOffer = self:validateOffer(playerId, offerType, item, quantity, price)
	if validOffer then
		local player, isOffline = DatabasePlayer.get(playerId)
		itemValue = itemValue and tostring(itemValue) or ""
		local itemName = InventoryManager:getSingleton():getItemNameFromId(item)
		if player and not isOffline then
			if offerType == "sell" then
				local itemAmount = player:getInventory():getItemAmount(itemName, nil, self:formatItemValue(itemValue)) 
				if itemAmount >= quantity then
					local check = false
					for i = 1, quantity do
						check = player:getInventory():removeItem(itemName, 1, self:formatItemValue(itemValue))
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
			MarketOffer:new(0, self:getId(), playerId, item, quantity, price, itemValue, offerType, category)
		end
	else 
		return validOffer
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
			self:transferMoney(player, self:getBank(), price, true)
		elseif bank > price then 
			self:transferMoney(player:getBankAccount(), self:getBank(), price, true)
		else 
			if priorityBar then
				self:transferMoney(player, self:getBank(), price-bank, true)
				self:transferMoney(player:getBankAccount(), self:getBank(), bank, true)
				
			else 
				self:transferMoney(player:getBankAccount(), self:getBank(), price-bar, true)
				self:transferMoney(player, self:getBank(), bar, true)
			end
		end
		self.m_ImaginaryBank = self:getBankAmount() + price
		return true
	else
		return false
	end
end

function MarketPlace:takeMoney(player, money) 
	if self:getBankAmount() - money >= 0 then
		self.m_ImaginaryBank = self:getBankAmount() - money
		self:transferMoney(self:getBank(), player, money, false)
		return true
	end
	return false
end

function MarketPlace:transferMoney(sender, receiver, amount, type)
	sender:transferMoney(receiver, amount, ("%s - %s"):format(self:getName(), type and "Marktplatz-Kaufangebot" or "Marktplatz-Kaufangebot Rückzahlung"), "Gameplay", "Marketplace")
end

function MarketPlace:removeOffer(playerId, offerType, item, price, itemValue)
	local validOffer = self:validOffer(playerId, 1, offerType, item, price)
	if validOffer then
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
							player:getInventory():giveItem(itemName, 1, self:formatItemValue(itemValue))
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
	else 
		return validOffer
	end
end

function MarketPlace:validateOffer(player, quantity, offerType, item, price) 
	if not player or not tonumber(player) then return "Kein Spieler gefunden" end
	if not quantity or not tonumber(quantity) or quantity < 1 then return  "Keine Anzahl" end
	if not offerType or not type(offerType) == "string" or not (offerType == "buy" or offerType == "sell") then return "Keine Verkaufsart" end
	if not item or not tonumber(item) then return "Kein Gegenstand" end
	if not price and not tonumber(price) then return "Kein Preis" end
	return true
end

function MarketPlace:validateName(name)
	local query = "SELECT Name FROM ??_marketplaces WHERE Name=?"
	local result = sql:queryFetchSingle(query, sql:getPrefix(), name)
	if result then 
		if result.Name == name then 
			return false
		end 
	end
	return true
end

function MarketPlace:formatItemValue(value) 
	return value ~= "" and value or nil
end

--//Todo Automatic-Deal
function MarketPlace:isValid() return self.m_Valid end
function MarketPlace:isOpen() return self.m_Open end
function MarketPlace:getId() return self.m_Id end
function MarketPlace:getMap() return self.m_Map end
function MarketPlace:getName() return self.m_Name end
function MarketPlace:getBankAmount() return self.m_ImaginaryBank end
function MarketPlace:getBank() return self.m_Bank end
function MarketPlace:getStorage() return self.m_Storage end
function MarketPlace:getStorageCount(item, value) 
	if not self.m_Storage[item] then 
		return 0
	end
	if not self.m_Storage[item][value] then 
		return 0
	end
	return self.m_Storage[item][value]
end
function MarketPlace:getOfferFromId(id) return self.m_Map[id] end
function MarketPlace:getOffer() return self.m_Offers end
function MarketPlace:getOffers(player, item, value, offerType, price) 
	if self.m_Offers[item] then 
		if self.m_Offers[item][value] then 
			if self.m_Offers[item][value][offerType] then 
				if self.m_Offers[item][value][offerType][price] then 
					if self.m_Offers[item][value][offerType][price][player] then 
						return self.m_Offers[item][value][offerType][price][player] 
					end
				end
			end
		end
	end
	return false
end