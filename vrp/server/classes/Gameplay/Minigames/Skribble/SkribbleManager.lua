-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleManager = inherit(Singleton)
addRemoteEvents{"skribbleRequestLobbys", "skribbleCreateLobby", "skribbleJoinLobby", "skribbleLeaveLobby", "skribbleChoosedWord", "skribbleSendDrawing"}

function SkribbleManager:constructor()
	self.m_Lobbys = {}

	Player.getChatHook():register(
		function(player, text, type)
			if player.skribbleLobby then
				return player.skribbleLobby:onPlayerChat(player, text, type)
			end
		end
	)

	addEventHandler("skribbleRequestLobbys", root, bind(SkribbleManager.requestLobbys, self))
	addEventHandler("skribbleCreateLobby", root, bind(SkribbleManager.createLobby, self))
	addEventHandler("skribbleJoinLobby", root, bind(SkribbleManager.joinLobby, self))
	addEventHandler("skribbleLeaveLobby", root, bind(SkribbleManager.leaveLobby, self))
	addEventHandler("skribbleChoosedWord", root, bind(SkribbleManager.choosedWord, self))
	addEventHandler("skribbleSendDrawing", root, bind(SkribbleManager.receiveDrawing, self))
end

function SkribbleManager:unlinkLobby(id)
	if not self.m_Lobbys[id] then return end
	self.m_Lobbys[id] = nil
end

function SkribbleManager:requestLobbys()
	local lobbys = {}
	for id, lobby in pairs(self.m_Lobbys) do
		lobbys[id] = {
			owner = lobby.m_Owner,
			name = lobby.m_Name,
			password = lobby.m_Password,
			rounds = lobby.m_Rounds,
			currentRound = lobby.m_CurrentRound,
			players = #lobby:getPlayers()
		}
	end

	client:triggerEvent("skribbleReceiveLobbys", lobbys)
end

function SkribbleManager:createLobby(name, password, rounds)
	-- todo: check arguments
	local id = #self.m_Lobbys + 1
	self.m_Lobbys[id] = SkribbleLobby:new(id, client, name, password, rounds)
end

function SkribbleManager:joinLobby(id)
	if not self.m_Lobbys[id] then return end
	if client.skribbleLobby then return end

	self.m_Lobbys[id]:addPlayer(client)
end

function SkribbleManager:leaveLobby()
	if not client.skribbleLobby then return end
	client.skribbleLobby:removePlayer(client)
end

function SkribbleManager:choosedWord(key)
	if not client.skribbleLobby then return end
	client.skribbleLobby:choosedWord(client, key)
end

function SkribbleManager:receiveDrawing(drawData)
	if not client.skribbleLobby then return end
	client.skribbleLobby:receiveDrawing(client, drawData)
end
