-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RaceCreateLobby.lua
-- *  PURPOSE:     Race Create Lobby GUI
-- *
-- ****************************************************************************
RaceCreateLobbyGUI = inherit(GUIForm)
inherit(Singleton, RaceCreateLobbyGUI)

function RaceCreateLobbyGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 6) 
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, self.m_Width, self.m_Height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Sitzung erstellen", true, false, self)

	GUIGridLabel:new(1, 1, 16, 1, "Warnung: Die Lobby wird gelöscht sobald kein Spieler mehr darin spielt!", self.m_Window)

	self.m_MapChanger = GUIGridChanger:new(2, 2, 13, 1, self.m_Window)
	:addItem("Karte auswählen")

	GUIGridRectangle:new(2, 3, 13, 1, Color.Grey, self.m_Window)
	GUIGridLabel:new(3, 3, 11, 1, "Passwort der Lobby", self.m_Window)
	self.m_Password = GUIGridEdit:new(9, 3, 6, 1, self.m_Window)

	self.m_CreateSolo = GUIGridButton:new(2, 5, 7, 1, _"Zeitrennen (Solo) (100$)", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_CreateSolo.onLeftClick = bind(self.createLobby, self)

	self.m_CreateFree = GUIGridButton:new(9, 5, 7, 1, _"Freeroam (500$)", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_CreateFree.onLeftClick = bind(self.createLobby, self)

	self.m_DestroyVehicle = true	
	--addEventHandler("deathmatchReceiveCreateData", root, bind(self.receiveData, self))
end

function RaceCreateLobbyGUI:destructor()
	if self.m_DestroyVehicle then
		if self.m_CamDrive then 
			self.m_CamDrive:delete()
		end
		if self.m_PreviewVehicle then 
			self.m_PreviewVehicle:destroy()
		end
	end
	self:close()
	GUIForm.destructor(self)
end

function RaceCreateLobbyGUI:setup(camDrive, previewVehicle) 
	self.m_CamDrive = camDrive 
	self.m_PreviewVehicle = previewVehicle 
	self.m_DestroyVehicle = false
	self.m_Window:addBackButton(function ()
		self.m_DestroyVehicle = false
		RaceLobbyGUI:getSingleton():setup(self.m_CamDrive, self.m_PreviewVehicle)
		RaceLobbyGUI:getSingleton():show()
	end)
end

function RaceCreateLobbyGUI:onShow()
	--triggerServerEvent("deathmatchRequestCreateData", root)
end

function RaceCreateLobbyGUI:onHide()
end

function RaceCreateLobbyGUI:createLobby()
	local map = self.m_MapNames[self.m_MapChanger:getSelectedItem()]
	local weapon = self.m_WeaponNames[self.m_WeaponChanger:getSelectedItem()]
	local password = self.m_Password:getText() or ""
	triggerServerEvent("RaceCreateLobby", localPlayer, map, weapon, password)
	delete(self)
end

function RaceCreateLobbyGUI:receiveData(maps, weapons)
	self.m_MapNames = {}
	for index, mapData in pairs(maps) do
		self.m_MapNames[mapData["Name"]] = index
		self.m_MapChanger:addItem(mapData["Name"])
	end
end

function RaceCreateLobbyGUI:isBackgroundBlurred()
	return true
end
