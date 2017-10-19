-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
DrawContestOverviewGUI = inherit(GUIForm)
inherit(Singleton, DrawContestOverviewGUI)

addRemoteEvents{"drawContestReceivePlayers", "drawContestReceiveImage"}

function DrawContestOverviewGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 26)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Halloween Zeichenwettbewerb", true, true, self)

	self.m_PlayersGrid = GUIGridGridList:new(1, 1, 5, 14, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Zeichnungen", 1)

	self.m_Skribble = GUIGridSkribble:new(6, 1, 20, 10, self.m_Window)
	self.m_Background = GUIGridRectangle:new(6, 1, 20, 10, Color.Clear, self.m_Window)
	self.m_InfoLabel = GUIGridLabel:new(6, 1, 20, 10, "", self.m_Window):setAlign("center", "center"):setFont(VRPFont(50)):setAlpha(0)

	self.m_SelectedPlayerId = 0
	self.m_SelectedPlayerName = ""

	self:showInfoText("eXo-Reallife Halloween Zeichen-Wettbewerb!\nMale ein Bild zum angegeben Thema.\n(Jeder User darf nur ein Bild pro Thema einsenden)\nEinem Tag nach Einsendeschluss können User das Bild bewerten.\nZu Gewinnen gibt es bei jedem Wettbewerb 15 eXo-Dollar!")

	self.m_Rating = GUIGridRating:new(6, 11, 5, 1, 5, self.m_Window)
	self.m_Rating.onChange = function(ratingValue)
		QuestionBox:new(_("Möchtest du das Bild von %s mit %d Stern/en bewerten?", self.m_SelectedPlayerName, ratingValue),
		function() triggerServerEvent("drawContestRateImage", localPlayer, ratingValue) end,
		function() self.m_Rating:reset() end
	)
	end

	self.m_Rating:setVisible(false)

	local draw = GUIGridButton:new(21, 11, 5, 1, "eigenes Bild malen", self.m_Window)
	draw.onLeftClick = function()
		DrawContestGUI:new()
		delete(self)
	end

	triggerServerEvent("drawContestRequestPlayers", localPlayer)
	addEventHandler("drawContestReceivePlayers", root, bind(self.onReceivePlayers, self))
	addEventHandler("drawContestReceiveImage", root, bind(self.onReceiveImage, self))
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

function DrawContestOverviewGUI:onReceivePlayers(players)
	self.m_PlayersGrid:clear()
	local item
	for id, name in pairs(players) do
		item = self.m_PlayersGrid:addItem(name)
		item.onLeftClick = function()
			self.m_SelectedPlayerName = name
			self.m_SelectedPlayerId = id
			self.m_Skribble:clear(true)
			self.m_Rating:setVisible(false)
			self:showInfoText("Das Bild wird geladen...")
			triggerServerEvent("drawContestRequestImage", localPlayer, id)
		end
	end
end

function DrawContestOverviewGUI:onReceiveImage(drawData)
	self:hideInfoText()
	self.m_Rating:setVisible(true)
	self.m_Skribble:drawSyncData(fromJSON(drawData))
end
