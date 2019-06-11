-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InfluxDB.lua
-- *  PURPOSE:     InfluxDB class
-- *
-- ****************************************************************************
InfluxLogging = inherit(Singleton)

function InfluxLogging:constructor()
    self.m_PlayerTimer = setTimer(bind(self.writePlayerCount, self), 10 * 60 * 1000, 0)
    self.m_PerformanceTimer = setTimer(bind(self.writePerformance, self), 60 * 1000, 0)
end

function InfluxLogging:destructor()
    killTimer(self.m_PlayerTimer)
    killTimer(self.m_PerformanceTimer)
end

function InfluxLogging:writePlayerCount()
    InfluxDB:getSingleton():write("user_count", getPlayerCount())
end

function InfluxLogging:writePerformance()
    local _, rows = getPerformanceStats("Lua timing", "d")
    for _, v in pairs(rows) do
        if v[1] then
            if v[2] ~= "-" then
                local name = v[1] or "unknown"
                local time = v[3] or 0
                local calls = v[4] or 0

                InfluxDB:getSingleton():write("performance", v[2]:sub(0, -2), {["name"] = name, ["cpuTime"] = time, ["calls"] = calls})
            end
        end
    end
end