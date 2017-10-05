-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleLobbyGUI = inherit(GUIForm)
inherit(Singleton, SkribbleLobbyGUI)
addRemoteEvents{"skribbleReceiveLobbys"}

function SkribbleLobbyGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Skribble Lobby", true, true, self)

	self.m_LobbyGrid = GUIGridGridList:new(1, 1, 15, 10, self.m_Window)
	self.m_LobbyGrid:addColumn(_"", .025)
	self.m_LobbyGrid:addColumn(_"Name", .375)
	self.m_LobbyGrid:addColumn(_"Ersteller", .2)
	self.m_LobbyGrid:addColumn(_"Spieler", .2)
	self.m_LobbyGrid:addColumn(_"Runde", .1)

	local refreshButton = GUIGridIconButton:new(15, 1, FontAwesomeSymbols.Refresh, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Clear)
	refreshButton.onLeftClick =
		function()
			triggerServerEvent("skribbleRequestLobbys", localPlayer)
		end

	GUIGridButton:new(1, 11, 5, 1, "Lobby erstellen", self.m_Window):setBackgroundColor(Color.Red).onLeftClick =
		function()
			delete(self)
			SkribbleLobbyCreateGUI:new()
		end

	GUIGridButton:new(11, 11, 5, 1, "Lobby betreten", self.m_Window).onLeftClick =
		function()
			local selectedItem = self.m_LobbyGrid:getSelectedItem()
			if not selectedItem then return end
			triggerServerEvent("skribbleJoinLobby", localPlayer, selectedItem.Id)
		end

	self.m_ReceiveLobbys = bind(SkribbleLobbyGUI.receiveLobbys, self)
	addEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)

	triggerServerEvent("skribbleRequestLobbys", localPlayer)
end

function SkribbleLobbyGUI:virtual_destructor()
	removeEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)
end

function SkribbleLobbyGUI:receiveLobbys(lobbys)
	self.m_LobbyGrid:clear()

	for id, lobby in pairs(lobbys) do
		local item = self.m_LobbyGrid:addItem(lobby.password ~= "" and FontAwesomeSymbols.Lock or FontAwesomeSymbols.Group, lobby.name, lobby.owner:getName(), lobby.players, ("%s/%s"):format(lobby.currentRound, lobby.rounds))
		item:setColumnFont(1, FontAwesome(25), 1):setColumnColor(1, lobby.password ~= "" and Color.Red or Color.Green)
		item.Id = id
	end
end

------------------------------------------------------------------------------------------------------------------------
SkribbleLobbyCreateGUI = inherit(GUIForm)
inherit(Singleton, SkribbleLobbyCreateGUI)

function SkribbleLobbyCreateGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 5)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Skribble Lobby erstellen", true, true, self)

	GUIGridLabel:new(1, 1, 3, 1, "Name:", self.m_Window)
	GUIGridLabel:new(1, 2, 3, 1, "Passwort:", self.m_Window)
	GUIGridLabel:new(1, 3, 3, 1, "Runden:", self.m_Window)

	self.m_Name = GUIGridEdit:new(3, 1, 5, 1, self.m_Window)
	self.m_Password = GUIGridEdit:new(3, 2, 5, 1, self.m_Window):setMasked():setTooltip("Leer lassen für eine öffentliche Lobby!", "right")
	self.m_Rounds = GUIGridChanger:new(3, 3, 5, 1, self.m_Window)
	self.m_Rounds:addItem(3)
	self.m_Rounds:addItem(5)
	self.m_Rounds:addItem(10)

	GUIGridButton:new(1, 4, 7, 1, "Erstellen", self.m_Window).onLeftClick =
		function()
			triggerServerEvent("skribbleCreateLobby", localPlayer, self.m_Name:getText(), self.m_Password:getText(), self.m_Rounds:getSelectedItem())
			delete(self)
		end
end
