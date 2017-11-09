TSConnect = inherit(Singleton)

function TSConnect:constructor()
	self.m_APIUrl = "https://exo-reallife.de/ingame/TSConnect/ts_connect.php"
	self.m_Secret = "8H041OAyGYk8wEpIa1Fv"
end

function TSConnect:destructor()
end

function TSConnect:callAPI(player, method, arg, callback)
	if not player or not isElement(player) then
		return false
	end

	local options = {
		["postData"] =  ("secret=%s&playerId=%d&method=%s&arg=%s"):format(self.m_Secret, player:getId(), method, arg or "")
	}
	outputChatBox(options["postData"])
	fetchRemote(self.m_APIUrl, options,
		function(rawResponseData, responseInfo)
			--outputConsole(inspect({data = responseData, info = responseInfo}))
			if responseInfo["success"] == true then
				local responseData = fromJSON(rawResponseData)
				if not responseData or responseData["error"] then
					outputDebugString(("TSConnect PHP-Error: %s"):format(responseData and responseData["error"] or "no responseData"), 1)
				elseif responseData["response"] and responseData["player"] then
					local responsePlayer = PlayerManager:getSingleton():getPlayerFromId(responseData["player"])
					if responsePlayer and isElement(responsePlayer) then
						responsePlayer:sendShortMessage(responseData["response"], "Teamspeak", {66, 94, 128})
					end
				end
				if callback then
					callback(responseData)
				end
			else
				outputDebugString(("TSConnect Fetch-Error: %s"):format(responseInfo["statusCode"]), 1)
			end
		end
	)
end

function TSConnect:asyncCallAPI(...)
	local status = self:callAPI(Async.waitFor(), ...)
	return status, Async.wait()
end
