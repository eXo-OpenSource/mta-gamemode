SlackErrorLogger = inherit(Singleton)

function SlackErrorLogger:constructor()
	self.m_ErrorStack = {}
	addEventHandler("onDebugMessage", root, bind(self.check, self))
end

function SlackErrorLogger:destructor()
	self:sendStackedMessages()
end

function SlackErrorLogger:check(msg, level, file, line)
	if GIT_BRANCH == "release/production" then
		if level == 2 or level == 1 then
			local json = toJSON({
				color = ("%s"):format(level == 2 and "ffcc00" or "ff0000"),
				pretext = ("%s occured on mta.exo-reallife.de:%d"):format(level == 2 and "Warning" or "Error", getServerPort()),
				fields = {
					{
						title = ("Source"):format(level == 2 and "Warning" or "Error"),
						value = ("%s:%d"):format(file, line),
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

			local hash = hash("md5", json)
			if not self.m_ErrorStack[hash] then
				self.m_ErrorStack[hash] = {count = 1, json = json, lastOccured = getTickCount()}
			else
				local currStackElement = self.m_ErrorStack[hash]
				if (getTickCount() - currStackElement.lastOccured) < 500 then
					currStackElement.lastOccured = getTickCount()
					currStackElement.count = currStackElement.count + 1

					if currStackElement.timer and isTimer(currStackElement) then
						resetTimer(currStackElement.timer)
						return
					end
				end
			end

			self.m_ErrorStack[hash].timer = setTimer(bind(self.sendMessage, self, json), 550, 1)
		end
	end
end

function SlackErrorLogger:sendMessage(json)
	if json then
		local url = ('https://exo-reallife.de/slack.php')
		--outputConsole(url)
		local status = callRemote(url, function (...)
			--[[
			outputDebugString("[Error-Listener] Showing debug infos", 3)
			local args = {...}
			outputDebugString(("[Error-Listener] Got %d strings response from the server.."):format(#args), 3)
			for i, v in pairs(args) do
				if type(v) == "table" then
					outputConsole(toJSON(v))
				else
					outputConsole(v)
				end
			end
			outputDebugString("[Error-Listener] End of debug infos", 3)
			--]]
		end, json)

		if status then
			outputDebugString("[Error-Listener] Reported Error to Slack!", 3)
		else
			outputDebugString("[Error-Listener] Reporting Error to Slack failed!", 3)
		end
	end
end

function SlackErrorLogger:sendStackedMessages()
	for hash, data in pairs(self.m_ErrorStack) do
		self:sendMessage(data.json)
	end
end
