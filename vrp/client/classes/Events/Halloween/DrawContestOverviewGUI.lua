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

	self.m_SelectedPlayerId = 0
	self.m_SelectedPlayerName = ""

	local rating = GUIGridRating:new(6, 11, 5, 1, 5, self.m_Window)
	rating.onChange = function(ratingValue)
		QuestionBox:new(_("Möchtest du das Bild von %s mit %d Stern/en bewerten?", self.m_SelectedPlayerName, ratingValue),
		function() triggerServerEvent("drawContestRateImage", localPlayer, ratingValue) end,
		function() rating:reset() end
	)
	end

	local draw = GUIGridButton:new(21, 11, 5, 1, "eigenes Bild malen", self.m_Window)
	draw.onLeftClick = function()
		DrawContestGUI:new()
		delete(self)
	end

	triggerServerEvent("drawContestRequestPlayers", localPlayer)
	addEventHandler("drawContestReceivePlayers", root, bind(self.onReceivePlayers, self))
	addEventHandler("drawContestReceiveImage", root, bind(self.onReceiveImage, self))
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
			triggerServerEvent("drawContestRequestImage", localPlayer, id)
		end
	end
end

function DrawContestOverviewGUI:onReceiveImage(drawData)
	outputConsole(drawData)
	self.m_Skribble:drawSyncData(fromJSON(drawData))
end
