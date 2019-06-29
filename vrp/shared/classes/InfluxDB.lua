-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/InfluxDB.lua
-- *  PURPOSE:     InfluxDB class
-- *
-- ****************************************************************************
InfluxDB = inherit(Object)

function InfluxDB:constructor(username, password, database)
    self.m_Username = username
    self.m_Password = password
    self.m_Database = database
	self.m_Host = "https://influxdb.merx.dev"
	self.m_DomainNotBlocked = not isBrowserDomainBlocked or not isBrowserDomainBlocked(self.m_Host, true)
	self.m_Enabled = not not GIT_BRANCH

	self.m_Branch = GIT_BRANCH or "dev"

	self.m_Data = {}


	if self.m_Enabled then
		self.m_TimedPulse = TimedPulse:new(20 * 1000) -- every 20 seconds
		self.m_TimedPulse:registerHandler(bind(self.flush, self))
	end
end

function InfluxDB:destructor()
	if not self.m_TimedPulse then
		delete(self.m_TimedPulse)
	end
end

function InfluxDB:write(measurement, tags, data, time)
	if not self.m_Enabled then return end
	local timestamp = nil

	if time then
		timestmap = time .. "000000000"
	else
		timestamp = getRealTime().timestamp .. "000000000"
	end


	if table.size(data) == 0 then
		return false
	end

	local tagsStr = ",branch=" .. tostring(self.m_Branch)

	if tags then
		for k, v in pairs(tags) do
			local v = v or "-"
			local value = tostring(v):gsub(",", ";")

			tagsStr = tagsStr .. "," .. tostring(k) .. "=" .. value
		end
	end

	local dataStr = ""

	for k, v in pairs(data) do
		local v = v or "-"
		if dataStr ~= "" then dataStr = dataStr .. "," end
		local value = ""

		if type(v) == "string" then
			value = "\"" .. v:gsub("\"", "'") .. "\""
		else
			value = tostring(v):gsub(",", ";")
		end

		dataStr = dataStr .. tostring(k) .. "=" .. value
	end

	table.insert(self.m_Data, measurement .. tagsStr .. " " .. dataStr .. " " .. timestamp)
end

function InfluxDB:flush()
	if #self.m_Data == 0 then return end

	if not self.m_DomainNotBlocked then
		self.m_DomainNotBlocked = not isBrowserDomainBlocked(self.m_Host, true)
		return
	end

	local data = ""

	for k, v in pairs(self.m_Data) do
		if data ~= "" then data = data .. "\n" end
		data = data .. v
	end
	self.m_Data = {}

	fetchRemote(self.m_Host .. "/write?db=" .. self.m_Database, {
		["method"] = "POST",
		["username"] = self.m_Username,
		["password"] = self.m_Password,
		["postData"] = data
	}, function(response) if triggerServerEvent then outputDebugString(response) end end)
end
