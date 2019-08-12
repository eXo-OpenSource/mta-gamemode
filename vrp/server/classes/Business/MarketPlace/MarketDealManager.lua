-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketDealManager.lua
-- *  PURPOSE:     Business MarketdealManager class
-- *
-- ****************************************************************************
MarketDealManager = inherit(Object)

function MarketDealManager:constructor(market)
	self.m_Market = market
	self.m_DealHandler = MarketDealHandler:new(self:getMarket(), 0)
	self.m_Map = {}
	self.m_PlayerLookup = {} -- pass in player as index then get all their deals, usefull for easy access from a player-perspective
	self.m_BuyerLookup = {} -- this will provide us a quick way to check wether there are other deals that touch the same buy-offer*
	self.m_SellerLookup = {} -- this will provide us a quick way to check wether there are other deals that touch the same sell-offer*
	-- * the case happens when an offer just buys/sells a fraction of another offer; we then have multiple deals running over the same offer since its quantity gets split
	---  and divided upon other deals
	---|  example -> offer1[sell:2xitem] -> offer2[buy:1xitem] = deal1[offer1, offer2, amount:1] | offer1 sells its item to offers2 but we have one item left in offer1 since it was 2xitem
	---|  			 offer2[sell:1xitem] -> offer3[buy:1xitem] = deal2[offer1, offer3, amount:1] | now we have two deals with the same offer (offer1) 
end

function MarketDealManager:destructor() 
	for id, instance in pairs(self.m_Map) do 
		instance:delete(true)
	end
end

function MarketDealManager:map()
	local query = "SELECT * FROM ??_marketplace_deals WHERE MarketId=?"
	local result = sql:queryFetch(query, sql:getPrefix(), self:getMarket():getId())
	local loadCount = 0
	if result then
		for index, row in pairs(result) do
			local instance = MarketDeal:new(self, row.Id, row.MarketId, row.SellId, row.BuyId, row.Amount, row.ConfirmTake, row.ConfirmPay)
			if instance and instance:isValid() then
				loadCount = loadCount + 1
			else
				instance:delete()
			end
		end
		if DEBUG then outputDebugString( ("[Marketplace] Loaded %s marketplace-deals for (Id: %s)"):format(loadCount, self:getMarket():getName()), 0, 150, 150, 0) end
	end
end

function MarketDealManager:addToPlayerMap(player, deal, type) -- type: whether it is a buy or a sell
	if not self:getPlayerMap()[player] then self:getPlayerMap()[player] = {} end
	if not self:getPlayerMap()[player][deal:getId()] then self:getPlayerMap()[player][deal:getId()] = {} end
	self:getPlayerMap()[player][deal:getId()][type] = deal
end

function MarketDealManager:addBuyerToMap(buyer, deal)
	if not self:getBuyerLookup()[buyer:getId()] then self:getBuyerLookup()[buyer:getId()] = {} end
	self:getBuyerLookup()[buyer:getId()][deal:getId()] = deal
end

function MarketDealManager:removeBuyerFromMap(buyer, deal)
	if self:getBuyerLookup()[buyer:getId()] and  self:getBuyerLookup()[buyer:getId()][deal:getId()] then
		self:getBuyerLookup()[buyer:getId()][deal:getId()] = nil
	end
end

function MarketDealManager:addSellerToMap(seller, deal)
	if not self:getSellerLookup()[seller:getId()] then self:getSellerLookup()[seller:getId()] = {} end
	self:getSellerLookup()[seller:getId()][deal:getId()] = deal
end

function MarketDealManager:removeSellerFromMap(seller, deal)
	if self:getSellerLookup()[seller:getId()] and  self:getSellerLookup()[seller:getId()][deal:getId()] then
		self:getSellerLookup()[seller:getId()][deal:getId()] = nil
	end
end

function MarketDealManager:pulse()
	self:getDealHandler():pulse()
end

function MarketDealManager:getMarket() return self.m_Market end
function MarketDealManager:getMap() return self.m_Map end
function MarketDealManager:getPlayerMap() return self.m_PlayerLookup end
function MarketDealManager:getBuyerLookup() return self.m_BuyerLookup end
function MarketDealManager:getSellerLookup() return self.m_SellerLookup end
function MarketDealManager:getPlayerOffers(player) return self.m_PlayerLookup[player] end
function MarketDealManager:getDealHandler() return self.m_DealHandler end
function MarketDealManager:getId(id)
	return MarketDealManager.Map[id]
end

