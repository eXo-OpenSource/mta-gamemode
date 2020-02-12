Sentry = inherit(Singleton)

function Sentry:constructor()
	self.m_DSN = "https://3ae511c975bd4531a3a37703e368cde9:2ed5a472965c4fc18817bdf640f86af5@sentry.exo.merx.dev/5"

	self:parseDSN()
end

function Sentry:parseDSN()
	local protocol, public_key, secret_key, long_host, path, project_id = string.match(self.m_DSN, "^([^:]+)://([^:]+):([^@]+)@([^/]+)(.*/)(.+)$")
	self.m_PublicKey = public_key
	self.m_SecretKey = secret_key
	self.m_Host = long_host
	self.m_ProjectId = project_id
	-- iprint({protocol, public_key, secret_key, long_host, path, project_id})
end

function Sentry:handleException(message, level, trace)
	--[[
		level enum [fatal, error, warning, info, debug]
	]]
	local eventId = self:generateEventId()
	-- info.source, info.name, info.currentline or "not specified"
	local frames = {}
	for id = #trace, 1, -1 do
		local v = trace[id]

		local pos = lastIndexOf(v[1], "\\") or lastIndexOf(v[1], "/") or 1
		local length = #v[1]
		local filename = v[1]:sub(pos + 1, length)
		local frame = {
			filename = filename,
			abs_path = v[1],
			["function"] = v[3]
		}

		if type(v[2]) == "number" then
			frame["lineno"] = v[2]
		end

		table.insert(frames, frame)
	end

	local data = toJSON({
		event_id = eventId,
		timestamp = getRealTime().timestamp,
		platform = "lua",
		logger = "mta-logger",
		level = level,
		environment = GIT_BRANCH,
		release = GIT_VERSION,
		tags = {
			type = triggerServerEvent and "client" or "server"
		},
		exception = {
			values = {
				{
					value = message,
					stacktrace = {
						frames = frames
					}
				}
			}
		}
	}, true)
	data = data:sub(2, #data-1)

	local options = {
		method = "POST",
		headers = {
            ['X-Sentry-Auth'] = self:generateAuthHeader()
		},
		postData = data
	}

	fetchRemote("https://" .. self.m_Host .. "/api/" .. self.m_ProjectId .. "/store/", options, function() end)
end

function Sentry:generateEventId()
	return string.format("%07x%07x%07x%07x%04x",
		math.random(0, 0xfffffff), math.random(0, 0xfffffff),
		math.random(0, 0xfffffff), math.random(0, 0xfffffff),
		math.random(0, 0xffff))
end

function Sentry:generateAuthHeader()
    return string.format(
        "Sentry sentry_version=7, sentry_client=%s, sentry_timestamp=%s, sentry_key=%s, sentry_secret=%s",
        "lua/" .. _VERSION,
        getRealTime().timestamp,
        self.m_PublicKey,
        self.m_SecretKey)
end
