-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Fishing.lua
-- *  PURPOSE:     Serverside Fishing Class
-- *
-- ****************************************************************************
Fishing = inherit(Singleton)
addRemoteEvents{"clientFishHit", "clientFishCaught", "clientRequestFishPricing", "clientRequestFishTrading", "clientSendFishTrading"}

function Fishing:constructor()
	self.Random = Randomizer:new()
	self.m_Players = {}

	self:loadFishDatas()
	self:updatePricing()

	self.m_UpdatePricingPulse = TimedPulse:new(3600000)
	self.m_UpdatePricingPulse:registerHandler(bind(Fishing.updatePricing, self))

	addEventHandler("clientFishHit", root, bind(Fishing.FishHit, self))
	addEventHandler("clientFishCaught", root, bind(Fishing.FishCaught, self))
	addEventHandler("clientRequestFishPricing", root, bind(Fishing.onFishRequestPricing, self))
	addEventHandler("clientRequestFishTrading", root, bind(Fishing.onFishRequestTrading, self))
	addEventHandler("clientSendFishTrading", root, bind(Fishing.clientSendFishTrading, self))
end

function Fishing:destructor()
end

function Fishing:loadFishDatas()
	local readFuncs = {
		["Name_DE"] = function (value) return utf8.escape(value) end,
		["Location"] = function(value) if fromJSON(value) then return fromJSON(value) else return value end end,
		["Times"] = function(value) return fromJSON(value) end,
		["Size"] = function(value) return fromJSON(value) end,
	}

	Fishing.Fish = sql:queryFetch("SELECT * FROM ??_fish_data", sql:getPrefix())

	for i, fish in pairs(Fishing.Fish) do
		for key, value in pairs(fish) do
			if readFuncs[key] then
				Fishing.Fish[i][key] = readFuncs[key](value)
			end
		end
	end
end

function Fishing:getFish(location, timeOfDay, weather)
	local tmp = {}

	for _, v in pairs(Fishing.Fish) do
		local checkLocation = false
		local checkTime = false
		local checkWeather = false

		-- Check Location
		if #v.Location == 2 then
			for key, value in pairs(v.Location) do
				if value == location then
					checkLocation = true
				end
			end
		elseif v.Location == location then
			checkLocation = true
		end

		-- Check time
		if #v.Times == 1 then
			checkTime = true
		else
			for i = 1, #v.Times, 2 do
				if timeOfDay >= v.Times[i] and timeOfDay <= v.Times[i+1] then
					checkTime = true
				end
			end
		end

		-- Check weather
		if v.Weather == 0 then			-- Any
			checkWeather = true
		elseif v.Weather == 1 then		-- Sunny
			if weather ~= 8 then
				checkWeather = true
			end
		elseif v.Weather == 2 then		-- Rainy
			if weather == 8 then
				checkWeather = true
			end
		end

		-- Check all
		if checkLocation and checkTime and checkWeather then
			table.insert(tmp, v)
		end
	end

	return tmp[self.Random:get(1, #tmp)]
end

function Fishing:FishHit(location, castPower)
	if not self.m_Players[client] then return end

	local time = tonumber(("%s%.2d"):format(getRealTime().hour, getRealTime().minute))
	local weather = getWeather()

	local fish = self:getFish(location, time, weather)

	client:triggerEvent("fishingBobberBar", fish)

	self.m_Players[client].lastFish = fish
	self.m_Players[client].location = location
	self.m_Players[client].castPower = castPower
	self.m_Players[client].lastFishHit = getTickCount()
end

function Fishing:FishCaught()
	if not self.m_Players[client] then return end
	local tbl = self.m_Players[client]
	local timeToCatch = getTickCount() - tbl.lastFishHit
	local size = self:getFishSize(client, tbl.lastFish.Id, timeToCatch, tbl.castPower)
	local playerInventory = client:getInventory()
	local allBagsFull = false

	self:updatePlayerSkill(client, size)
	client:addFishSpecies(tbl.lastFish.Id)
	client:increaseStatistics("FishCaught")

	if client:getFishSpeciesCaughtCount() >= 10 then
		client:giveAchievement(93) -- Fischer
	elseif client:getFishSpeciesCaughtCount() >= 24 then
		client:giveAchievement(94) -- Alter Seemann
	elseif client:getFishSpeciesCaughtCount() >= #Fishing.Fish then
		client:giveAchievement(95) -- Angelmeister
	end

	if client:getStatistics("FishCaught") >= 150 then
		client:giveAchievement(96) -- Angelgott
	elseif client:getStatistics("FishCaught") >= 500 then
		client:giveAchievement(97) -- Für Helene Fischer
	end

	for bagName, bagProperties in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local fishId = tbl.lastFish.Id
			local fishName = tbl.lastFish.Name_EN
			local currentValue = playerInventory:getItemValueByBag("Items", place)
			local json = fromJSON(currentValue)
			if json then currentValue = json else currentValue = {} end

			if #currentValue < bagProperties.max then
				table.insert(currentValue, {Id = fishId, fishName = fishName, size = size, quality = self:getFishQuality(fishId, size), timestamp = getRealTime().timestamp})
				playerInventory:setItemValueByBag("Items", place, toJSON(currentValue))

				self:increaseFishCaughtCount(fishId)

				StatisticsLogger:getSingleton():addfishCaughtLogs(client, fishName, size, tbl.location)
				return
			end

			allBagsFull = true
		end
	end

	if allBagsFull then
		client:sendError("Deine Kühltaschen sind voll!")
		return
	end

	client:sendError("Du besitzt keine Kühltaschen, in der du deine Fische lagern kannst!")
end

function Fishing:getFishSize(player, fishId, timeToCatch, castPower)
	local fishSizeReduction = timeToCatch/2500*1
	local minFishSize = Fishing.Fish[fishId].Size[1]
	local maxFishSize = Fishing.Fish[fishId].Size[2]
	local playerLevel = player:getPrivateSync("FishingLevel")

	local num = self.Random:get(1 + math.min(10, playerLevel/2), 6) / 5
	local fishSizeMultiplicator = math.max(0, math.min(1, num*(1 + self.Random:get(-10, 10)/100)))

	local fishSize = math.max(minFishSize, ((minFishSize + (maxFishSize - minFishSize) * fishSizeMultiplicator)-fishSizeReduction)*castPower)

	return math.floor(fishSize)
end

function Fishing:updatePlayerSkill(player, skill)
	player:giveFishingSkill(skill)

	if player:getFishingLevel() < MAX_FISHING_LEVEL then
		if player:getFishingSkill() >= FISHING_LEVELS[player:getFishingLevel() + 1] then
			player:sendInfo("Fischer Level erhöht!")
			player:setFishingLevel(player:getFishingLevel() + 1)
			player:setFishingSkill(player:getFishingSkill() - FISHING_LEVELS[player:getFishingLevel()])
		end
	end
end

function Fishing:increaseFishCaughtCount(fishId)
	Fishing.Fish[fishId].CaughtCount = Fishing.Fish[fishId].CaughtCount + 1
	sql:queryExec("UPDATE ??_fish_data SET CaughtCount = ? WHERE Id = ?", sql:getPrefix(), Fishing.Fish[fishId].CaughtCount, fishId)
end

function Fishing:increaseFishSoldCount(fishId)
	Fishing.Fish[fishId].SoldCount = Fishing.Fish[fishId].SoldCount + 1
	sql:queryExec("UPDATE ??_fish_data SET SoldCount = ? WHERE Id = ?", sql:getPrefix(), Fishing.Fish[fishId].SoldCount, fishId)
end

function Fishing:onFishRequestPricing()
	-- Todo: Only trigger specific datas
	client:triggerEvent("openFishPricingGUI", Fishing.Fish)
end

function Fishing:onFishRequestTrading()
	local fishes = {}
	local playerInventory = client:getInventory()

	for bagName, bagProperties in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local currentValue = playerInventory:getItemValueByBag("Items", place)
			local json = fromJSON(currentValue)
			if json then currentValue = json else currentValue = {} end

			table.insert(fishes, {name = bagName, content = currentValue})
		end
	end

	client:triggerEvent("openFishTradeGUI", fishes, Fishing.Fish)
end

function Fishing:clientSendFishTrading(list)
	local fishingLevel = client:getPrivateSync("FishingLevel")
	local totalPrice = 0

	for _, item in pairs(list) do
		if self:isFishInCoolingBag(item.fishId, item.fishSize) then
			outputChatBox("TRUE")
		end

		--[[if item.fishId then
			local default = Fishing.Fish[item.fishId].DefaultPrice
			local fishingLevelMultiplicator = fishingLevel >= 10 and 1.5 or (fishingLevel >= 5 and 1.25 or 1)
			local qualityMultiplicator = item.fishQuality == 2 and 1.5 or (item.fishQuality == 1 and 1.25 or 1)
			local rareBonusMultiplicator = self.m_FishTable[item.fishId].RareBonus + 1

			totalPrice = totalPrice + default*fishingLevelMultiplicator*qualityMultiplicator*rareBonusMultiplicator
		end]]
	end
end

function Fishing:isFishInCoolingBag(fishId, fishSize)
	local playerInventory = client:getInventory()

	for bagName, bagProperties in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local currentValue = playerInventory:getItemValueByBag("Items", place)
			local json = fromJSON(currentValue)
			if json then currentValue = json else currentValue = {} end

			for _, fish in pairs(currentValue) do
				if fish.Id == fishId and fish.size == fishSize then
					return true
				end
			end
		end
	end
end

function Fishing:getFishQuality(fishId, size)
	local minFishSize = Fishing.Fish[fishId].Size[1]
	local maxFishSize = Fishing.Fish[fishId].Size[2]
	local thirdSpan = (maxFishSize - minFishSize)/3

	if size < minFishSize + thirdSpan then
		return 0
	elseif size > maxFishSize - thirdSpan then
		return 2
	else
		return 1
	end
end

function Fishing:updatePricing()
	-- Create a sort table, otherwise we get trouble with Fish Ids
	local sortTable = {}
	for _, fish in pairs(Fishing.Fish) do
		table.insert(sortTable, fish.SoldCount)
	end

	-- Calculate fish price depending by sold count
	table.sort(sortTable)

	-- Define price by the ratio with the average sold fish
	local averageSoldFish = sortTable[math.floor(#sortTable/3)]

	for _, fish in pairs(Fishing.Fish) do
		fish.RareBonus = math.max(1 - (fish.SoldCount)/(averageSoldFish + 1), 0)
	end
end

function Fishing:inventoryUse(player)
	if self.m_Players[player] then
		local fishingRod = self.m_Players[player].fishingRod
		if fishingRod then fishingRod:destroy() end
		self.m_Players[player] = nil

		player:triggerEvent("onFishingStop")
		return
	end

	local fishingRod = createObject(1826, player.position)
	exports.bone_attach:attachElementToBone(fishingRod, player, 12, -0.03, 0.02, 0.05, 180, 120, 0)

	self.m_Players[player] = {
		fishingRod = fishingRod,
	}

	player:triggerEvent("onFishingStart", fishingRod)
end
