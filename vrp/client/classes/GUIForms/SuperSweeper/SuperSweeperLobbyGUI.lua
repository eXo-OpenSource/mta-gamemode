-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SuperSweeperLobbyGUI.lua
-- *  PURPOSE:     Super Sweeper Lobby GUI
-- *
-- ****************************************************************************
SuperSweeperLobbyGUI = inherit(GUIForm)
inherit(Singleton, SuperSweeperLobbyGUI)

addRemoteEvents{"superSweeperOpenLobbyGUI", "superSweeperReceiveLobbys"}

function SuperSweeperLobbyGUI:constructor()
	GUIWindow.updateGrid()			
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Super Sweeper Lobby", true, true, self)
	GUIGridLabel:new(1, 1, 18, 1, _"Warnung: Alle deine Waffen werden beim betreten einer Lobby gelöscht!", self.m_Window):setColor(Color.Red)
	
	self.m_RefreshButton = GUIGridButton:new(19, 1, 1, 1, FontAwesomeSymbols.Refresh, self.m_Window):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function()
		triggerServerEvent("superSweeperRequestLobbys", root)
	end

	self.m_LobbyGrid = GUIGridGridList:new(1, 2, 19, 12, self.m_Window)
	self.m_LobbyGrid:addColumn(_"Name", 0.3)
	self.m_LobbyGrid:addColumn(_"Spieler", 0.1)
	self.m_LobbyGrid:addColumn(_"Status", 0.1)
	self.m_LobbyGrid:addColumn(_"Map", 0.2)
	self.m_LobbyGrid:addColumn(_"Modus", 0.15)
	self.m_LobbyGrid:addColumn(_"PW", 0.15)

	self.m_CreateLobbyButton = GUIGridButton:new(15, 14, 5, 1, _"Lobby erstellen", self.m_Window):setBackgroundColor(Color.Accent):setBarEnabled(true)
	self.m_CreateLobbyButton.onLeftClick = function()
		SuperSweeperCreateLobby:getSingleton():open()
		delete(self)
	end

	self.m_JoinButton = GUIGridButton:new(15, 15, 5, 1, _"Lobby betreten", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_JoinButton.onLeftClick = bind(self.tryJoinLobby, self)

	self.m_PlayerLabel = GUIGridLabel:new(1, 14, 14, 1, "", self.m_Window)

	triggerServerEvent("superSweeperRequestLobbys", root)

	addEventHandler("superSweeperReceiveLobbys", root, bind(self.receiveLobbys, self))
end

function SuperSweeperLobbyGUI:destructor()
	GUIForm.destructor(self)
end

function SuperSweeperLobbyGUI:onShow()
	triggerServerEvent("superSweeperRequestLobbys", localPlayer)
end

function SuperSweeperLobbyGUI:onHide()
end

function SuperSweeperLobbyGUI:receiveLobbys(lobbyTable)
	self.m_LobbyGrid:clear()

	local item, pw
	for id, lobby in pairs(lobbyTable) do
		pw = lobby.password ~= "" and _"Ja" or _"Nein"
		item = self.m_LobbyGrid:addItem(lobby.name, lobby.players, lobby.state == "running" and _"Läuft" or _"Wartend", lobby.map, lobby.mode, pw)
		item.onLeftClick = function()
			self.m_PlayerLabel:setText(_("Spieler: %s", lobby.playerNames))
		end
		item.onLeftDoubleClick = bind(self.tryJoinLobby, self)
		item.Id = id
		item.Password = lobby.password
		item.PlayerNames = lobby.playerNames
	end
end

function SuperSweeperLobbyGUI:joinLobby(lobbyId)
	triggerServerEvent("superSweeperJoinLobby", root, lobbyId)
	delete(self)
end

function SuperSweeperLobbyGUI:tryJoinLobby()
	selectedItem = self.m_LobbyGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		if selectedItem.Password and selectedItem.Password ~= "" then
			InputBox:new(_"Passwort eingeben", _"Diese Lobby ist Passwort geschützt! Gib das Passwort ein:",
				function (password)
					if password == selectedItem.Password then
						self:joinLobby(selectedItem.Id)
					else
						ErrorBox:new(_"Falsches Passwort eingegeben!")
					end
				end
			)
		else
			self:joinLobby(selectedItem.Id)
		end
	else
		ErrorBox:new(_"Keine Lobby ausgewählt")
	end
end


addEventHandler("superSweeperOpenLobbyGUI", root, function()
	SuperSweeperLobbyGUI:new()
end)
