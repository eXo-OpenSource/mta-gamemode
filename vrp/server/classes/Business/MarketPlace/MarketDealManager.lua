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

function MarketDealManager:addToPlayerMap(player, deal)
	if not self:getPlayerMap()[player] then self:getPlayerMap()[player] = {} end
	self:getPlayerMap()[player][deal:getId()] = deal
end

function MarketDealManager:pulse()
	self:getDealHandler():pulse()
end

function MarketDealManager:getMarket() return self.m_Market end
function MarketDealManager:getMap() return self.m_Map end
function MarketDealManager:getPlayerMap() return self.m_PlayerLookup end
function MarketDealManager:getPlayerOffers(player) return self.m_PlayerLookup[player] end
function MarketDealManager:getDealHandler() return self.m_DealHandler end
function MarketDealManager:getId(id)
	return MarketDealManager.Map[id]
end

