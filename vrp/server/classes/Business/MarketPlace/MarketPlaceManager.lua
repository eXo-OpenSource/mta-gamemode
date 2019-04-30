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

function MarketPlaceManager:constructor( )
	addEventHandler("Marketplace:showMarket", root, bind(self.Event_showMarket, self))
	addEventHandler("Marketplace:closeMarket", root, bind(self.Event_showMarket, self))
	self.m_UpdateTimer = setTimer(bind(self.upatePulse, self), MARKETPLACE_UPDATE_RATE, 0)
	MarketPlace:new(1, "General", {}, {}, 0, true) 
end

function MarketPlaceManager:destructor()
	for id, market in pairs(self.m_Markets) do 
		market:delete()
	end
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
			market:updateAll()
		end
	end
end

