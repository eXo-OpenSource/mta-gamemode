MARKETPLACE_UPDATE_RATE = 1000

MARKETPLACE_EMTPY_ID = 0
MARKET_ITEM_CATEGORIES_INT = 
{
	[1] = "ITEM:::",
	[2] = "VEHICLE:::",
	[3] = "WEAPON:::",
}
MARKET_ITEM_CATEGORIES_ID = 
{
	ITEM = "ITEM:::",
	VEHICLE = "VEHICLE:::",
	WEAPON = "WEAPON:::",
}

MARKET_ITEM_CATEGORIES_INT_TO_CONSTANT = 
{
	ITEM = 1,
	VEHICLE = 2,
	WEAPON = 3,
}

MARKET_MESSAGE_TITLE = "Marktplatz"

function toMarketPlaceItem(item, category)
	if item and tonumber(item) then
		if MARKET_ITEM_CATEGORIES_INT[category] then 
			return ("%s%s"):format(MARKET_ITEM_CATEGORIES_INT[category], item)
		end
	end
end

function fromMarketPlaceItem(item)
	if item and type(item) == "string" then 
		for index, category in pairs(MARKET_ITEM_CATEGORIES_INT) do 
			if item:find(category) and item:find(category) == 1 then 
				local pureItem = item:gsub(category, "")
				return tonumber(pureItem)
			end
		end
	else 
		return item
	end
end