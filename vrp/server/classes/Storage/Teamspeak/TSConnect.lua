TSConnect = inherit(Singleton)

--[[
	API Doc:
	tsMessageToClient(msg)
	tsPoke(msg)
	tsMoveClient(channelName or channelId)
	tsAddServergroup(groupName or groupId)
	tsRemoveServergroup(groupName or groupId)
]]

function TSConnect:constructor()
	self.m_APIUrl = "https://exo-reallife.de/ingame/TSConnect/ts_connect.php"
	self.m_Secret = "8H041OAyGYk8wEpIa1Fv"

	self.m_MoveRequests = {}

	self.m_SMTitle = "Teamspeak"
	self.m_SMColor = {66, 94, 128}

	addRemoteEvents{"acceptMoveRequest", "deleteMoveRequest"}
	addEventHandler("acceptMoveRequest", root, bind(self.acceptMoveRequest, self))
	addEventHandler("deleteMoveRequest", root, bind(self.deleteMoveRequest, self))

end

function TSConnect:destructor()
end

function TSConnect:callAPI(player, method, arg, response, callback)
	if not player or not isElement(player) then
		return false
	end

	local options = {
		["postData"] =  ("secret=%s&playerId=%d&method=%s&arg=%s"):format(self.m_Secret, player:getId(), method, arg or "")
	}
	fetchRemote(self.m_APIUrl, options,
		function(rawResponseData, responseInfo)
			--outputConsole(inspect({data = responseData, info = responseInfo}))
			if responseInfo["success"] == true then
				local responseData = fromJSON(rawResponseData)
				if not responseData or responseData["error"] then
					outputDebugString(("TSConnect PHP-Error: %s"):format(responseData and responseData["error"] or "no responseData"), 1)
				elseif response and responseData["response"] and responseData["player"] then
					local responsePlayer = PlayerManager:getSingleton():getPlayerFromId(responseData["player"])
					if responsePlayer and isElement(responsePlayer) then
						responsePlayer:sendShortMessage(responseData["response"], self.m_SMTitle, self.m_SMColor)
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

function TSConnect:sendMoveRequest(player, targetChannel, text)
	if player.m_TeamspeakId then
		text = text or "Klicke hier um in den Channel \""..targetChannel.."\" gemoved zu werden!"
		player:sendShortMessage(text, self.m_SMTitle, self.m_SMColor, 10000, "acceptMoveRequest", "deleteMoveRequest")
		self.m_MoveRequests[player] = targetChannel
	end
end

function TSConnect:acceptMoveRequest()
	if self.m_MoveRequests[client] then
		self:callAPI(client, "tsMoveClient", self.m_MoveRequests[client])
		self.m_MoveRequests[client] = nil
	else
		client:sendError("Du konntest nicht gemoved werden! Request abgelaufen!")
	end
end

function TSConnect:deleteMoveRequest()
	self.m_MoveRequests[client] = nil
end

function TSConnect:asyncCallAPI(...)
	local status = self:callAPI(Async.waitFor(), ...)
	return status, Async.wait()
end

TSConnect.Channel = {
	STATE = "Staat • Sammelstelle",

}
