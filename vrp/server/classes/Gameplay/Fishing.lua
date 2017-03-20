-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Fishing.lua
-- *  PURPOSE:     Serverside Fishing Class
-- *
-- ****************************************************************************
Fishing = inherit(Singleton)

-- Weather: 0 = any, 1 = sunny, 2 = rain
Fishing.Fish = {
	{name = "Albacory", de = "weißer Thun", location = "ocean", difficulty = 60, behavior = "mixed", weather = 0, times = {600, 1100, 1800, 2400}, size = {50, 104}},
	{name = "Anchovy", de = "Sardelle", location = "ocean", difficulty = 30, behavior = "dart", weather = 0, times = {0}, size = {2.5, 43}, },
	{name = "Bream", de = "Brachse", location = "river", difficulty = 35, behavior = "smooth", weather = 0, times = {0, 200, 1800, 2400}, size = {30, 78}},
	{name = "Bullhead", de = "Katzenwels", location = "lake", difficulty = 46, behavior = "smooth", weather = 0, times = {0}, size = {30, 78}},
	{name = "Carp", de = "Karpfen", location = "lake", difficulty = 15, behavior = "mixed", weather = 0, times = {0}, size = {38, 130}},
	{name = "Catfish", de = "Seewolf", location = "river", difficulty = 75, behavior = "mixed", weather = 2, times = {0}, size = {30, 185}},
	{name = "Chub", de = "Kaulbarsch", location = {"river", "lake"}, difficulty = 35, behavior = "dart", weather = 0, times = {0}, size = {30, 64}},
	{name = "Dorado", de = "Schwertfisch", location = "river", difficulty = 78, behavior = "mixed", weather = 0, times = {600, 1900}, size = {30, 84}},
	{name = "Eel", de = "Aal", location = "ocean", difficulty = 70, behavior = "smooth", weather = 2, times = {0, 200, 1600, 2400}, size = {30, 205}},
	{name = "Halibut", de = "Heilbutt", location = "ocean", difficulty = 50, behavior = "sinker", weather = 0, times = {0, 200, 600, 1100, 1900, 2400}, size = {25, 86}},
	{name = "Herring", de = "Hering", location = "ocean", difficulty = 25, behavior = "dart", weather = 0, times = {0}, size = {20, 53}},
	{name = "Largemouth Bass", de = "Forellenbarsch", location = "lake", difficulty = 50, behavior = "mixed", weather = 0, times = {600, 1900}, size = {28, 78}},
	{name = "Lingcod", de = "Lengdirsch", location = {"river", "lake"}, difficulty = 85, behavior = "mixed", weather = 0, times = {0}, size = {76, 130}},
	{name = "Octopus", de = "Tintenfisch", location = "ocean", difficulty = 95, behavior = "sinker", weather = 0, times = {600, 1300}, size = {30, 122}},
	{name = "Perch", de = "Barsch", location = {"river", "lake"}, difficulty = 35, behavior = "mixed", weather = 0, times = {0}, size = {25, 63}},
	{name = "Pike", de = "Hecht", location = "river", difficulty = 60, behavior = "dart", weather = 0, times = {0}, size = {38, 155}},
	{name = "Pufferfish", de = "Kugelfische", location = "ocean", difficulty = 80, behavior = "floater", weather = 1, times = {1200, 1600}, size = {2.5, 94}},
	{name = "Rainbow Trout", de = "Regenbogenforelle", location = "river", difficulty = 45, behavior = "mixed", weather = 1, times = {600, 1900}, size = {25, 66}},
	{name = "Red Mullet", de = "Rote Meerbarbe", location = "ocean", difficulty = 55, behavior = "smooth", weather = 0, times = {600, 1900}, size = {25, 58}},
	{name = "Red Snapper", de = "Roter Schnapper", location = "ocean", difficulty = 40, behavior = "mixed", weather = 2, times = {600, 1900}, size = {20, 66}},
	{name = "Salmon", de = "Lachse", location = "river", difficulty = 50, behavior = "mixed", weather = 0, times = {600, 1900}, size = {61, 167}},
	{name = "Sandfish", de = "Sandfisch", location = "desert", difficulty = 65, behavior = "mixed", weather = 0, times = {600, 2200}, size = {20, 61}},
	{name = "Sardine", de = "Sardine", location = "ocean", difficulty = 30, behavior = "dart", weather = 0, times = {600, 1900}, size = {2.5, 33}},
	{name = "Sea Cucumber", de = "Seegurke", location = "ocean", difficulty = 40, behavior = "sinker", weather = 0, times = {600, 1900}, size = {8, 53}},
	{name = "Shad", de = "Alosa sapidissima", location = "river", difficulty = 45, behavior = "smooth", weather = 2, times = {0, 200, 900, 2400}, size = {50, 125}},
	{name = "Smallmouth Bass", de = "Schwarzbarsch", location = "river", difficulty = 28, behavior = "mixed", weather = 0, times = {0}, size = {30, 63}},
	{name = "Squid", de = "Kalmar", location = "ocean", difficulty = 75, behavior = "sinker", weather = 0, times = {0, 200, 1800, 2400}, size = {30, 124}},
	{name = "Stonefish", de = "Steinfisch", location = "ocean", difficulty = 65, behavior = "sinker", weather = 2, times = {0}, size = {35, 40}},
	{name = "Sturgeon", de = "Stör", location = "lake", difficulty = 78, behavior = "mixed", weather = 0, times = {600, 1900}, size = {30, 155}},
	{name = "Sunfish", de = "Mondfisch", location = "river", difficulty = 30, behavior = "mixed", weather = 1, times = {600, 1900}, size = {13, 40}},
	{name = "Super Cucumber", de = "Super Seegurke", location = "ocean", difficulty = 85, behavior = "sinker", weather = 0, times = {0, 200, 1800, 2400}, size = {30, 94}},
	{name = "Tiger Trout", de = "Tigerforelle", location = "river", difficulty = 60, behavior = "dart", weather = 0, times = {600, 1900}, size = {25, 53}},
	{name = "Tilapia", de = "Tilapia", location = "ocean", difficulty = 50, behavior = "mixed", weather = 0, times = {600, 1400}, size = {28, 78}},
	{name = "Tuna", de = "Thunfisch", location = "ocean", difficulty = 70, behavior = "smooth", weather = 0, times = {600, 1900}, size = {58, 155}},
	{name = "Walleye", de = "Glasaugenbarsch", location = {"river", "lake"}, difficulty = 45, behavior = "smooth", weather = 0, times = {0, 200, 1200, 2400}, size = {25, 104}},
}

addRemoteEvents{"clientFishHit", "clientFishCaught", "fishingPedClick"}

function Fishing:constructor()
	self.Random = Randomizer:new()
	self.m_Players = {}

	addEventHandler("clientFishHit", root, bind(Fishing.FishHit, self))
	addEventHandler("clientFishCaught", root, bind(Fishing.FishCaught, self))
	addEventHandler("fishingPedClick", root, bind(Fishing.onPedClick, self))
end

function Fishing:destructor()
end

function Fishing:getFish(location, timeOfDay, weather)
	local tmp = {}

	for k, v in pairs(Fishing.Fish) do
		local checkLocation = false
		local checkTime = false
		local checkWeather = false

		-- Check Location
		if #v.location == 2 then
			for key, value in pairs(v.location) do
				if value == location then
					checkLocation = true
				end
			end
		elseif v.location == location then
			checkLocation = true
		end

		-- Check time
		if #v.times == 1 then
			checkTime = true
		else
			for i = 1, #v.times, 2 do
				if timeOfDay >= v.times[i] and timeOfDay <= v.times[i+1] then
					checkTime = true
				end
			end
		end

		-- Check weather
		if v.weather == 0 then			-- Any
			checkWeather = true
		elseif v.weather == 1 then		-- Sunny
			if weather ~= 8 then
				checkWeather = true
			end
		elseif v.weather == 2 then		-- Rainy
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
	local time = tonumber(("%s%.2d"):format(getRealTime().hour, getRealTime().minute))
	local weather = getWeather()

	local fish = self:getFish(location, time, weather)

	client:triggerEvent("fishingBobberBar", fish)

	self.m_Players[client] = {
		lastFish = fish,
		lastFishHit = getTickCount(),
		caught = {}
	}
end

function Fishing:FishCaught()
	if not self.m_Players[client] then return end
	local tbl = self.m_Players[client]

	outputChatBox(("Caught: %s [%s]"):format(tbl.lastFish.name, getTickCount() - tbl.lastFishHit))
	table.insert(tbl.caught, tbl.lastFish)
end

function Fishing:onPedClick()

end
