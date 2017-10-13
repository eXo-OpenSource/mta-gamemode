-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleGUI = inherit(GUIForm)
inherit(Singleton, SkribbleGUI)
addRemoteEvents{"skribbleSyncLobbyInfos", "skribbleShowInfoText", "skribbleChoosingWord", "skribbleSyncDrawing"}

function SkribbleGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Skribble", true, true, self)

	GUIGridRectangle:new(1, 1, 24, 1, Color.LightGrey, self.m_Window)
	GUIGridLabel:new(1, 1, 1, 1, FontAwesomeSymbols.Clock, self.m_Window):setFont(FontAwesome(30)):setFontSize(1):setAlignX("center")

	self.m_TimeLeftLabel = GUIGridLabel:new(2, 1, 1, 1, "", self.m_Window)
	self.m_RoundLabel = GUIGridLabel:new(1, 1, 5, 1, "", self.m_Window):setAlignX("right")
	self.m_GuessingWordLabel = GUIGridLabel:new(10, 1, 10, 1, "", self.m_Window)

	self.m_PlayersGrid = GUIGridGridList:new(1, 2, 5, 14, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Spieler", .5)
	self.m_PlayersGrid:addColumn(_"Punkte", .3)
	self.m_PlayersGrid:addColumn(_"", .2)

	self.m_Skribble = GUIGridSkribble:new(6, 2, 19, 13, self.m_Window)

	self.m_Background = GUIGridRectangle:new(6, 2, 19, 13, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 2, 19, 13, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	local predefinedColors = {"Black", "Brown", "Red", "Orange", "Yellow", "Green", "LightBlue", "Blue", "Purple"}
	for i, color in pairs(predefinedColors) do
		local colorButton = GUIGridRectangle:new(5 + i, 15, 1, 1, Color[color], self.m_Window)
		colorButton.onLeftClick =
			function()
				self.m_ChangeColor:setBackgroundColor(Color[color])
				self.m_Skribble:setDrawColor(Color[color])
			end

		GUIGridEmptyRectangle:new(5 + i, 15, 1, 1, 1, Color.Black, self.m_Window)
	end

	self.m_ChangeColor = GUIGridIconButton:new(16, 15, FontAwesomeSymbols.Brush, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	self.m_ChangeColor.onLeftClick = bind(SkribbleGUI.changeColor, self)

	local erase = GUIGridIconButton:new(17, 15, FontAwesomeSymbols.Erase, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	erase.onLeftClick = function() self.m_Skribble:setDrawColor(Color.White) end

	local clearDraw = GUIGridIconButton:new(18, 15, FontAwesomeSymbols.Trash, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	clearDraw.onLeftClick = function() if self.m_CurrentDrawing == localPlayer then self.m_Skribble:clear() end end

	-- About the slider range:
	-- GUISkribble draws a FontAwesome text/symbol
	-- The FontAwesome font height will devided by 2. dxCreateFont height ist limited to 5 - 150 (https://github.com/multitheftauto/mtasa-blue/blob/b2227c359092ce530cdf9727466b88bec8282cd0/Client/core/Graphics/CRenderItem.DxFont.cpp#L96)
	local slider = GUIGridSlider:new(20, 15, 5, 1, self.m_Window):setRange(10, 300)
	slider.onUpdate = function(size) self.m_Skribble:setDrawSize(size) end
end

function SkribbleGUI:virtual_destructor()
	triggerServerEvent("skribbleLeaveLobby", localPlayer)

	if isTimer(self.m_ChooseTimer) then killTimer(self.m_ChooseTimer) end
end

function SkribbleGUI:showInfoText(text)
	if not text then self:hideInfoText() return end
	self:deleteChoosingButtons()
	self:deleteResultLabels()
	self.m_InfoLabel:setText(text)

	local backgroundAlpha = self.m_Background:getAlpha()
	if backgroundAlpha ~= 200 then
		Animation.FadeAlpha:new(self.m_Background, 250, backgroundAlpha, 200)
	end

	local posX, posY = self.m_InfoLabel:getPosition()
	self.m_InfoLabel:setPosition(posX, -posY)
	Animation.Move:new(self.m_InfoLabel, 250, posX, posY, "OutQuad")
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 0, 255)
end

function SkribbleGUI:hideInfoText()
	self:deleteChoosingButtons()
	self:deleteResultLabels()
	if self.m_InfoLabel:getText() == "" then return end

	Animation.FadeAlpha:new(self.m_Background, 250, 200, 0)
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 255, 0).onFinish =
		function()
			self.m_InfoLabel:setText("")
		end
end

function SkribbleGUI:showDrawResult()
	self:showInfoText("")

	local posX, posY = self.m_Skribble:getPosition()
	local width, height = self.m_Skribble:getSize()
	local subText = self.m_SyncData.timesUp and "Zeit abgelaufen!" or "Alle Spieler haben das Wort erraten!"
	local guessingWord = self.m_SyncData.guessingWord
	local offset = width/4

	if not self.m_Players[self.m_SyncData.drawer] then
		subText = "Der Zeichner hat das Spiel verlassen!"
	end

	self.m_ResultLabels = {}
	self.m_ResultLabels[1] = GUILabel:new(posX, posY, width, 80, ("Das Wort war: %s"):format(guessingWord), self.m_Window):setFont(VRPFont(50)):setAlignX("center"):setAlpha(0)
	self.m_ResultLabels[2] = GUILabel:new(posX, posY + 55, width, 25, subText, self.m_Window):setFont(VRPFont(25)):setAlignX("center"):setColor(Color.LightGrey):setAlpha(0)

	Animation.FadeAlpha:new(self.m_ResultLabels[1], 250, 0, 255)
	Animation.FadeAlpha:new(self.m_ResultLabels[2], 250, 0, 255)

	local i = 1
	for player, data in pairs(self.m_Players) do
		local nameLabel = GUILabel:new(posX + offset, posY + 100 + 25*(i-1), offset, 25, player:getName(), self.m_Window):setFont(VRPFont(30)):setAlpha(0)
		local pointsLabel = GUILabel:new(posX + offset*2, posY + 100 + 25*(i-1), offset, 25, ("+%s"):format(data.gotPoints), self.m_Window):setFont(VRPFont(30)):setColor(data.gotPoints > 0 and Color.Green or Color.Red):setAlignX("right"):setAlpha(0)

		table.insert(self.m_ResultLabels, nameLabel)
		table.insert(self.m_ResultLabels, pointsLabel)

		Animation.FadeAlpha:new(nameLabel, 250, 0, 255)
		Animation.FadeAlpha:new(pointsLabel, 250, 0, 255)

		i = i + 1
	end
end

function SkribbleGUI:showGameResult()
	self:showInfoText("Ergebnis\n\n\n\n\n\n\n\n")

	local posX, posY = self.m_Skribble:getPosition()
	local width, height = self.m_Skribble:getSize()
	local offset = width/4
	local positionColors = {[1] = Color.Yellow, [2] = Color.LightGrey, [3] = Color.Browm}

	self.m_ResultLabels = {}

	for i, data in pairs(self.m_SyncData.players) do
		local posLabel = GUILabel:new(posX, posY + 100 + 25*(i-1), offset - 10, 25, ("#%s"):format(i), self.m_Window):setFont(VRPFont(30)):setAlpha(0):setAlignX("right")
		local nameLabel = GUILabel:new(posX + offset, posY + 100 + 25*(i-1), offset, 25,  data[1], self.m_Window):setFont(VRPFont(30)):setAlpha(0)
		local pointsLabel = GUILabel:new(posX + offset*2, posY + 100 + 25*(i-1), offset, 25, data[2], self.m_Window):setFont(VRPFont(30)):setAlpha(0):setAlignX("right")

		if positionColors[i] then
			posLabel:setColor(positionColors[i])
			nameLabel:setColor(positionColors[i])
			pointsLabel:setColor(positionColors[i])
		end

		table.insert(self.m_ResultLabels, posLabel)
		table.insert(self.m_ResultLabels, nameLabel)
		table.insert(self.m_ResultLabels, pointsLabel)

		Animation.FadeAlpha:new(posLabel, 250, 0, 255)
		Animation.FadeAlpha:new(nameLabel, 250, 0, 255)
		Animation.FadeAlpha:new(pointsLabel, 250, 0, 255)
	end
end

function SkribbleGUI:deleteResultLabels()
	if self.m_ResultLabels then
		for k, element in pairs(self.m_ResultLabels) do
			Animation.FadeAlpha:new(element, 250, 255, 0).onFinish =
			function()
				element:delete()
			end
		end

		self.m_ResultLabels = nil
	end
end

function SkribbleGUI:deleteGameResult()

end

function SkribbleGUI:updateInfos(state, players, currentDrawing, currentRound, rounds, guessingWord, hints, syncData, timeLeft)
	self.m_State = state
	self.m_Players = players
	self.m_GuessingWord = guessingWord
	self.m_CurrentDrawing = currentDrawing
	self.m_SyncData = syncData
	self.m_Hints = hints

	self.m_RoundLabel:setText(("Runde %s von %s"):format(currentRound, rounds))

	self.m_PlayersGrid:clear()
	for player, data in pairs(self.m_Players) do
		local item = self.m_PlayersGrid:addItem(player:getName(), data.points, player == self.m_CurrentDrawing and FontAwesomeSymbols.Pencil or (data.queued and FontAwesomeSymbols.Clock or FontAwesomeSymbols.Check))
		item:setColumnFont(3, FontAwesome(20), 1)
		item:setClickable(false)
		item:setColor(Color.White)

		if data.guessedWord and player ~= self.m_CurrentDrawing then
			item:setBackgroundColor(tocolor(60, 255, 0, 180))
		end
	end

	if self.m_GuessingWord then
		if self.m_CurrentDrawing == localPlayer then
			self.m_GuessingWordLabel:setText(self.m_GuessingWord[1])
			self:setDrawingEnabled(true)
		else
			self:updateGuessingWordLabel()
		end
	end

	if self.m_CurrentDrawing ~= localPlayer then
		self:setDrawingEnabled(false)
	end

	if self.m_SyncData then
		if self.m_State == "finishedDrawing" and self.m_SyncData.showDrawResult then
			self:showDrawResult()
		end

		if self.m_State == "finishedGame" and self.m_SyncData.showGameResult then
			self:showGameResult()
		end

		if self.m_SyncData.clearDrawings then
			self.m_Skribble:clear(true)
		end
	else
		self:deleteResultLabels()
	end

	if timeLeft then
		self.m_TimeLeft = math.floor(timeLeft/1000)
		self.m_TimeLeftLabel:setText(self.m_TimeLeft)

		if isTimer(self.m_TimeLeftTimer) then killTimer(self.m_TimeLeftTimer) end
		self.m_TimeLeftTimer = setTimer(
			function()
				self.m_TimeLeft = self.m_TimeLeft - 1
				self.m_TimeLeftLabel:setText(self.m_TimeLeft)
			end, 1000, self.m_TimeLeft
		)
	else
		if isTimer(self.m_TimeLeftTimer) then killTimer(self.m_TimeLeftTimer) end
		self.m_TimeLeftLabel:setText("")
	end
end

function SkribbleGUI:updateGuessingWordLabel()
	local wordLength = self.m_GuessingWord[1]:len()

	if table.size(self.m_Hints) == 0 then
		self.m_GuessingWordLabel:setText(("_ "):rep(wordLength))
	else
		local text = ""
		for i = 1, wordLength do
			if not self.m_Hints[i] then
				text = ("%s_ "):format(text)
			else
				text = ("%s%s "):format(text, utfSub(self.m_GuessingWord[1], i, i))
			end
		end

		self.m_GuessingWordLabel:setText(text)
	end
end

function SkribbleGUI:choosingWord(words)
	self:showInfoText("Wähle ein Wort aus ...\n\n\n\n")

	self.m_WordButtons = {}
	for key, word in pairs(words) do
		local posX, posY = self.m_Skribble:getPosition()
		local width, height = self.m_Skribble:getSize()

		self.m_WordButtons[key] = GUIButton:new(posX + width/2 - 125, (posY+height/2) + 55*(key-2), 250, 50, word[1], self.m_Window):setBarEnabled(false):setAlpha(0)
		Animation.FadeAlpha:new(self.m_WordButtons[key], 300*key, 0, 255)

		self.m_WordButtons[key].onLeftClick =
			function()
				if isTimer(self.m_ChooseTimer) then killTimer(self.m_ChooseTimer) end
				triggerServerEvent("skribbleChoosedWord", localPlayer, key)
			end
	end

	if isTimer(self.m_ChooseTimer) then killTimer(self.m_ChooseTimer) end
	self.m_ChooseTimer = setTimer(
		function()
			triggerServerEvent("skribbleChoosedWord", localPlayer, 1)
		end, 10000, 1
	)
end

function SkribbleGUI:deleteChoosingButtons()
	if self.m_WordButtons then
		for _, button in pairs(self.m_WordButtons) do
			button:delete()
		end

		self.m_WordButtons = nil
	end
end

function SkribbleGUI:setDrawingEnabled(state)
	if state then
		self.m_Skribble:setDrawingEnabled(true)

		if isTimer(self.m_SyncDrawTimer) then return end
		self.m_SyncDrawTimer = setTimer(
			function()
				local syncData = self.m_Skribble:getSyncData(true)
				if #syncData > 0 then
					triggerServerEvent("skribbleSendDrawing", localPlayer, syncData)
				end
			end, 500, 0
		)
	else
		if isTimer(self.m_SyncDrawTimer) then killTimer(self.m_SyncDrawTimer) end
		self.m_Skribble:setDrawingEnabled(false)
	end
end

function SkribbleGUI:changeColor()
	ColorPicker:new(
		function(r, g, b)
			self.m_ChangeColor:setBackgroundColor(tocolor(r, g, b))
			self.m_Skribble:setDrawColor(tocolor(r, g, b))
		end,
		function(r, g, b)
			self.m_ChangeColor:setBackgroundColor(tocolor(r, g, b))
		end,
		function(r, g, b)
			self.m_ChangeColor:setBackgroundColor(tocolor(r, g, b))
			self.m_Skribble:setDrawColor(tocolor(r, g, b))
		end,
		self.m_Skribble.m_DrawColor
	)
end

addEventHandler("skribbleSyncLobbyInfos", root,
	function(...)
		if not SkribbleGUI:isInstantiated() then
			SkribbleGUI:new(...)
			Phone:getSingleton():close()
		end

		SkribbleGUI:getSingleton():updateInfos(...)
	end
)

addEventHandler("skribbleShowInfoText", root,
	function(...)
		if SkribbleGUI:isInstantiated() then
			SkribbleGUI:getSingleton():showInfoText(...)
		end
	end
)

addEventHandler("skribbleChoosingWord", root,
	function(words)
		if SkribbleGUI:isInstantiated() then
			SkribbleGUI:getSingleton():choosingWord(words)
		end
	end
)

addEventHandler("skribbleSyncDrawing", root,
	function(drawData)
		if SkribbleGUI:isInstantiated() then
			SkribbleGUI:getSingleton().m_Skribble:drawSyncData(drawData)
		end
	end
)
