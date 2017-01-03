Main = {}

function Main.resourceStart()
	-- Stop useless Resources
	for i, v in pairs(RESOURCES_TO_STOP) do
		local resource = Resource.getFromName(v)
		if resource then
			resource:stop()
		end
	end

	-- Instantiate Core
	core = Core:new()
end
addEventHandler("onResourceStart", resourceRoot, Main.resourceStart, true, "high+99999")

function Main.resourceStop()
	delete(core)
end
addEventHandler("onResourceStop", resourceRoot, Main.resourceStop, true, "low-99999")

-- Slack Error logger (for release/production branch)
addEventHandler("onDebugMessage", root,
	function (msg, level, file, line)
		if GIT_BRANCH == "release/production" then
			if level == ERROR_LEVEL.Warning or level == ERROR_LEVEL.Error then
				local json = toJSON({
					color = ("%s"):format(level == ERROR_LEVEL.Warning and "ffcc00" or "ff0000"),
					pretext = ("%s occured on mta.exo-reallife.de:%d"):format(level == ERROR_LEVEL.Warning and "Warning" or "Error", getServerPort()),
					fields = {
						{
							title = ("Source"):format(level == ERROR_LEVEL.Warning and "Warning" or "Error"),
							value = ("%s:%d"):format(file, line),
							short = false
						},
						{
							title = "Message",
							value = msg,
							short = false
						}
					},
				})
				json = json:sub(3, #json-2)

				local url = ('https://exo-reallife.de/slack.php?json=%s'):format(json)
				local status = fetchRemote(url, function () end)
				if status then
					outputDebugString("[Error-Listener] Reported Error to Slack!", 3)
				end
			end
		end
	end
)
