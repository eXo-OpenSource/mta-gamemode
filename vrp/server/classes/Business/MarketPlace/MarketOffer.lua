-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketOffer.lua
-- *  PURPOSE:     Business Marketplace-Offer class
-- *
-- ****************************************************************************
MarketOffer = inherit(Object)

function MarketOffer:constructor(id, market, playerId, item, quantity, price, value, offerType, category, dealt, visitorCount) 
	self.m_Market = MarketPlaceManager:getSingleton():getId(market)
	self.m_Valid = false
	if self:getMarket() and self:getMarket():isValid() and toMarketPlaceItem(item, category or 1) then
		self:getMarket():increaseOfferCount()
		self.m_Valid = true
		self.m_Id = id
		self.m_Category = category or 1
		self.m_Item = toMarketPlaceItem(item, self.m_Category) 
		self.m_ItemName = InventoryManager:getSingleton():getItemNameFromId(item)
		self.m_Value = value 
		self.m_Type = offerType
		self.m_Price = price
		self:setQuantity(quantity)
		self.m_Player = playerId
		self.m_VisitedBy = {} -- Stores each player element in order to not count multiple visits of the same player 
		self.m_VisitorCount = visitorCount or 0
		self.m_Dealt = dealt or false
		if not self:getMarket():getOffer()[self:getItem()] then  self:getMarket():getOffer()[self:getItem()] = {} end
		if not self:getMarket():getOffer()[self:getItem()][value] then self:getMarket():getOffer()[self:getItem()][value] = {} end
		if not self:getMarket():getOffer()[self:getItem()][value][offerType] then self:getMarket():getOffer()[self:getItem()][value][offerType] = {} end
		if not self:getMarket():getOffer()[self:getItem()][value][offerType][price] then self:getMarket():getOffer()[self:getItem()][value][offerType][price] = {} end
		if self:getMarket():getOffer()[self:getItem()][value][offerType][price][playerId] then 
			local previousQuantity = self:getMarket():getOffer()[self:getItem()][value][offerType][price][playerId]:getQuantity()
			self:getMarket():getOffer()[self:getItem()][value][offerType][price][playerId]:delete()
			self.m_Quantity = quantity + previousQuantity
		end

		self:getMarket():getOffer()[self:getItem()][value][offerType][price][playerId] = self
		if id == 0 then
			self:save()
		end
		local dateResult = sql:queryFetchSingle("SELECT UNIX_TIMESTAMP(Date) FROM ??_marketplace_offers WHERE Id=?", sql:getPrefix(), self:getId())
		self.m_Date = dateResult.Date
		self:getMarket():getMap()[self:getId()] = self

	end
end

function MarketOffer:destructor(save)
	if self:isValid() then
		if not save then
			sql:queryExec("DELETE FROM ??_marketplace_offers  WHERE Id = ?;", sql:getPrefix(), self:getId())
			local result = sql:queryFetchSingle("SELECT COUNT(*) As Count FROM ??_marketplace_offers", sql:getPrefix())
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
		self:getMarket():getOffer()[self:getItem()][self:getValue()][self:getType()][self:getPrice()][self:getPlayer()] = nil
		self:getMarket():getMap()[self:getId()] = nil
	end
end

function MarketOffer:save()
	local query = "INSERT INTO ??_marketplace_offers (Id, MarketId, PlayerId, Item, Value, Type, Price, Quantity, Category, VisitorCount, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE Quantity = ?, Dealt=?, VisitorCount=?"
	sql:queryExec(query, sql:getPrefix(), self:getId(), self.m_Market:getId(), self:getPlayer(), fromMarketPlaceItem(self:getItem()), self:getValue(), self:getType(), self:getPrice(), self:getQuantity(), self:getCategory(), self:getVisitorCount(), self:getQuantity(), fromboolean(self:isDealt()), self:getVisitorCount())
	if self.m_Id == MARKETPLACE_EMTPY_ID then
		self.m_Id = sql:lastInsertId()
	end
end

function MarketOffer:truncate() 
	sql:queryExec("TRUNCATE ??_marketplace_offers", sql:getPrefix())
	if DEBUG then outputDebugString( ("[Marketplace] Truncated %s_marketplace_offers"):format(sql:getPrefix()), 0, 200, 200, 200) end
end

function MarketOffer:setQuantity(quantity) 
	self.m_Quantity = quantity
	if quantity == 0 then 
		self:getMarket():decreaseOfferCount()
	end
end

function MarketOffer:setDealt(bool) 
	self.m_Dealt = bool
end

function MarketOffer:withdraw() 
	if self:getType() == "buy" then	
		local player, isOffline = DatabasePlayer.get(self:getPlayer())
		local payback = self:getQuantity() * self:getPrice()
		self:setQuantity(0)
		if player and isElement(player) then
			self:getMarket():takeMoney(player, payback)
		end
	else 
		if self:getCategory() == MARKET_ITEM_CATEGORIES_INT_TO_CONSTANT.ITEM then
			self:giveItemBack()
		end
		self:setQuantity(0)
	end
	if not self:isDealt() then 
		if self:getQuantity() == 0 then
			self:delete()
		else 
			self:save()
		end
	else 
		self:save()
	end
end

function MarketOffer:giveItemBack( )
	local giveBack = self:getQuantity()
	local itemName = InventoryManager:getSingleton():getItemNameFromId(fromMarketPlaceItem(self:getItem()))
	local player, isOffline = DatabasePlayer.get(self:getPlayer())
	if player and isElement(player) and itemName and itemName ~= "" then
		local enoughSpace = true
		local giveCount = 0
		for i = 1, giveBack do
			enoughSpace = player:getInventory():giveItem(itemName, 1, self:getValue())
			if not enoughSpace then 
				break
			else 
				giveCount = giveCount + 1
			end
		end
		if giveBack - giveCount > 0 then 	
			self:setQuantity(giveBack - giveCount)
			player:sendMessage("[Marktplatz] #ffffffDir wurden nur %s Stück (%s) zurückgegeben da, dein Inventar voll ist. Kehre mit mehr Platz zurück und hol dir alles ab!", 200, 200, 0, giveCount, itemName)
		else 
			player:sendShortMessage(_("Du hast das Angebot zurückgezogen und deine Items (%s) erhalten!", player, itemName))
		end
	end
end

function MarketOffer:addVisitor(player)
	if not self.m_VisitedBy[player:getName()] then 
		self.m_VisitedBy[player:getName()] = true 
		self.m_VisitorCount = self.m_VisitorCount + 1
	end
end

function MarketOffer:isValid() return self.m_Valid end
function MarketOffer:getId() return self.m_Id end
function MarketOffer:getItem() return self.m_Item end
function MarketOffer:getValue() return self.m_Value end
function MarketOffer:getType() return self.m_Type end
function MarketOffer:getPrice() return self.m_Price end
function MarketOffer:getQuantity() return self.m_Quantity end
function MarketOffer:getPlayer() return self.m_Player end
function MarketOffer:getCategory() return self.m_Category end
function MarketOffer:isDealt() return self.m_Dealt end
function MarketOffer:getMarket() return self.m_Market end
function MarketOffer:getVisitorCount() return self.m_VisitorCount end