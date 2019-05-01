-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketOffer.lua
-- *  PURPOSE:     Business Marketplace-Offer class
-- *
-- ****************************************************************************
MarketOffer = inherit(Object)

function MarketOffer:constructor(id, market, playerId, item, quantity, price, value, offerType, category, done) 
	self.m_Market = MarketPlaceManager:getSingleton():getId(market)
	self.m_Valid = false
	if self.m_Market and self.m_Market:isValid() then
		self.m_Valid = true
		self.m_Item = item 
		self.m_Value = value 
		self.m_Type = offerType
		self.m_Price = price
		self.m_Quantity = quantity
		self.m_Player = playerId
		self.m_Done = done or false
		self.m_Category = category or 1

		self.m_HasSqlEntry = false
		if not self.m_Market.m_Offers[playerId] then  self.m_Market.m_Offers[playerId] = {} end
		if not self.m_Market.m_Offers[playerId][item] then self.m_Market.m_Offers[playerId][item] = {} end
		if not self.m_Market.m_Offers[playerId][item][value] then self.m_Market.m_Offers[playerId][item][value] = {} end
		if not self.m_Market.m_Offers[playerId][item][value][offerType] then self.m_Market.m_Offers[playerId][item][value][offerType] = {} end

		if self.m_Market.m_Offers[playerId][item][value][offerType][price] then 
			local previousQuantity = self.m_Market.m_Offers[playerId][item][value][offerType][price]:getQuantity()
			self.m_Market.m_Offers[playerId][item][value][offerType][price]:delete()
			self.m_Quantity = quantity + previousQuantity
		end

		self.m_Market.m_Offers[playerId][item][value][offerType][price] = self

		self.m_Id = id

		self:save()
		self.m_Market.m_Map[self:getId()] = self
	end
end

function MarketOffer:isValid() return self.m_Valid end
function MarketOffer:getItem() return self.m_Item end
function MarketOffer:getValue() return self.m_Value end
function MarketOffer:getType() return self.m_Type end
function MarketOffer:getPrice() return self.m_Price end
function MarketOffer:getQuantity() return self.m_Quantity end

function MarketOffer:save()
	local query = "INSERT INTO ??_marketplace_offers (Id, MarketId, PlayerId, Item, Value, Type, Price, Quantity, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE Quantity = ?"
	sql:queryExec(query, sql:getPrefix(), self.m_Id, self.m_Market:getId(), self.m_Player, self.m_Item, self.m_Value, self.m_Type, self.m_Price, self.m_Quantity, self.m_Quantity)
	if self.m_Id == 0 then
		self.m_Id = sql:lastInsertId()
	end
end


function MarketOffer:destructor(save)
	if self:isValid() then
		if not save then
			sql:queryExec("DELETE FROM ??_marketplace_offers  WHERE Id = ?;", sql:getPrefix(), self.m_Id)
		else 
			self:save()
		end
		self.m_Market.m_Offers[self.m_Player][self.m_Item][self.m_Value][self.m_Type][self.m_Price] = nil
	end
end