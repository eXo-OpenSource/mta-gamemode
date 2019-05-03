-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketDeal.lua
-- *  PURPOSE:     Business Marketplace-Deal class
-- *
-- ****************************************************************************
MarketDeal = inherit(Object)

function MarketDeal:constructor(manager, id, market, selloffer, buyoffer, amount, confirmTake, confirmPay) 
	self.m_Valid = false
	self.m_Manager = manager
	self.m_Market = MarketPlaceManager:getSingleton():getId(market)
	if self:getMarket() and self:getMarket():isValid() and amount > 0 then 
		self.m_Id = id
		self.m_Sell = self:getMarket():getOfferFromId(selloffer)
		self.m_Buy = self:getMarket():getOfferFromId(buyoffer)
		self.m_Amount = amount
		self.m_ConfirmTake = confirmTake and fromboolean(confirmTake) or false 
		self.m_ConfirmPay = confirmPay and fromboolean(confirmPay) or false
		if self:getSell() and self:getSell():isValid() and self:getBuy() and self:getBuy():isValid() then
			self:getSell():setDealt(true)
			self:getSell():save()
			self:getBuy():setDealt(true)
			self:getBuy():save()
			self.m_Valid = true
			if id == 0 then
				self:save()
			end
			self:getManager():getMap()[self:getId()] = self
			self:getManager():addToPlayerMap(self:getSell():getPlayer(), self)
			self:getManager():addToPlayerMap(self:getBuy():getPlayer(), self)
			self:getManager():addBuyerToMap(self:getBuy(), self)
			self:getManager():addSellerToMap(self:getSell(), self)
			self:notify()
		end
	end
end

function MarketDeal:destructor(save)
	if self:isValid() then
		if not save then
			if table.size(self:getManager():getBuyerLookup()[self:getBuy():getId()]) < 2  then
				self:getBuy():delete()
			end
			if table.size(self:getManager():getSellerLookup()[self:getSell():getId()]) < 2 then
				self:getSell():delete()
			end
			sql:queryExec("DELETE FROM ??_marketplace_deals  WHERE Id = ?;", sql:getPrefix(), self:getId())
			local result = sql:queryFetchSingle("SELECT COUNT(*) As Count FROM ??_marketplace_deals", sql:getPrefix())
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
		self:getManager():getMap()[self:getId()] = nil
		if self:getManager():getPlayerMap()[self:getSell():getPlayer()] then 
			self:getManager():getPlayerMap()[self:getSell():getPlayer()][self:getId()] = nil
		end
		if self:getManager():getPlayerMap()[self:getBuy():getPlayer()] then 
			self:getManager():getPlayerMap()[self:getBuy():getPlayer()][self:getId()] = nil
		end
		self:getManager():removeBuyerFromMap(self:getBuy(), self)
		self:getManager():removeSellerFromMap(self:getSell(), self)
	end
end

function MarketDeal:notify() 
	local buyer, isOffline = DatabasePlayer.get(self:getBuy():getPlayer())	
	if not isOffline then
		if isValidElement(buyer, "player") then 
			buyer:sendShortMessage(_("Dir wurden deine Waren verkauft!", buyer))
		end
	end
	local seller, isOffline = DatabasePlayer.get(self:getSell():getPlayer())	
	if not isOffline then
		if isValidElement(seller, "player") then 
			seller:sendShortMessage(_("Deine Waren wurden verkauft!", seller))
		end
	end
end

function MarketDeal:save()
	local query = "INSERT INTO ??_marketplace_deals (Id, MarketId, SellId, BuyId, Amount, Date) VALUES(?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE ConfirmTake=?, ConfirmPay=?"
	sql:queryExec(query, sql:getPrefix(), self:getId(), self:getMarket():getId(), self:getSell():getId(), self:getBuy():getId(), self:getAmount(), fromboolean(self:isTaken()), fromboolean(self:isPaid()))
	if self:getId() == MARKETPLACE_EMTPY_ID then
		self.m_Id = sql:lastInsertId()
	end
end

function MarketDeal:truncate() 
	sql:queryExec("TRUNCATE ??_marketplace_deals", sql:getPrefix())
	if DEBUG then outputDebugString( ("[Marketplace] Truncated %s_marketplace_deals"):format(sql:getPrefix()), 0, 200, 200, 200) end
end

function MarketDeal:confirmPay() -- in case the seller comes to get his stuff
	self.m_ConfirmPay = true 
	if self:isTaken() then -- handshake
		self:delete()
	end
end

function MarketDeal:confirmTake() -- in case the buyer comes to get his stuff
	self.m_ConfirmTake = true 
	if self:isPaid() then -- handshake
		self:delete() 
	end
end

function MarketDeal:getId() return self.m_Id end
function MarketDeal:isValid() return self.m_Valid end
function MarketDeal:getSell() return self.m_Sell end
function MarketDeal:getBuy() return self.m_Buy end
function MarketDeal:getManager() return self.m_Manager end
function MarketDeal:isTaken() return self.m_ConfirmTake end
function MarketDeal:isPaid() return self.m_ConfirmPay end
function MarketDeal:getMarket() return self:getManager():getMarket() end
function MarketDeal:getAmount() return self.m_Amount end