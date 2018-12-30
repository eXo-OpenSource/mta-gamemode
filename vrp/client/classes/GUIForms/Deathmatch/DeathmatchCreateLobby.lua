-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DeathmatchCreateLobby.lua
-- *  PURPOSE:     Deathmatch Create Lobby GUI
-- *
-- ****************************************************************************
DeathmatchCreateLobby = inherit(GUIForm)
inherit(Singleton, DeathmatchCreateLobby)

addRemoteEvents{"deathmatchReceiveCreateData"}


function DeathmatchCreateLobby:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch-Lobby erstellen", true, true, self)
	self.m_Window:addBackButton(function () DeathmatchLobbyGUI:getSingleton():show() end)
	GUILabel:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.05, "Warnung: Die Lobby wird gelöscht sobald kein Spieler mehr darin spielt!", self.m_Window):setColor(Color.Red)

	GUILabel:new(self.m_Width*0.02, 40+self.m_Height*0.05, self.m_Width*0.25, self.m_Height*0.07, "Map:", self.m_Window)
	self.m_MapChanger = GUIChanger:new(self.m_Width*0.02+self.m_Width*0.25, 40+self.m_Height*0.05, self.m_Width*0.35, self.m_Height*0.07, self.m_Window)

	GUILabel:new(self.m_Width*0.02, 40+self.m_Height*0.13, self.m_Width*0.25, self.m_Height*0.07, "Waffe:", self.m_Window)
	self.m_WeaponChanger = GUIChanger:new(self.m_Width*0.02+self.m_Width*0.25, 40+self.m_Height*0.13, self.m_Width*0.35, self.m_Height*0.07, self.m_Window)

	GUILabel:new(self.m_Width*0.02, 40+self.m_Height*0.21, self.m_Width*0.25, self.m_Height*0.07, "Passwort:", self.m_Window)
	self.m_Password = GUIEdit:new(self.m_Width*0.02+self.m_Width*0.25, 40+self.m_Height*0.21, self.m_Width*0.35, self.m_Height*0.07, self.m_Window)

	self.m_Create = GUIButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.09, self.m_Width*0.3, self.m_Height*0.07, _"Erstellen (500$)", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_Create.onLeftClick = bind(self.createLobby, self)

	addEventHandler("deathmatchReceiveCreateData", root, bind(self.receiveData, self))
end

function DeathmatchCreateLobby:destructor()
	GUIForm.destructor(self)
end

function DeathmatchCreateLobby:onShow()
	triggerServerEvent("deathmatchRequestCreateData", root)
end

function DeathmatchCreateLobby:onHide()
end

function DeathmatchCreateLobby:createLobby()
	local map = self.m_MapNames[self.m_MapChanger:getSelectedItem()]
	local weapon = self.m_WeaponNames[self.m_WeaponChanger:getSelectedItem()]
	local password = self.m_Password:getText() or ""
	triggerServerEvent("deathmatchCreateLobby", localPlayer, map, weapon, password)
	delete(self)
end

function DeathmatchCreateLobby:receiveData(maps, weapons)
	self.m_MapNames = {}
	for index, mapData in pairs(maps) do
		self.m_MapNames[mapData["Name"]] = index
		self.m_MapChanger:addItem(mapData["Name"])
	end

	self.m_WeaponNames = {}
	for index, weaponId in pairs(weapons) do
		self.m_WeaponNames[WEAPON_NAMES[weaponId]] = weaponId
		self.m_WeaponChanger:addItem(WEAPON_NAMES[weaponId])
	end
end
