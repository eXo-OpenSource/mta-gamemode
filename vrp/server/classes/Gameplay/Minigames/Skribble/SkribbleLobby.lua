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
	self.m_GuessingWords = nil
	self.m_GuessingWord = nil

	self:addPlayer(owner)
end

function SkribbleLobby:destructor()
	if isTimer(self.m_DrawTimer) then killTimer(self.m_DrawTimer) end
	if isTimer(self.m_StartRoundTimer) then killTimer(self.m_StartRoundTimer) end

	SkribbleManager:getSingleton():unlinkLobby(self.m_Id)
end

function SkribbleLobby:setState(state)
	outputChatBox("SkribbleLobby:setState -> " .. tostring(state))

	if state == "idle" then
		self.m_State = state
		if isTimer(self.m_StartRoundTimer) then killTimer(self.m_StartRoundTimer) end
		self:showInfoText("Warten auf weitere Spieler ...")

		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil

		self:syncLobbyInfos()
	elseif state == "choosing" then
		self.m_State = state
		local nextPlayer = self:getNextDrawingPlayer()
		if not nextPlayer then
			return self:setState("finishedRound")
		end

		self.m_CurrentDrawing = nextPlayer
		self.m_GuessingWord = nil
		self.m_GuessingWords = self:getRandomWords()

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
		self.m_Players[self.m_CurrentDrawing].queued = false
		self.m_Players[self.m_CurrentDrawing].guessedWord = 0

		self.m_DrawTimer = setTimer(
			function()
				self:setState("finishedDrawing")
			end, 80000, 1
		)

		self:syncLobbyInfos(true)
		self:showInfoText()
	elseif state == "finishedDrawing" then
		self.m_State = state

		self:calculatePoints()

		for _, data in pairs(self.m_Players) do
			data.guessedWord = false
		end

		local subText = (isTimer(self.m_DrawTimer) and self.m_DrawTimer:getDetails() > 0) and "Alle Spieler haben das Wort erraten!" or "Die Zeit ist abgelaufen!"
		self:showInfoText(("Das Wort war: %s\n%s"):format(self.m_GuessingWord[1], subText))

		if isTimer(self.m_DrawTimer) then killTimer(self.m_DrawTimer) end

		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil

		self:syncLobbyInfos()
		-- todo show results :)
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

		self.m_CurrentDrawing = nil
		self.m_GuessingWords = nil
		self.m_GuessingWord = nil

		self:syncLobbyInfos()
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
	elseif player == self.m_CurrentDrawing then
		--todo
	end

	self:syncLobbyInfos()
end

function SkribbleLobby:calculatePoints()
	for player, data in pairs(self.m_Players) do
		if data.guessedWord then
			if player == self.m_CurrentDrawing then
				data.gotPoints = data.guessedWord -- todo calculation
				data.points = data.points + data.gotPoints
			else
				data.gotPoints = data.guessedWord -- todo calculation
				data.points = data.points + data.gotPoints
			end
		else
			data.gotPoints = 0
		end
	end
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
				if v[1] == word[1] then return true end
			end
		end

	local words = {}
	for i = 1, 3 do
		local word = SKRIBBLE_WORDS[math.random(1, #SKRIBBLE_WORDS)]
		while isInList(words, word) do
			word = SKRIBBLE_WORDS[math.random(1, #SKRIBBLE_WORDS)]
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
end

function SkribbleLobby:verifyGuess(text)
	local toGuessingWord = self.m_GuessingWord[1]:lower()
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

function SkribbleLobby:syncLobbyInfos(clearDrawings)
	local timeLeft = isTimer(self.m_DrawTimer) and self.m_DrawTimer:getDetails() or false

	for player in pairs(self.m_Players) do
		player:triggerEvent("skribbleSyncLobbyInfos", self.m_Players, self.m_CurrentDrawing, self.m_CurrentRound, self.m_Rounds, self.m_GuessingWord, clearDrawings, timeLeft)
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
