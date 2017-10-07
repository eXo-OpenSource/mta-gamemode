-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleLobby = inherit(Object)

function SkribbleLobby:constructor(id, owner, name, password, rounds)
	self.m_Id = id
	self.m_Owner = owner
	self.m_Name = name
	self.m_Password = password
	self.m_Rounds = rounds

	self.m_Players = {}
	self.m_CurrentRound = 1
	self.m_State = "idle"
	self.m_CurrentDrawing = nil

	self:addPlayer(owner)
end

function SkribbleLobby:destructor()
	SkribbleManager:getSingleton():unlinkLobby(self.m_Id)
end

function SkribbleLobby:setState(state)
	outputChatBox("SkribbleLobby:setState -> " .. tostring(state))

	if state == "idle" then
		self.m_State = state
		if isTimer(self.m_StartRoundTimer) then killTimer(self.m_StartRoundTimer) end
		self:showInfoText("Warten auf weitere Spieler ...")
	elseif state == "choosing" then
		self.m_State = state
		local nextPlayer = self:getNextDrawingPlayer()
		if not nextPlayer then
			self:setState("finishedRound")
		end

		self.m_CurrentDrawing = nextPlayer
	elseif state == "finishedRound" then
		self.m_State = state

		if self.m_CurrentRound < self.m_Rounds then
			self.m_CurrentRound = self.m_CurrentRound + 1

			for _, data in pairs(self.m_Players) do
				data.queued = true
			end

			self:setState("choosing")
		else
			self:setState("finishedGame")
		end
	elseif state == "finishedGame" then
		self.m_State = state
		-- todo show results :)
	end
end

function SkribbleLobby:isState(state)
	return self.m_State == state
end

function SkribbleLobby:showInfoText(text)
	for player in pairs(self.m_Players) do
		player:triggerEvent("skribbleShowInfoText", text)
	end
end

function SkribbleLobby:getPlayers()
	local players = {}
	for player in pairs(self.m_Players) do
		if isElement(player) then
			table.insert(players, player)
		end
	end
	return players
end

function SkribbleLobby:addPlayer(player)
	self.m_Players[player] = {points = 0, queued = true}
	player.skribbleLobby = self

	self:sendShortMessage(player:getName() .. " is beigetreten!")
	self:syncLobbyInfos()

	local playerCount = #self:getPlayers()

	if playerCount == 1 then
		player:triggerEvent("skribbleShowInfoText", "Warten auf weitere Spieler ...")
		return
	end

	if self:isState("idle") and playerCount > 1 then
		self:showInfoText("Runde " .. self.m_CurrentRound)

		self.m_StartRoundTimer = setTimer(
			function()
				self:showInfoText()
				self:setState("choosing")
			end, 2000, 1
		)
	end
end

function SkribbleLobby:removePlayer(player)
	self.m_Players[player] = nil
	player.skribbleLobby = nil

	local playerCount = #self:getPlayers()
	if playerCount == 0 then
		return delete(self)
	elseif playerCount < 2 then
		self:setState("idle")
	end

	self:syncLobbyInfos()
end

function SkribbleLobby:getNextDrawingPlayer()
	for player, data in pairs(self.m_Players) do
		if data.queued then
			return player
		end
	end
end

function SkribbleLobby:syncLobbyInfos()
	for player in pairs(self.m_Players) do
		player:triggerEvent("skribbleSyncLobbyInfos", self.m_Players, self.m_CurrentDrawing, self.m_CurrentRound, self.m_Rounds)
	end
end

function SkribbleLobby:sendShortMessage(text, ...)
	for player in pairs(self.m_Players) do
		player:sendShortMessage(_(text, player), "Skribble", {255, 125, 0}, ...)
	end
end

function SkribbleLobby:onPlayerChat(player, text, type)
	if type ~= 0 then return end

	for player in pairs(self.m_Players) do
		player:outputChat(("[Skribble] %s#E8FCFC: %s"):format(player:getName(), text), 255, 90, 0, true)
	end

	return true
end
