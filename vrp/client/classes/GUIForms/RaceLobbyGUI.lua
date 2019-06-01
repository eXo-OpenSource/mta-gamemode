-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RaceLobbyGUI.lua
-- *  PURPOSE:     Race Lobby GUI
-- *
-- ****************************************************************************
RaceLobbyGUI = inherit(GUIForm)
inherit(Singleton, RaceLobbyGUI)

RaceLobbyGUI.PreviewPosition =
{
	{1, 1387.68, -23.05, 1000.73, 0, 0,  235.46, 1390.58, -23.80, 1001.92, 1393.50, -34.33, 1001.91}
}

function RaceLobbyGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, self.m_Width, self.m_Height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Rennstrecke", true, true, self)
	GUIGridLabel:new(1, 1, 16, 1, "Warnung: Alle deine Waffen werden beim betreten einer Lobby gelöscht!", self.m_Window)
	self.m_LobbyGrid = GUIGridGridList:new(1, 2, 15, 8, self.m_Window)
	self.m_LobbyGrid:addColumn(_"Name", 0.4)
	self.m_LobbyGrid:addColumn(_"Map", 0.2)
	self.m_LobbyGrid:addColumn(_"Passwort", 0.15)
	self.m_CreateLobbyButton = GUIGridButton:new(12, 11, 4, 1, _"Lobby erstellen", self.m_Window):setBackgroundColor(Color.LightBlue):setBarEnabled(true)
	self.m_CreateLobbyButton.onLeftClick = function()
		self.m_DestroyVehicle = false
		RaceCreateLobbyGUI:getSingleton():setup(self.m_CamDrive, self.m_PreviewVehicle)
		RaceCreateLobbyGUI:getSingleton():open()
		delete(self)
	end

	self.m_JoinButton = GUIGridButton:new(12, 10, 4, 1, _"Lobby betreten", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)


	GUIGridRectangle:new(1,10, 10, 1, Color.Grey, self.m_Window)
	GUIGridRectangle:new(1,11, 10, 1, Color.Grey, self.m_Window)

	GUIGridIconButton:new(1, 10, FontAwesomeSymbols.Comment, self.m_Window)
	self.m_NameLabel = GUIGridLabel:new(1, 10, 10, 1, "Keine ausgewählt", self.m_Window)
	:setAlignX("center")

	GUIGridIconButton:new(1, 11, FontAwesomeSymbols.Book, self.m_Window)
	self.m_MapLabel = GUIGridLabel:new(1, 11, 10, 1, "Keine ausgewählt", self.m_Window)
	:setAlignX("center")

	self.m_Dimension = PRIVATE_DIMENSION_CLIENT
	self.m_DestroyVehicle = true
end

function RaceLobbyGUI:virtual_destructor()
	if self.m_DestroyVehicle then
		if self.m_CamDrive then
			self.m_CamDrive:delete()
		end
		if self.m_PreviewVehicle and isElement(self.m_PreviewVehicle) then
			destroyElement(self.m_PreviewVehicle)
		end
	end
	self:close()
end

function RaceLobbyGUI:setup(cameraDrive, previewVehicle)
	self.m_CamDrive = cameraDrive
	self.m_PreviewVehicle = previewVehicle
	self:Event_GetLobbyData({}, localPlayer.vehicle)
end

function RaceLobbyGUI:receiveLobbys(lobbyTable)
	local item, pw
	for id, lobby in pairs(lobbyTable) do
		item = self.m_LobbyGrid:addItem(lobby.name, lobby.map, pw)
		item.onLeftClick = function()
			self.m_NameLabel:setText(_("Name: %s", lobby.playerNames))
			self.m_MapLabel:setText(_("Strecke: %s", lobby.weapons))
		end
		item.onLeftDoubleClick = bind(self.tryJoinLobby, self)
		item.Id = id
		item.Password = lobby.m_Password
		item.Name = lobby.m_Name
		item.Map = lobby.m_Map
	end
end

function RaceLobbyGUI:joinLobby(lobbyId)
	--triggerServerEvent("deathmatchJoinLobby", root, lobbyId)
	delete(self)
end

function RaceLobbyGUI:Event_GetLobbyData( data )
	if not self.m_CamDrive and not self.m_PreviewVehicle then
		local int, x, y, z, rx, ry, rz, px, py, pz, lx, ly, lz  = unpack(RaceLobbyGUI.PreviewPosition[1])
		setCameraInterior(int)
		local vehicle = createVehicle(496, x, y, z)
		localPlayer:setInterior(int)
		localPlayer:setFrozen(true)
		vehicle:setInterior(int)
		vehicle:setPosition(x, y, z)
		vehicle:setRotation(rx, ry, rz)
		vehicle:setFrozen(true)
		vehicle:setLocked(true)
		vehicle:setColor(255, 255, 255, 0, 0, 0)
		vehicle:addUpgrade(1006)
		vehicle:addUpgrade(1001)
		vehicle:addUpgrade(1142)
		setVehicleOverrideLights(vehicle, 2)
		self.m_PreviewVehicle = vehicle
		self.m_CamDrive = cameraDrive:new(px, py, pz, x, y, z, lx, ly, lz, x, y, z, 400000, "Linear" )
		self.m_CamDrive:setRoll(10)
	end
end

function RaceLobbyGUI:tryJoinLobby()
	local selectedItem = self.m_LobbyGrid:getSelectedItem()
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


function RaceLobbyGUI:isBackgroundBlurred()
	return false
end
