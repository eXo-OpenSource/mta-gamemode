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

	self.m_DrawData = {}
	self.m_Players = {}
	self.m_CurrentRound = 1
	self.m_State = "idle"
	self.m_CurrentDrawing = nil
	self.m_GuessingWords = nil
	self.m_GuessingWord = nil
	self.m_Hints = {}

	self:addPlayer(owner)
end

function SkribbleLobby:destructor()
	if isTimer(self.m_DrawTimer) then killTimer(self.m_DrawTimer) end
	if isTimer(self.m_HintTimer) then killTimer(self.m_HintTimer) end
	if isTimer(self.m_StartRoundTimer) then killTimer(self.m_StartRoundTimer) end
	if isTimer(self.m_NextPlayerTimer) then killTimer(self.m_NextPlayerTimer) end
	if isTimer(self.m_RestartGameTimer) then killTimer(self.m_RestartGameTimer) end

	SkribbleManager:getSingleton():unlinkLobby(self.m_Id)
end

function SkribbleLobby:setState(state)
	--outputChatBox("SkribbleLobby:setState -> " .. tostring(state))

	if state == "idle" then
		self.m_State = state
		if isTimer(self.m_StartRoundTimer) then killTimer(self.m_StartRoundTimer) end
		if isTimer(self.m_DrawTimer) then killTimer(self.m_DrawTimer) end
		if isTimer(self.m_NextPlayerTimer) then killTimer(self.m_NextPlayerTimer) end
		if isTimer(self.m_HintTimer) then killTimer(self.m_HintTimer) end
		if isTimer(self.m_RestartGameTimer) then killTimer(self.m_RestartGameTimer) end
		self:showInfoText("Warten auf weitere Spieler ...")

		self.m_SyncData = nil
		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil
		self.m_Hints = {}
		self.m_DrawData = {}

		for _, data in pairs(self.m_Players) do
			data.guessedWord = false
		end

		self:syncLobbyInfos()
	elseif state == "choosing" then
		self.m_State = state

		local playerCount = #self:getPlayers()
		if playerCount < 2 then
			return self:setState("idle")
		end

		local nextPlayer = self:getNextDrawingPlayer()
		if not nextPlayer then
			return self:setState("finishedRound")
		end

		self.m_CurrentDrawing = nextPlayer
		self.m_GuessingWord = nil
		self.m_GuessingWords = self:getRandomWords()
		self.m_DrawData = {}

		for player in pairs(self.m_Players) do
			if player == self.m_CurrentDrawing then
				player:triggerEvent("skribbleChoosingWord", self.m_GuessingWords)
			else
				player:triggerEvent("skribbleShowInfoText", ("%s wählt ein Wort aus ..."):format(self.m_CurrentDrawing:getName()))
			end
		end

		self:syncLobbyInfos()
	elseif state == "drawing" then
		self.m_State = state
		self.m_DrawData = {}
		self.m_Players[self.m_CurrentDrawing].queued = false
		self.m_Players[self.m_CurrentDrawing].guessedWord = 0

		self.m_DrawTimer = setTimer(
			function()
				self:setState("finishedDrawing")
			end, 80000, 1
		)

		self.m_HintTimer = setTimer(
			function()
				self:addHint()
				self:syncLobbyInfos()
			end, 30000, 2
		)

		self.m_SyncData = {clearDrawings = true} -- clear all previous drawing
		self:syncLobbyInfos()
		self:showInfoText()

		self.m_SyncData = nil
	elseif state == "finishedDrawing" then
		self.m_State = state

		self:calculatePoints()

		local players = {}

		for player, data in pairs(self.m_Players) do
			data.guessedWord = false
			table.insert(players, {player:getName(), data.gotPoints})
		end

		table.sort(players, function(a, b) return a[2] > b[2] end)

		self.m_SyncData = {showDrawResult = true, drawer = self.m_CurrentDrawing, players = players, timesUp = isTimer(self.m_DrawTimer) and self.m_DrawTimer:getDetails() <= 0, guessingWord = self.m_GuessingWord.Word}

		if isTimer(self.m_DrawTimer) then killTimer(self.m_DrawTimer) end
		if isTimer(self.m_HintTimer) then killTimer(self.m_HintTimer) end

		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil
		self.m_Hints = {}
		self.m_DrawData = {}

		self:syncLobbyInfos()

		self.m_NextPlayerTimer = setTimer(
			function()
				self:setState("choosing")
			end, 5000, 1
		)
	elseif state == "finishedRound" then
		self.m_State = state

		if self.m_CurrentRound < self.m_Rounds then
			self.m_CurrentRound = self.m_CurrentRound + 1

			for _, data in pairs(self.m_Players) do
				data.queued = true
			end

			self:showInfoText("Runde " .. self.m_CurrentRound)

			self.m_StartRoundTimer = setTimer(
				function()
					self:setState("choosing")
				end, 2000, 1
			)
		else
			self:setState("finishedGame")
		end
	elseif state == "finishedGame" then
		self.m_State = state

		local players = {}
		for player, data in pairs(self.m_Players) do
			table.insert(players, {player:getName(), data.points})
		end

		table.sort(players, function(a, b) return a[2] > b[2] end)

		self.m_SyncData = {showGameResult = true, players = players} -- clear all previous drawing

		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil

		self:syncLobbyInfos()

		self.m_RestartGameTimer = setTimer(
			function()
				self.m_CurrentRound = 1
				self.m_SyncData = nil
				self.m_CurrentDrawing = nil
				self.m_GuessingWords = nil
				self.m_GuessingWord = nil
				self.m_Hints = {}
				self.m_DrawData = {}

				for _, data in pairs(self.m_Players) do
					data.points = 0
					data.queued = true
					data.guessedWord = false
				end

				self:setState("choosing")
			end, 15000, 1
		)
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

	self:sendShortMessage(player:getName() .. " ist beigetreten!")
	self:syncLobbyInfos()

	local playerCount = #self:getPlayers()

	if playerCount == 1 then
		player:triggerEvent("skribbleShowInfoText", "Warten auf weitere Spieler ...")
		return
	end

	if self:isState("drawing") then
		player:triggerEvent("skribbleSyncDrawing", self.m_DrawData)
	end

	if self:isState("idle") and playerCount > 1 and not isTimer(self.m_StartRoundTimer) then
		self:showInfoText("Runde " .. self.m_CurrentRound)

		self.m_StartRoundTimer = setTimer(
			function()
				self:setState("choosing")
			end, 2000, 1
		)
	end
end

function SkribbleLobby:removePlayer(player)
	self.m_Players[player] = nil
	player.skribbleLobby = nil

	self:sendShortMessage(player:getName() .. " hat die Lobby verlassen!")

	local playerCount = #self:getPlayers()
	if playerCount == 0 then
		return delete(self)
	elseif playerCount < 2 then
		if self:isState("finishedGame") then
			self.m_CurrentRound = 1

			for _, data in pairs(self.m_Players) do
				data.points = 0
				data.queued = true
			end
		end

		self:setState("idle")
	elseif player == self.m_CurrentDrawing then
		self:setState(self:isState("drawing") and "finishedDrawing" or "choosing")
	else
		if #self:getGuessedPlayers() == #self:getPlayers() then
			self:setState("finishedDrawing")
		end
	end

	self:syncLobbyInfos()
end

function SkribbleLobby:calculatePoints()
	local playerCount = #self:getPlayers()
	local pool = playerCount*200
	local timeleftSum = 0
	local highestTimeleft = 0

	for player, data in pairs(self.m_Players) do
		if data.guessedWord then
			timeleftSum = timeleftSum + data.guessedWord

			if data.guessedWord > highestTimeleft then
				highestTimeleft = data.guessedWord
			end
		end
	end

	if self.m_Players[self.m_CurrentDrawing] then
		self.m_Players[self.m_CurrentDrawing].guessedWord = highestTimeleft*0.6
	end

	for player, data in pairs(self.m_Players) do
		if data.guessedWord and timeleftSum > 0 then
			data.gotPoints = math.round(pool/timeleftSum*data.guessedWord/5)*5
			data.points = data.points + data.gotPoints
		else
			data.gotPoints = 0
		end
	end
end

function SkribbleLobby:addHint()
	local wordLength = self.m_GuessingWord.Word:len()
	local randomHintIndex = math.random(1, wordLength)

	while self.m_Hints[randomHintIndex] do
		randomHintIndex = math.random(1, wordLength)
	end

	self.m_Hints[randomHintIndex] = true
end

function SkribbleLobby:getNextDrawingPlayer()
	for player, data in pairs(self.m_Players) do
		if data.queued then
			return player
		end
	end
end

function SkribbleLobby:getRandomWords()
	local isInList =
		function(tab, word)
			for _, v in pairs(tab) do
				if v.Word == word.Word then return true end
			end
		end

	local words = {}
	for i = 1, 3 do
		local word = SkribbleManager.Words[math.random(1, #SkribbleManager.Words)]
		while isInList(words, word) do
			word = SkribbleManager.Words[math.random(1, #SkribbleManager.Words)]
		end

		table.insert(words, word)
	end

	return words
end

function SkribbleLobby:choosedWord(player, key)
	if player == self.m_CurrentDrawing and self:isState("choosing") then
		self.m_GuessingWord = self.m_GuessingWords[key]
		self:setState("drawing")
	end
end

function SkribbleLobby:receiveDrawing(client, drawData)
	for player in pairs(self.m_Players) do
		if player ~= client then
			player:triggerEvent("skribbleSyncDrawing", drawData)
		end
	end

	table.append(self.m_DrawData, drawData)
end

function SkribbleLobby:verifyGuess(text)
	local toGuessingWord = self.m_GuessingWord.Word:lower()
	local guessedWord = text:lower()

	-- Todo: Simplify rates by recognizing similar words
	return toGuessingWord == guessedWord
end

function SkribbleLobby:getGuessedPlayers()
	local guessedPlayers = {}

	for player, data in pairs(self.m_Players) do
		if data.guessedWord then
			table.insert(guessedPlayers, player)
		end
	end

	return guessedPlayers
end

function SkribbleLobby:syncLobbyInfos()
	local timeLeft = isTimer(self.m_DrawTimer) and self.m_DrawTimer:getDetails() or false

	for player in pairs(self.m_Players) do
		player:triggerEvent("skribbleSyncLobbyInfos", self.m_State, self.m_Players, self.m_CurrentDrawing, self.m_CurrentRound, self.m_Rounds, self.m_GuessingWord, self.m_Hints, self.m_SyncData, timeLeft)
	end
end

function SkribbleLobby:sendShortMessage(text, ...)
	for player in pairs(self.m_Players) do
		player:sendShortMessage(_(text, player), "Skribble", {255, 125, 0}, ...)
	end
end

function SkribbleLobby:onPlayerChat(client, text, type)
	if type ~= 0 then return end

	if self:isState("drawing") and not self.m_Players[client].guessedWord then
		if self:verifyGuess(text) then
			self.m_Players[client].guessedWord = self.m_DrawTimer:getDetails()

			if #self:getGuessedPlayers() == #self:getPlayers() then
				self:setState("finishedDrawing")
			end

			for player in pairs(self.m_Players) do
				player:outputChat(("[Skribble] %s hat das Wort erraten!"):format(client:getName()), 90, 190, 80)
			end

			self:syncLobbyInfos()
			return true
		end
	end

	local clientGuessed = self.m_Players[client].guessedWord
	local color = clientGuessed and {150, 255, 140, true} or {255, 135, 70, true}

	for player, data in pairs(self.m_Players) do
		if not clientGuessed then
			player:outputChat(("[Skribble] %s#E8E8E8: %s"):format(client:getName(), text), unpack(color))
		elseif clientGuessed and data.guessedWord then
			player:outputChat(("[Skribble] %s#E8E8E8: %s"):format(client:getName(), text), unpack(color))
		end
	end

	return true
end
