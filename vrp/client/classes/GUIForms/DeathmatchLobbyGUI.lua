-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DeathmatchLobbyGUI.lua
-- *  PURPOSE:     Deathmatch Lobby GUI
-- *
-- ****************************************************************************
DeathmatchLobbyGUI = inherit(GUIForm)
inherit(Singleton, DeathmatchLobbyGUI)

addRemoteEvents{"deathmatchOpenLobbyGUI", "deathmatchReceiveLobbys"}

function DeathmatchLobbyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch Lobby", true, true, self)
	GUILabel:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.05, "Warnung: Alle deine Waffen werden beim betreten einer Lobby gelöscht!", self.m_Window):setColor(Color.Red)
	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, 40+self.m_Height*0.05, self.m_Width*0.96, self.m_Height*0.6, self.m_Window)
	self.m_LobbyGrid:addColumn(_"Name", 0.4)
	self.m_LobbyGrid:addColumn(_"Spieler", 0.1)
	self.m_LobbyGrid:addColumn(_"Map", 0.2)
	self.m_LobbyGrid:addColumn(_"Modus", 0.15)
	self.m_LobbyGrid:addColumn(_"PW", 0.15)
	self.m_CreateLobbyButton = GUIButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.17, self.m_Width*0.3, self.m_Height*0.07, _"Lobby erstellen", self.m_Window):setBackgroundColor(Color.LightBlue):setBarEnabled(true)
	self.m_CreateLobbyButton.onLeftClick = function()
		DeathmatchCreateLobby:getSingleton():open()
		delete(self)
	end

	self.m_JoinButton = GUIButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.09, self.m_Width*0.3, self.m_Height*0.07, _"Lobby betreten", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_JoinButton.onLeftClick = bind(self.tryJoinLobby, self)

	self.m_PlayerLabel = GUILabel:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.17, self.m_Width*0.65, self.m_Height*0.06, "", self.m_Window)
	self.m_WeaponLabel = GUILabel:new(self.m_Width*0.02, self.m_Height-self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.06, "", self.m_Window)

	triggerServerEvent("deathmatchRequestLobbys", root)

	addEventHandler("deathmatchReceiveLobbys", root, bind(self.receiveLobbys, self))
end

function DeathmatchLobbyGUI:destructor()
	GUIForm.destructor(self)
end

function DeathmatchLobbyGUI:onShow()
	triggerServerEvent("deathmatchRequestLobbys", root)
end

function DeathmatchLobbyGUI:onHide()
end

function DeathmatchLobbyGUI:receiveLobbys(lobbyTable)
	local item, pw
	for id, lobby in pairs(lobbyTable) do
		pw = lobby.password ~= "" and "Ja" or "Nein"
		item = self.m_LobbyGrid:addItem(lobby.name, lobby.players, lobby.map, lobby.mode, pw)
		item.onLeftClick = function()
			self.m_PlayerLabel:setText(_("Spieler: %s", lobby.playerNames))
			self.m_WeaponLabel:setText(_("Waffen: %s", lobby.weapons))
		end
		item.onLeftDoubleClick = bind(self.tryJoinLobby, self)
		item.Id = id
		item.Password = lobby.password
		item.PlayerNames = lobby.playerNames
		item.weapons = lobby.weapons
	end
end

function DeathmatchLobbyGUI:joinLobby(lobbyId)
	triggerServerEvent("deathmatchJoinLobby", root, lobbyId)
	delete(self)
end

function DeathmatchLobbyGUI:tryJoinLobby()
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


addEventHandler("deathmatchOpenLobbyGUI", root, function()
	DeathmatchLobbyGUI:new()
end)
