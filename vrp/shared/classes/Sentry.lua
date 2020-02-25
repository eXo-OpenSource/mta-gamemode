Sentry = inherit(Singleton)

function Sentry:constructor()
	self.m_DSN = "https://3ae511c975bd4531a3a37703e368cde9@sentry.exo.merx.dev/5"

	self:parseDSN()
end

function Sentry:parseDSN()
	local protocol, publicKey, host, path, projectId = string.match(self.m_DSN, "^([^:]+)://([^:]+)@([^/]+)(.*/)(.+)$")
	self.m_PublicKey = publicKey
	self.m_Host = host
	self.m_ProjectId = projectId
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

		local filename = v[1]:gsub("@", "") -- remove this for testing
		filename = filename:gsub("%[vrp%]\\", "")
		filename = filename:gsub("%[vrp%]/", "")

		local frame = {
			filename = filename,
			abs_path = ("https://git.heisi.at/eXo/mta-gamemode/tree/%s/%s"):format(GIT_BRANCH or "master", filename),
			["function"] = v[3]
		}

		if type(v[2]) == "number" then
			frame["lineno"] = v[2]
			frame["abs_path"] = ("https://git.heisi.at/eXo/mta-gamemode/tree/%s/%s#L%d"):format(GIT_BRANCH or "master", filename, v[2])
		end

		table.insert(frames, frame)
	end

	local data = {
		event_id = eventId,
		timestamp = getRealTime().timestamp,
		platform = "lua",
		logger = "mta-logger",
		level = level,
		environment = GIT_BRANCH and GIT_BRANCH:gsub("/", "-") or "local",
		release = GIT_VERSION,
		tags = {
			side = triggerServerEvent and "client" or "server"
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
	}

	if not triggerServerEvent then
		data["breadcrumbs"] = {
			values = {

			}
		}

		local queries = {}

		for id = #SQL.LastExecQuery, 1, -1 do
			table.insert(queries, SQL.LastExecQuery[id])

		end

		for id = #SQL.LastFetchQuery, 1, -1 do
			table.insert(queries, SQL.LastFetchQuery[id])
		end
		for k,v in spairs(queries, function(t,a,b) return t[b].timestamp > t[a].timestamp end) do
			table.insert(data.breadcrumbs.values, {
				category = "sql." .. v.type,
				level = "info",
				timestamp = v.timestamp,
				message = v.query,
				data = {
					bindings = v.args,
					connectionName = v.prefix
				}
			})
		end

	end

	data = toJSON(data, true)
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
        "Sentry sentry_version=7, sentry_client=%s, sentry_timestamp=%s, sentry_key=%s",
        "lua/" .. _VERSION,
        getRealTime().timestamp,
        self.m_PublicKey)
end
