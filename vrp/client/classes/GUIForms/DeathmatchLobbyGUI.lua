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

	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, 40+self.m_Height*0.05, self.m_Width*0.96, self.m_Height*0.6, self.m_Window)
	self.m_LobbyGrid:addColumn(_"Name", 0.4)
	self.m_LobbyGrid:addColumn(_"Spieler", 0.2)
	self.m_LobbyGrid:addColumn(_"Map", 0.2)
	self.m_LobbyGrid:addColumn(_"Modus", 0.2)
	self.m_JoinButton = VRPButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.09, self.m_Width*0.3, self.m_Height*0.07, _"Lobby betreten", true, self.m_Window):setBarColor(Color.Green)
	self.m_JoinButton.onLeftClick = bind(self.joinLobby, self)

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
	local item
	for id, lobby in pairs(lobbyTable) do
		item = self.m_LobbyGrid:addItem(lobby.name, lobby.players, lobby.map, lobby.mode)
		item.Id = id
		item.Weapons = lobby.weapons
	end
end

function DeathmatchLobbyGUI:joinLobby()
	selectedItem = self.m_LobbyGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("deathmatchJoinLobby", root, selectedItem.Id)
		delete(self)
	else
		ErrorBox:new(_"Keine Lobby ausgewählt")
	end
end


addEventHandler("deathmatchOpenLobbyGUI", root, function()
	DeathmatchLobbyGUI:new()
end)
