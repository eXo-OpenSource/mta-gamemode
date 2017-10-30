-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

--DEVELOP INFO:
-- Player Grid wird von Lokaler DB über MTA geladen
-- Bild wird über PHP auf Test-DB gespeichert/geladen


DrawContestOverviewGUI = inherit(GUIForm)
inherit(Singleton, DrawContestOverviewGUI)

addRemoteEvents{"drawContestReceivePlayers", "drawingContestReceiveVote"}

function DrawContestOverviewGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 26)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Halloween Zeichenwettbewerb", true, true, self)

	self.m_ContestNameLabel = GUIGridLabel:new(1, 1, 10, 1, "Aktuelle Aufgabe: -", self.m_Window)
	self.m_ContestTypeLabel = GUIGridLabel:new(13, 1, 10, 1, "Aktuelle Phase: -", self.m_Window)

	self.m_PlayersGrid = GUIGridGridList:new(1, 2, 5, 11, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Zeichnungen", 1)

	self.m_Skribble = GUIGridSkribble:new(6, 2, 20, 10, self.m_Window)
	self.m_Background = GUIGridRectangle:new(6, 2, 20, 10, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 2, 20, 10, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	self.m_SelectedPlayerId = 0
	self.m_SelectedPlayerName = ""

	self:showInfoText("eXo-Reallife Halloween Zeichen-Wettbewerb!\nMale ein Bild zum angegeben Thema.\n(Jeder User darf nur ein Bild pro Thema einsenden)\nEinem Tag nach Einsendeschluss können User das Bild bewerten.\nZu Gewinnen gibt es bei jedem Wettbewerb 15 eXo-Dollar!")

	self.m_RatingLabel = GUIGridLabel:new(6, 12, 3, 1, "Deine Bewertung:", self.m_Window)
	self.m_Rating = GUIGridRating:new(9, 12, 5, 1, 5, self.m_Window)
	self.m_Rating.onChange = function(ratingValue)
		QuestionBox:new(_("Möchtest du das Bild von %s mit %d Stern/en bewerten?", self.m_SelectedPlayerName, ratingValue),
		function() triggerServerEvent("drawContestRateImage", localPlayer, self.m_SelectedPlayerId, ratingValue) end,
		function() self.m_Rating:reset() end
	)
	end
	self.m_RatingAdmin = GUIGridLabel:new(15, 12, 10, 1, "", self.m_Window):setAlignX("right")

	self.m_RatingLabel:setVisible(false)
	self.m_Rating:setVisible(false)
	self.m_RatingAdmin:setVisible(false)

	self.m_HideAdmin = GUIGridButton:new(15, 12, 5, 1, "Deaktivieren", self.m_Window)
	self.m_HideAdmin:setVisible(false)
	self.m_HideAdmin.onLeftClick = function()
		QuestionBox:new(_("Möchtest du das Bild von %s deaktivieren?", self.m_SelectedPlayerName),
		function() triggerServerEvent("drawContestHideImage", localPlayer, self.m_SelectedPlayerId) end
	)
	self.m_AddDrawBtn = GUIGridButton:new(21, 12, 5, 1, "eigenes Bild malen", self.m_Window)
	self.m_AddDrawBtn:setVisible(false)
	self.m_AddDrawBtn.onLeftClick = function()
		if self.m_Contest and self.m_ContestType == "draw" then
			DrawContestGUI:new(self.m_Contest)
			delete(self)
		end
	end

	triggerServerEvent("drawContestRequestPlayers", localPlayer)
	addEventHandler("drawContestReceivePlayers", root, bind(self.onReceivePlayers, self))
	addEventHandler("drawingContestReceiveVote", root, bind(self.onReceiveVote, self))


end

function DrawContestOverviewGUI:showInfoText(text)
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

function DrawContestOverviewGUI:hideInfoText()
	if self.m_InfoLabel:getText() == "" then return end

	Animation.FadeAlpha:new(self.m_Background, 250, 200, 0)
	Animation.FadeAlpha:new(self.m_InfoLabel, 250, 255, 0).onFinish =
		function()
			self.m_InfoLabel:setText("")
		end
end

function DrawContestOverviewGUI:onReceivePlayers(contestName, contestType, players)
	self.m_Contest = contestName
	self.m_ContestType = contestType
	self.m_ContestNameLabel:setText(_("Aktuelle Aufgabe: %s", contestName))
	self.m_ContestTypeLabel:setText(_("Aktuelle Phase: %s", contestType == "draw" and "Zeichenphase" or "Abstimmungsphase"))

	if self.m_ContestType == "draw" then
		self.m_AddDrawBtn:setVisible(true)
		self.m_RatingLabel:setVisible(false)
		self.m_Rating:setVisible(false)
		self.m_RatingAdmin:setVisible(false)
	else
		self.m_AddDrawBtn:setVisible(false)
	end

	self.m_PlayersGrid:clear()
	local item
	for id, name in pairs(players) do
		item = self.m_PlayersGrid:addItem(name)
		item.onLeftClick = function()
			if not localPlayer.LastRequest then
				self.m_SelectedPlayerName = name
				self.m_SelectedPlayerId = id
				self.m_Skribble:clear(true)
				self.m_RatingLabel:setVisible(false)
				self.m_Rating:setVisible(false)
				self.m_RatingAdmin:setVisible(false)
				self.m_Rating:reset()
				self:showInfoText("Das Bild wird geladen...")
				localPlayer.LastRequest = true
				triggerServerEvent("drawContestRequestRating", localPlayer, id, contestName)
				fetchRemote(("https://exo-reallife.de/ingame/drawContest/getData.php?playerId=%s&contest=%s"):format(id, contestName), bind(self.onReceiveImage, self))
			else
				WarningBox:new("Bitte warte bis die letzte Anfrage verarbeitet wurde")
			end
		end
	end
end

function DrawContestOverviewGUI:onReceiveVote(rating, admin)
	self.m_Rating:setRating(rating)
	if admin then
		self.m_RatingAdmin:setText(admin)
	end
end

function DrawContestOverviewGUI:onReceiveImage(drawData)
	localPlayer.LastRequest = false
	self:hideInfoText()
	self.m_Skribble:drawSyncData(fromJSON(drawData))

	if localPlayer:getRank() >= RANK.Moderator then
		self.m_HideAdmin:setVisible(false)
	end

	if self.m_ContestType == "vote" then
		self.m_RatingLabel:setVisible(true)
		self.m_Rating:setVisible(true)
		if localPlayer:getRank() >= RANK.Moderator then
			self.m_RatingAdmin:setVisible(true)
		end
	end
end
