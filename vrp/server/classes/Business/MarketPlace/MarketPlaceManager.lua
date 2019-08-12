-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketPlaceManager.lua
-- *  PURPOSE:     Business Marketplace class
-- *
-- ****************************************************************************
MarketPlaceManager = inherit(Singleton)

addRemoteEvents{ "Marketplace:closeClient", "Marketplace:getMarkets", "Marketplace:getOffer", "Marketplace:getMarket", "Marketplace:getDeals"}

MarketPlaceManager.Map = {}

function MarketPlaceManager:constructor()
	addEventHandler("Marketplace:getMarkets", root, bind(self.Event_getMarkets, self))
	addEventHandler("Marketplace:getMarket", root, bind(self.Event_getMarket, self))
	addEventHandler("Marketplace:getOffer", root, bind(self.Event_getOffer, self))
	addEventHandler("Marketplace:getDeals", root, bind(self.Event_getDeals, self))
	addEventHandler("Marketplace:closeClient", root, bind(self.Event_closeClient, self))
	self.m_UpdateTimer = setTimer(bind(self.upatePulse, self), MARKETPLACE_UPDATE_RATE, 0)
	self.m_Clients = {}
end

function MarketPlaceManager:destructor() 
	for id, instance in pairs(MarketPlaceManager.Map) do 
		instance:delete(true)
	end
end

function MarketPlaceManager:createMarket(name)
	local instance = MarketPlace:new(0, name, {}, 0, 0, true) 
	if instance then 
		if not instance.m_Valid then 
			instance:delete()
		else 
			MarketPlaceManager.Map[instance.m_Id] = instance
		end
	end
end

function MarketPlaceManager:initialize()
	local query = "SELECT * FROM ??_marketplaces"
	local result = sql:queryFetch(query, sql:getPrefix())
	local loadCount = 0
	if result then
		for index, row in pairs(result) do
			local instance = MarketPlace:new(row.Id, row.Name, row.Storage, row.Bank, row.Type, toboolean(row.Open))
			if instance:isValid() then
				loadCount = loadCount + 1
			else 
				instance:delete()
			end
		end
	end
	if DEBUG then outputDebugString( ("[Marketplace] Loaded %s marketplaces"):format(loadCount), 0, 200, 200, 0) end
end

function MarketPlaceManager:getId(id)
	return MarketPlaceManager.Map[id]
end

function MarketPlaceManager:Event_closeMarket(marketId)
	if client and marketId and MarketPlaceManager.Map[marketId] then 
		MarketPlaceManager.Map[marketId]:hide(client)
	end
end

function MarketPlaceManager:Event_getMarkets()
	self.m_Clients[client] = {1} --page
	client:triggerEvent("onAppGetServercall", 1, self:getCompactMap())
end

function MarketPlaceManager:Event_getMarket(id)
	if MarketPlaceManager.Map[id] then
		self.m_Clients[client] = {2, MarketPlaceManager.Map[id]} -- page, market
		client:triggerEvent("onAppGetServercall", 2, MarketPlaceManager.Map[id])
	end
end

function MarketPlaceManager:Event_getOffer(id)
	if self.m_Clients[client] then
		local page, market = unpack(self.m_Clients[client])
		if page and market and market.getId and market:getId() then
			if MarketPlaceManager.Map[market:getId()] then
				if MarketPlaceManager.Map[market:getId()]:getMap()[id] then
					MarketPlaceManager.Map[market:getId()]:getMap()[id]:addVisitor(client)
					self.m_Clients[client] = {3, market, MarketPlaceManager.Map[market:getId()]:getMap()[id]} -- page, market, offer
					client:triggerEvent("onAppGetServercall", 3, MarketPlaceManager.Map[market:getId()]:getMap()[id])
				end
			end
		end
	end
end

function MarketPlaceManager:Event_getDeals()
	local deals = {}
	for id, market in pairs(MarketPlaceManager.Map) do 
		if market:getDealManager():getPlayerMap()[client:getId()] then
			deals[market:getName()] = {}
			for dealId, subdata in pairs(market:getDealManager():getPlayerMap()[client:getId()]) do
				deals[market:getName()][dealId] = {}
				for type, deal in pairs(subdata) do
					deals[market:getName()][dealId][type] = deal
				end
			end
		end
	end
	client:triggerEvent("onAppGetServercall", 4, deals)
end


function MarketPlaceManager:Event_closeClient()
	self.m_Clients[client] = nil
end


function MarketPlaceManager:upatePulse()
	for id, market in pairs(MarketPlaceManager.Map) do 
		if market and market.isOpen and market:isOpen() then 
			market:pulse()
		end
	end
end

function MarketPlaceManager:getCompactMap() -- this compacts the table to not send more data then necessary
	local compact = {}
	for id, instance in pairs(MarketPlaceManager.Map) do 
		compact[id] = {m_Name = instance:getName(), m_Size = instance:getActiveOfferCount()}
	end
	return compact
end

