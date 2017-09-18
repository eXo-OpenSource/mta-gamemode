Main = {}

function Main.resourceStart()
	-- Stop useless Resources
	for i, v in pairs(RESOURCES_TO_STOP) do
		local resource = Resource.getFromName(v)
		if resource and resource:getState() == "running" then
			resource:stop()
		end
	end

	-- Instantiate Core
	core = Core:new()
end
addEventHandler("onResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.preResourceStop()
	-- Call stop hook
	core:getStopHook():call()
end
addEventHandler("onResourceStop", resourceRoot, Main.preResourceStop, true, "high+99999")

function Main.resourceStop()
	delete(core)
end
addEventHandler("onResourceStop", resourceRoot, Main.resourceStop, true, "low-99999")

-- Slack Error logger (for release/production branch)
local function sendSlackMessage(msg, level, stackTrace)
	if level == 2 or level == 1 then

		local formattedStackTrace = ""
		for id = #stackTrace, 1, -1 do
			local data = stackTrace[id]
			data[1] = data[1]:gsub("@", "") -- for some reason msgs start with an @ which we don't need
			formattedStackTrace = 
			formattedStackTrace .. ("<https://git.heisi.at/eXo/mta-gamemode/tree/%s/%s#L%d|%s:%d>\n"):format(GIT_BRANCH or "master", data[1], data[2], data[1], data[2])
		end
		local json = toJSON({
			color = ("%s"):format(level == 2 and "ffcc00" or "ff0000"),
			pretext = ("%s %s"):format(level == 2 and ":warning:" or ":no_entry_sign:", msg),
			fields = {
				{
					title = "StackTrace",
					value = formattedStackTrace,
					short = false
				},
			},
		}, true)
		json = json:sub(2, #json-1)

		local status = callRemote('https://exo-reallife.de/slack.php', function (...) end, json)
		if status then
			outputDebugString("[Error-Listener] Reported Error to Slack!", 3)
		else
			outputDebugString("[Error-Listener] Reporting Error to Slack failed!", 3)
		end
	end
end

local STACK_TIMING = 300000
local slackMessages = {}
local function stackSlackMessages(msg, level, stackTrace)
	local index = ("%s%s%s"):format(msg, level, toJSON(stackTrace))

	if not slackMessages[index] then
		slackMessages[index] = {
			msg = msg,
			level = level,
			duplicates = 1,
			stackTrace = stackTrace,
		}

		sendSlackMessage(msg, level, stackTrace)

		setTimer(
			function(index)
				if slackMessages[index].duplicates > 1 then
					local msg = ("%s [DUP x%s]"):format(slackMessages[index].msg, slackMessages[index].duplicates)
					sendSlackMessage(msg, slackMessages[index].level, slackMessages[index].stackTrace)
				end

				slackMessages[index] = nil
			end, STACK_TIMING, 1, index
		)
	else
		slackMessages[index].duplicates = slackMessages[index].duplicates + 1
	end
end

addEventHandler("onDebugMessage", root,
	function(msg, level, file, line)
		if GIT_BRANCH == "release/production" and level <= 2 then
			-- get trace back of type {filepath, line} (adapted from traceback())
			local trace = {}
			local traceLevel = 2
			table.insert(trace, {file, line or "not specified"})
			while true do
				local info = debug.getinfo(traceLevel, "Sl")
				if not info then break end
				if info.what ~= "C" and info.source then -- skip c functions as they don't have info
					if info.source:find("tail call") then break end -- break if the stack is in a loop
					if not info.source:find("classlib.lua") then -- skip classlib traceback (e.g. pre-calling destructor) as it is useless for debugging
						if trace[1][1] ~= info.source:gsub("@", "") then -- for some reason messages get duplicated, but we need to collect the message from file, line as it skips it sometimes in traceback
							table.insert(trace, {info.source, info.currentline or "not specified"})
						end
					end
				end
				traceLevel = traceLevel + 1
			end

			stackSlackMessages(msg, level, trace)
		end
	end
)
