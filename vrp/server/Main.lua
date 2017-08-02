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
local function sendSlackMessage(msg, level, file, line)
	if level == 2 or level == 1 then
		local json = toJSON({
			color = ("%s"):format(level == 2 and "ffcc00" or "ff0000"),
			pretext = ("%s occured on mta.exo-reallife.de:%d"):format(level == 2 and "Warning" or "Error", getServerPort()),
			fields = {
				{
					title = "Source",
					value = ("<https://git.heisi.at/eXo/mta-gamemode/tree/%s/%s#L%d|%s:%d>"):format(GIT_BRANCH, file, line, file, line),
					short = false
				},
				{
					title = "Message",
					value = msg,
					short = false
				}
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
local function stackSlackMessages(msg, level, file, line)
	local index = ("%s%s%s%s"):format(msg, level, file or "", line or "")

	if not slackMessages[index] then
		slackMessages[index] = {
			msg = msg,
			level = level,
			file = file,
			line = line,
			duplicates = 1,
		}

		sendSlackMessage(msg, level, file or "", line or 0)

		setTimer(
			function(index)
				if slackMessages[index].duplicates > 1 then
					local msg = ("%s [DUP x%s]"):format(slackMessages[index].msg, slackMessages[index].duplicates)
					sendSlackMessage(msg, slackMessages[index].level, slackMessages[index].file or "", slackMessages[index].line or 0)
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
		if GIT_BRANCH == "release/production" then
			stackSlackMessages(msg, level, file, line)
		end
	end
)
