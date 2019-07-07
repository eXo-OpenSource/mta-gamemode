-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InfluxDB.lua
-- *  PURPOSE:     InfluxDB class
-- *
-- ****************************************************************************
InfluxLogging = inherit(Singleton)

function InfluxLogging:constructor()
	self.m_TimedPulse = TimedPulse:new(30 * 1000)
	self.m_TimedPulse:registerHandler(bind(self.writePlayerCount, self))
	self.m_TimedPulse:registerHandler(bind(self.writePerformance, self))
end

function InfluxLogging:destructor()
	delete(self.m_TimedPulse)
end

function InfluxLogging:writePlayerCount()
	for k, v in pairs(FactionManager.Map) do
		local total = #v:getOnlinePlayers(false, false)
		local afk = total - #v:getOnlinePlayers(true, false)
		local duty = #v:getOnlinePlayers(false, true)

		influxPlayer:write("user_faction", {["name"] = v.m_Name}, {["total"] = total, ["afk"] = afk, ["duty"] = duty})
	end

	for k, v in pairs(CompanyManager.Map) do
		local total = #v:getOnlinePlayers(false, false)
		local afk = total - #v:getOnlinePlayers(true, false)
		local duty = #v:getOnlinePlayers(false, true)

		influxPlayer:write("user_company", {["name"] = v.m_Name}, {["total"] = total, ["afk"] = afk, ["duty"] = duty})
	end
	local players = getElementsByType("player")
	local loggedIn = 0
	local afk = 0

	for k, v in pairs(players) do
		if v and isElement(v) and v:isLoggedIn() then
			loggedIn = loggedIn + 1
			if v.m_isAFK then
				afk = afk + 1
			end
		end
	end

    influxPlayer:write("user_total", nil, {["total"] = #players, ["loggedIn"] = loggedIn, ["afk"] = afk})
end

function InfluxLogging:writePerformance()
	local _, rows = getPerformanceStats("Lua timing", "d")
	local resource = "unknown"
    for _, v in pairs(rows) do
        if v[1] then
            if v[2] ~= "-" then
                local name = v[1] or "unknown"
                local time = v[3] or 0
				local calls = v[4] or 0

				if name:sub(0, 1) ~= "." then
					resource = name
				else
					if name ~= "unknown" then name = name:sub(#name * -1 + 1) end
					influx:write("performance", {["name"] = name, ["resource"] = resource}, {["cpuTime"] = time, ["calls"] = calls, ["cpuUsage"] = tonumber(v[2]:sub(0, -2))})
				end
            end
        end
	end


	local _, rows = getPerformanceStats("Server info")
	local fps = split(rows[1][4], " ")

	local syncFps = tonumber(fps[1])
	local serverFps = tonumber(fps[2]:sub(2, -2))
	local packetsIn = tonumber(rows[5][4])
	local packetsOut = tonumber(rows[6][4])
	local packetLossOut = tonumber(rows[7][4]:sub(0, -3))

	local cpuLogic = tonumber(rows[6][2]:sub(0, 4))
	local cpuSync = tonumber(rows[7][2]:sub(0, 4))
	local cpuRaknet = tonumber(rows[8][2]:sub(0, 4))

	influx:write("server", nil, {
		["cpuLogic"] = cpuLogic,
		["cpuSync"] = cpuSync,
		["cpuRaknet"] = cpuRaknet,

		["syncFps"] = syncFps,
		["serverFps"] = serverFps,
		["packetsIn"] = packetsIn,
		["packetsOut"] = packetsOut,
		["packetLossOut"] = packetLossOut
	})

	local _, rows = getPerformanceStats("Server timing")
	local parent = "unknown"
    for _, v in pairs(rows) do
        if v[1] then
            if v[2] ~= "-" then
				local name = v[1] or "unknown"


				if name:sub(0, 1) ~= "." then
					parent = name
				else
					if name ~= "unknown" then name = name:sub(#name * -1 + 1) end

					local lastFrameCalls = tonumber(v[2])
					local lastFrameCpu = tonumber(v[3]:sub(0, -4))
					local lastFrameCpuPeak = tonumber(v[4]:sub(0, -4))

					local lastTwoSecCalls = v[5]
					local lastTwoSecCpu = tonumber(v[6]:sub(0, -4))

					influx:write("server_timing", {["name"] = name, ["parent"] = parent}, {
						["lastFrameCalls"] = lastFrameCalls,
						["lastFrameCpu"] = lastFrameCpu,
						["lastFrameCpuPeak"] = lastFrameCpuPeak,
						["lastTwoSecCalls"] = lastTwoSecCalls,
						["lastTwoSecCpu"] = lastTwoSecCpu
					})
				end
            end
        end
    end
end
