-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketPlaceManager.lua
-- *  PURPOSE:     Business Marketplace class
-- *
-- ****************************************************************************
MarketPlaceManager = inherit(Singleton)

addRemoteEvents{"Marketplace:showMarket", "Marketplace:closeMarket"}

MarketPlaceManager.Map = {}

function MarketPlaceManager:constructor()
	addEventHandler("Marketplace:showMarket", root, bind(self.Event_showMarket, self))
	addEventHandler("Marketplace:closeMarket", root, bind(self.Event_showMarket, self))
	self.m_UpdateTimer = setTimer(bind(self.upatePulse, self), MARKETPLACE_UPDATE_RATE, 0)
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

function MarketPlaceManager:Event_showMarket(marketId)
	if client and marketId and MarketPlaceManager.Map[marketId] then 
		MarketPlaceManager.Map[marketId]:show(client)
	end
end

function MarketPlaceManager:Event_closeMarket(marketId)
	if client and marketId and MarketPlaceManager.Map[marketId] then 
		MarketPlaceManager.Map[marketId]:hide(client)
	end
end

function MarketPlaceManager:upatePulse()
	for id, market in pairs(MarketPlaceManager.Map) do 
		if market and market.isOpen and market:isOpen() then 
			market:pulse()
		end
	end
end

