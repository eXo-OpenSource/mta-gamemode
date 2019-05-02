-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/MarketPlace/MarketDealHandler.lua
-- *  PURPOSE:     Business Marketplace DealHandler class
-- *
-- ****************************************************************************
MarketDealHandler = inherit(Object)

function MarketDealHandler:constructor(market, tax) -- automatically finds the best sale-buy-deal taking first-in-first-out into account for sell&buy
	self.m_Market = market
	self.m_Tax = tax
end

function MarketDealHandler:pulse() 
	local offers = self:getMarket():getOffer()
	if offers then
		for item, data in pairs(offers) do 
			for value, subdata in pairs(data) do 
				local sell = offers[item][value]["sell"]
				local buy = offers[item][value]["buy"]
				if sell and buy then 
					if table.size(buy) > 0 then
						for index, id in ipairs(self:getSorted(sell)) do -- first-come-first-serve for selling
							local bestBuy = true 
							local entry = self.m_Market:getOfferFromId(id)
							while(bestBuy and entry:getQuantity() > 0) do
								bestBuy = self:getMaxPrice(buy, entry:getPrice()) -- get the highest FiFo buy-offer for the lowest sell price, then repeat untill everything is sold in case we have more to sell
								if bestBuy then
									bestBuy = self:deal(entry, bestBuy)
								end
							end
						end
					end
				end
			end
		end
	end	
end

function MarketDealHandler:getSorted(list)
	local sort = {}
	for price, subdata in pairs(list) do 
		if list[price] then 
			for player, entry in pairs(list[price]) do
				sort[#sort+1] = entry:getId()
			end 
		end
	end
	table.sort(sort)
	return #sort > 0 and sort or {}
end

function MarketDealHandler:deal(sell, buy)
	local sellQuantity = sell:getQuantity()
	local buyQuantity = buy:getQuantity() 
	local take = (buyQuantity >= sellQuantity and sellQuantity) or buyQuantity
	sell:setQuantity(sellQuantity - take)
	buy:setQuantity(buyQuantity - take)
	MarketDeal:new(self:getMarket():getDealManager(), MARKETPLACE_EMTPY_ID, self:getMarket():getId(), sell:getId(), buy:getId(), take)
	
	--// todo: log this deal so buyer and seller can get their cut when visiting later
end 

function MarketDealHandler:getMaxPrice(entry, limitPrice)
	local max = 0
	local found
	for price, data in pairs(entry) do
		if entry[price] then
			for player, subdata in pairs(entry[price]) do
				if subdata and subdata:getQuantity() > 0 then
					if price >= limitPrice then
						if price >= max then
							max = price
							found = true
						end
					end
				end
			end
		end 
	end
	local sortTable = {}
	if found then
		if entry[max] then 
			for player, object in pairs(entry[max]) do
				sortTable[#sortTable+1] = object
			end
		end
	end
	table.sort(sortTable) -- First-come-first-serve as well
	return (sortTable and sortTable[1]) or false
end

function MarketDealHandler:destructor()

end

function MarketDealHandler:getMarket() return self.m_Market end
