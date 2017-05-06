-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Fishing.lua
-- *  PURPOSE:     Serverside Fishing Class
-- *
-- ****************************************************************************
Fishing = inherit(Singleton)
addRemoteEvents{"clientFishHit", "clientFishCaught", "clientRequestFishPricing"}

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

function Fishing:FishHit(location)
	if not self.m_Players[client] then return end

	local time = tonumber(("%s%.2d"):format(getRealTime().hour, getRealTime().minute))
	local weather = getWeather()

	local fish = self:getFish(location, time, weather)

	client:triggerEvent("fishingBobberBar", fish)

	self.m_Players[client].lastFish = fish
	self.m_Players[client].location = location
	self.m_Players[client].lastFishHit = getTickCount()
end

function Fishing:FishCaught()
	if not self.m_Players[client] then return end
	local tbl = self.m_Players[client]
	local size = math.random(tbl.lastFish.Size[1], tbl.lastFish.Size[2]) -- todo (calc size by rod power // fisher level // time to caught)
	--outputChatBox(("Caught: %s [%s] // Size: %s"):format(tbl.lastFish.name, getTickCount() - tbl.lastFishHit, size))
	local playerInventory = client:getInventory()
	local allBagsFull = false

	self:updatePlayerSkill(client, size)

	for bagName, bagProperties in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local fishId = tbl.lastFish.Id
			local fishName = tbl.lastFish.Name_EN
			local currentValue = playerInventory:getItemValueByBag("Items", place)
			if fromJSON(currentValue) then currentValue = fromJSON(currentValue) else currentValue = {} end

			if #currentValue < bagProperties.max then
				sql:queryExec("INSERT INTO ??_fish_caught (PlayerId, Fish, Size, Location, Time) VALUES (?, ?, ?, ?, NOW())", sql:getPrefix(), client:getId(), fishName, size, ("%s - %s"):format(tbl.location, getZoneName(client.position)))

				table.insert(currentValue, {Id = fishId, fishName = fishName, size = size, timestamp = getRealTime().timestamp})
				playerInventory:setItemValueByBag("Items", place, toJSON(currentValue))

				self:increaseFishCaughtCount(fishId)
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

function Fishing:updatePlayerSkill(player, skill)
	player:giveFishingSkill(skill)

	if player:getFishingLevel() < MAX_FISHING_LEVEL then
		if player:getFishingSkill() >= FISHING_LEVELS[player:getFishingLevel() + 1] then
			player:sendInfo("Angel Level erhöht!")
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

function Fishing:updatePricing()
	-- Calculate fish price depending by sold count
	table.sort(Fishing.Fish, function(a, b) return a.SoldCount < b.SoldCount end)

	-- Define price by the ratio with the average sold fish
	local averageSoldFish = Fishing.Fish[math.floor(#Fishing.Fish/3)]

	for _, fish in ipairs(Fishing.Fish) do
		fish.PriceBonus = math.max(1 - (fish.SoldCount)/(averageSoldFish.SoldCount + 1), 0)
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
