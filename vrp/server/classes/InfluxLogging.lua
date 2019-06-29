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
end
