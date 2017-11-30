QuestDraw = inherit(Object)

function QuestDraw:constructor(id, name, type)
	self.m_Id = id
	self.m_Name = name

	addRemoteEvents{"questDrawShowSkribble"}
	addEventHandler("questDrawShowSkribble", root, function()
		QuestDrawGUI:new(self.m_Id, self.m_Name)
	end)



end

function QuestDraw:destructor()
end

QuestDrawGUI = inherit(GUIForm)
inherit(Singleton, QuestDrawGUI)

function QuestDrawGUI:constructor(id, name)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, name, true, true, self)

	self.m_Skribble = GUIGridSkribble:new(1, 1, 20, 10, self.m_Window)
	self.m_Skribble:setDrawingEnabled(true)
	self.m_Background = GUIGridRectangle:new(1, 1, 20, 10, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(1, 1, 20, 10, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	self.m_Contest = contest

	local predefinedColors = {"Black", "Brown", "Red", "Orange", "Yellow", "Green", "LightBlue", "Blue", "Purple"}
	for i, color in pairs(predefinedColors) do
		local colorButton = GUIGridRectangle:new(i, 11, 1, 1, Color[color], self.m_Window)
		colorButton.onLeftClick =
			function()
				self.m_ChangeColor:setBackgroundColor(Color[color])
				self.m_Skribble:setDrawColor(Color[color])
			end

		GUIGridEmptyRectangle:new(i, 11, 1, 1, 1, Color.Black, self.m_Window)
	end

	self.m_ChangeColor = GUIGridIconButton:new(10, 11, FontAwesomeSymbols.Brush, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	self.m_ChangeColor.onLeftClick = bind(QuestDrawGUI.changeColor, self)

	local erase = GUIGridIconButton:new(11, 11, FontAwesomeSymbols.Erase, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	erase.onLeftClick = function() self.m_Skribble:setDrawColor(Color.White) end

	local clearDraw = GUIGridIconButton:new(12, 11, FontAwesomeSymbols.Trash, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Primary)
	clearDraw.onLeftClick = function() self.m_Skribble:clear() end


	-- About the slider range:
	-- GUISkribble draws a FontAwesome text/symbol
	-- The FontAwesome font height will devided by 2. dxCreateFont height ist limited to 5 - 150 (https://github.com/multitheftauto/mtasa-blue/blob/b2227c359092ce530cdf9727466b88bec8282cd0/Client/core/Graphics/CRenderItem.DxFont.cpp#L96)
	local slider = GUIGridSlider:new(13, 11, 5, 1, self.m_Window):setRange(10, 300)
	slider.onUpdate = function(size) self.m_Skribble:setDrawSize(size) end

	local save = GUIGridButton:new(18, 11, 3, 1, "Einsenden", self.m_Window)
	save.onLeftClick = function()
		QuestionBox:new("Möchtest du das Bild wirklich einsenden? Warnung: Du kannst nur ein einziges Bild für das Event einsenden!", function()
			self.m_Skribble:setDrawingEnabled(false)

			self:showInfoText("Das Bild wird gespeichert...")

			local options = {
				["postData"] =  ("secret=%s&playerId=%d&contest=%s&data=%s"):format("8H041OAyGYk8wEpIa1Fv", localPlayer:getPrivateSync("Id"), name, toJSON(self.m_Skribble:getSyncData()))
			}

			fetchRemote(("https://exo-reallife.de/ingame/drawContest/addData.php%s"):format(DEBUG and "?debug=true" or ""), options,
				function(responseData, responseInfo)
					--outputConsole(inspect({data = responseData, info = responseInfo}))
					responseData = fromJSON(responseData)
					if not responseData["error"] then
						self:showInfoText("Das Bild wurde erfolgreich gespeichert!")
						triggerServerEvent("questDrawPictureSaved", localPlayer)
					else
						if responseData["error"] == "Already sent a image" then
							self:showInfoText("Fehler: Du hast bereits ein Bild zu dieser Aufgabe eingesendet!")
						else
							self:showInfoText("Fehler: "..responseData["error"])
						end
					end

				end
			)
		end)

	end
end

function QuestDrawGUI:virtual_destructor()

end

function QuestDrawGUI:showInfoText(text)
	if not text then self:hideInfoText() return end
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

function QuestDrawGUI:hideInfoText()
	if self.m_InfoLabel:getText() == "" then return end

	Animation.FadeAlpha:new(self.m_Background, 250, 200, 0)
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 255, 0).onFinish =
		function()
			self.m_InfoLabel:setText("")
		end
end

function QuestDrawGUI:changeColor()
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

QuestDrawAdminGUI = inherit(GUIForm)
inherit(Singleton, QuestDrawAdminGUI)


addEvent("questDrawShowAdminGUI", true)
addEventHandler("questDrawShowAdminGUI", root, function()
	QuestDrawAdminGUI:new()
end)

function QuestDrawAdminGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 26)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Draw-Quest Admin GUI", true, true, self)

	self.m_ContestNameLabel = GUIGridLabel:new(1, 1, 10, 1, "Aktuelle Aufgabe: -", self.m_Window)

	self.m_PlayersGrid = GUIGridGridList:new(1, 2, 5, 11, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Zeichnungen", 1)

	self.m_Skribble = GUIGridSkribble:new(6, 2, 20, 10, self.m_Window)
	self.m_Background = GUIGridRectangle:new(6, 2, 20, 10, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 2, 20, 10, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	self.m_SelectedPlayerId = 0
	self.m_SelectedPlayerName = ""

	self:showInfoText("Bestätige nur Zeichnungen, die auch die Aufgabe richtig und schön gezeichnet haben!")

	self.m_AcceptDrawBtn = GUIGridButton:new(22, 12, 4, 1, "akzeptieren", self.m_Window):setBackgroundColor(Color.Green)
	self.m_AcceptDrawBtn:setVisible(false)
	self.m_AcceptDrawBtn.onLeftClick = function()
		QuestionBox:new(_("Möchtest du das Bild von %s akzeptieren?", self.m_SelectedPlayerName),
		function() triggerServerEvent("questDrawReceiveAcceptImage", localPlayer, self.m_SelectedDrawId) self:resetOverview("Wähle ein Bild aus") end)
	end

	self.m_DeclineDrawBtn = GUIGridButton:new(17, 12, 4, 1, "ablehnen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_DeclineDrawBtn:setVisible(false)
	self.m_DeclineDrawBtn.onLeftClick = function()
		QuestionBox:new(_("Möchtest du das Bild von %s ablehnen?", self.m_SelectedPlayerName),
		function() triggerServerEvent("questDrawReceiveDeclineImage", localPlayer, self.m_SelectedDrawId) self:resetOverview("Wähle ein Bild aus") end)
	end
	addEvent("questDrawReceivePlayers", true)

	triggerServerEvent("questDrawRequestPlayers", localPlayer)
	addEventHandler("questDrawReceivePlayers", root, bind(self.onReceivePlayers, self))
end

function QuestDrawAdminGUI:showInfoText(text)
	if not text then self:hideInfoText() return end
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

function QuestDrawAdminGUI:hideInfoText()
	if self.m_InfoLabel:getText() == "" then return end

	Animation.FadeAlpha:new(self.m_Background, 250, 200, 0)
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 255, 0).onFinish =
		function()
			self.m_InfoLabel:setText("")
		end
end

function QuestDrawAdminGUI:onReceivePlayers(contestName, players)
	self.m_Contest = contestName
	self.m_ContestNameLabel:setText(_("Aktuelle Aufgabe: %s", contestName))
	self.m_AcceptDrawBtn:setVisible(false)
	self.m_DeclineDrawBtn:setVisible(false)

	self.m_PlayersGrid:clear()
	local item
	for id, drawing in pairs(players) do
		item = self.m_PlayersGrid:addItem(drawing.name)

		item.onLeftClick = function(item)
			if item == self.m_SelectedDrawItem then return end

			if not localPlayer.LastRequest then
				self.m_SelectedDrawItem = item
				self.m_SelectedDrawId = drawing.drawId

				self.m_SelectedPlayerName = drawing.name
				self.m_SelectedPlayerId = id

				self:resetOverview("Das Bild wird geladen...")
				localPlayer.LastRequest = true

				fetchRemote(("https://exo-reallife.de/ingame/drawContest/getData.php?%splayerId=%s&contest=%s"):format(DEBUG and "debug=true&" or "", id, contestName), bind(self.onReceiveImage, self))
				self.m_AcceptDrawBtn:setVisible(false)
				self.m_DeclineDrawBtn:setVisible(false)
			else
				WarningBox:new("Bitte warte bis die letzte Anfrage verarbeitet wurde")
			end
		end
	end
end

function QuestDrawAdminGUI:resetOverview(labelText)
	self.m_Skribble:clear(true)
	self:showInfoText(labelText)
end

function QuestDrawAdminGUI:onReceiveImage(drawData)
	localPlayer.LastRequest = false

	self:hideInfoText()
	self.m_Skribble:drawSyncData(fromJSON(drawData))
	self.m_AcceptDrawBtn:setVisible(true)
	self.m_DeclineDrawBtn:setVisible(true)
end

