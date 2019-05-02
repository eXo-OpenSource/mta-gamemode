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
		self.m_Id = id
		self.m_Item = item 
		self.m_Value = value 
		self.m_Type = offerType
		self.m_Price = price
		self.m_Quantity = quantity
		self.m_Player = playerId
		self.m_Done = done or false
		self.m_Category = category or 1
		if not self.m_Market.m_Offers[item] then  self.m_Market.m_Offers[item] = {} end
		if not self.m_Market.m_Offers[item][value] then self.m_Market.m_Offers[item][value] = {} end
		if not self.m_Market.m_Offers[item][value][offerType] then self.m_Market.m_Offers[item][value][offerType] = {} end
		if not self.m_Market.m_Offers[item][value][offerType][price] then self.m_Market.m_Offers[item][value][offerType][price] = {} end
		if self.m_Market.m_Offers[item][value][offerType][price][playerId] then 
			local previousQuantity = self.m_Market.m_Offers[item][value][offerType][price][playerId]:getQuantity()
			self.m_Market.m_Offers[item][value][offerType][price][playerId]:delete()
			self.m_Quantity = quantity + previousQuantity
		end

		self.m_Market.m_Offers[item][value][offerType][price][playerId] = self
		if id == 0 then
			self:save()
		end
		self.m_Market.m_Map[self:getId()] = self
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
		self.m_Market.m_Offers[self:getItem()][self:getValue()][self:getType()][self:getPrice()][self:getPlayer()] = nil
		self.m_Market.m_Map[self:getId()] = nil
	end
end

function MarketOffer:save()
	local query = "INSERT INTO ??_marketplace_offers (Id, MarketId, PlayerId, Item, Value, Type, Price, Quantity, Category, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE Quantity = ?, Done=?"
	sql:queryExec(query, sql:getPrefix(), self:getId(), self.m_Market:getId(), self:getPlayer(), self:getItem(), self:getValue(), self:getType(), self:getPrice(), self:getQuantity(), self:getCategory(), self:getQuantity(), fromboolean(self:isDone()))
	if self.m_Id == MARKTPLACE_EMTPY_ID then
		self.m_Id = sql:lastInsertId()
	end
end

function MarketOffer:truncate() 
	sql:queryExec("TRUNCATE ??_marketplace_offers", sql:getPrefix())
	if DEBUG then outputDebugString( ("[Marketplace] Truncated %s_marketplace_offers"):format(sql:getPrefix()), 0, 200, 200, 200) end
end

function MarketOffer:setQuantity(quantity) 
	self.m_Quantity = quantity
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
function MarketOffer:isDone() return self.m_Done end
