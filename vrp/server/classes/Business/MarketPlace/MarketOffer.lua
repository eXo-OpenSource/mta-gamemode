-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketOffer.lua
-- *  PURPOSE:     Business Marketplace-Offer class
-- *
-- ****************************************************************************
MarketOffer = inherit(Object)

function MarketOffer:constructor(market, id, playerId, item, quantity, price, value, offerType, category) 
	self.m_Market = market
	self.m_Item = item 
	self.m_Value = value 
	self.m_Type = offerType
	self.m_Price = price
	self.m_Quantity = quantity
	self.m_Player = playerId
	self.m_Category = category
	self.m_HasSqlEntry = false
	if not market.m_Offers[playerId] then  market.m_Offers[playerId] = {} end
	if not market.m_Offers[playerId][item] then market.m_Offers[playerId][item] = {} end
	if not market.m_Offers[playerId][item][value] then market.m_Offers[playerId][item][value] = {} end
	if not market.m_Offers[playerId][item][value][offerType] then market.m_Offers[playerId][item][value][offerType] = {} end

	if market.m_Offers[playerId][item][value][offerType][price] then 
		local previousQuantity = market.m_Offers[playerId][item][value][offerType][price]:getQuantity()
		market.m_Offers[playerId][item][value][offerType][price]:delete()
		self.m_Quantity = quantity + previousQuantity
	end

	market.m_Offers[playerId][item][value][offerType][price] = self
	
	self.m_Id = id

	self:save()
end

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


function MarketOffer:destructor()
	self.m_Market.m_Offers[self.m_Player][self.m_Item][self.m_Value][self.m_Type][self.m_Price] = nil
	sql:queryExec("DELETE FROM ??_marketplace_offers  WHERE Id = ?;", sql:getPrefix(), self.m_Id)
end