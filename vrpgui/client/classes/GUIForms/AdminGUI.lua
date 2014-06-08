-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI
-- *
-- ****************************************************************************
AdminGUI = inherit(GUIForm)
inherit(Singleton, AdminGUI)

--[[
Player:
Kick, Ban, Freeze, Goto, Gethere, Set Pos, Set Interior, Set Dimension, Set Job, Set Money, Set Karma, Set XP, Screenshot, 
Kill, Fahrzeug list, Repair, Flip, Delete, Respawn, Spectate, Mute, Waffen, Inventar, Jail / Unjail, Gruppe
 Anticheat Browser, 

Vehicle:
Create Vehicle, Goto Car, Get Car, Respawn All Cars, Fahrzeug list, Repair, Flip, Delete, Respawn

Gruppen
Gruppe Find

General:
Globalchat toggle, Adminchat, Wetter, Zeit
ServerPW setzen, Disable / Enable Job, Disable / Enable Event, 
]]

function AdminGUI:constructor()
	local sw, sh = guiGetScreenSize()
	local width, height = sw*0.6, sh*0.6

	GUIForm.constructor(self, (sw-width)/2, (sh-height)/2, width, height + height*0.1)
	self.m_GeneralButton 		= VRPButton:new(0, 0, width/4, height*0.1, "Allgemein", false, self)
	self.m_PlayerButton 		= VRPButton:new(width/4, 0, width/4, height*0.1, "Spieler", false, self)
	self.m_VehiclesButton 		= VRPButton:new(width/4*2, 0, width/4, height*0.1, "Fahrzeuge", false, self)
	self.m_GroupsButton 		= VRPButton:new(width/4*3, 0, width/4, height*0.1, "Gruppen", false, self)
	
	self.m_GeneralTab 			= GUIRectangle:new(0, height*0.1, width, height, tocolor(0, 0, 0, 128), self)
	GUILabel:new(30, 30, 100, 25, "Wetter", self.m_GeneralTab)
	GUILabel:new(120, 30, 160, 25, "Sunny (1)", self.m_GeneralTab):setAlignX("center")
	self.m_WeatherPrev 			= GUIButton:new(100, 30, height*0.05, height*0.05, "<", self.m_GeneralTab)
	self.m_WeatherNext 			= GUIButton:new(280, 30, height*0.05, height*0.05, ">", self.m_GeneralTab)
	GUILabel:new(30, 60, 100, 25, "Zeit", self.m_GeneralTab)
	GUILabel:new(120, 60, 160, 25, "01:00", self.m_GeneralTab):setAlignX("center")
	self.m_TimePrev 			= GUIButton:new(100, 60, height*0.05, height*0.05, "<", self.m_GeneralTab)
	self.m_TimeNext 			= GUIButton:new(280, 60, height*0.05, height*0.05, ">", self.m_GeneralTab)
	GUILabel:new(30, 90, 100, 25, "Passwort", self.m_GeneralTab)
	GUIEdit:new(100, 90, 160, 30, self.m_GeneralTab)
	self.m_SetPassword = GUIButton:new(265, 90, 35, 30, "✔", self.m_GeneralTab)
	GUIButton:new(30, 130, 270, 25, "Global Chat [An]", self.m_GeneralTab)
	
	GUILabel:new(30, 180, 270, 30, "Jobs", self.m_GeneralTab)
	GUIButton:new(30, 210, 270, 25, "Farmer Job [An]", self.m_GeneralTab)
	GUIButton:new(30, 240, 270, 25, "Bankraub [An]", self.m_GeneralTab)
	
	-- Player Tab
	self.m_GeneralTab:hide()
	
	self.m_PlayerTab = GUIRectangle:new(0, height*0.1, width, height, tocolor(0, 0, 0, 128), self)
	self.m_PlayerList = GUIGridList:new(30, 55, 200, height-55-30, self.m_PlayerTab)
	self.m_PlayerList.onSelectItem = bind(AdminGUI.onSelectPlayer, self)
	GUIEdit:new(30, 20, 200, 30, self.m_PlayerTab)
	
	self.m_PlayerList:addColumn("Spieler", 200)
	self.m_PlayerList:addItem("sbx320")
	self.m_PlayerList:addItem("Doneasty")
	self.m_PlayerList:addItem("Jusonex")
	
	GUILabel:new(250, 30, 300, 30, "sbx320 (1)", self.m_PlayerTab)
	GUILabel:new(260, 60, 300, 25, "Geld: 500$", self.m_PlayerTab)
	GUILabel:new(260, 85, 300, 25, "Bankkonto: 500$", self.m_PlayerTab)
	GUILabel:new(260, 110, 300, 25, "Job: Farmer", self.m_PlayerTab)
	GUILabel:new(260, 135, 300, 25, "Gruppe: VRP Dev", self.m_PlayerTab)
	GUILabel:new(260, 160, 300, 25, "Karma: +17", self.m_PlayerTab)
	GUILabel:new(260, 185, 300, 25, "XP: 1337", self.m_PlayerTab)
	GUILabel:new(260, 210, 300, 25, "Wantedlevel: 12", self.m_PlayerTab)
	
	GUIButton:new(400, 60, 100, 20, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Geld", "SetMoney")
	GUIButton:new(400, 85, 100, 20, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Bankkonto", "SetBankMoney")
	GUIButton:new(400, 110, 100, 20, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Job", "SetJob")
	GUIButton:new(400, 135, 100, 20, "Ändern", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerEditGroup, self)
	GUIButton:new(400, 160, 100, 20, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Karma", "SetKarma")
	GUIButton:new(400, 185, 100, 20, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "XP", "SetXP")
	GUIButton:new(400, 210, 100, 25, "Setzen", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Wantedlevel", "SetWanted")
	GUIButton:new(260, 250, 100, 25, "Kick", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerYesNoReason, self, "kicken", "Kick")
	GUIButton:new(370, 250, 100, 25, "Ban", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerYesNoReason, self, "bannen", "Ban")
	GUIButton:new(260, 280, 100, 25, "Mute", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerYesNoReason, self, "muten", "Mute")
	GUIButton:new(370, 280, 100, 25, "Freeze", self.m_PlayerTab)
	GUIButton:new(260, 310, 100, 25, "Jail", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerYesNoReason, self, "jailen", "Jail")
	GUIButton:new(370, 310, 100, 25, "Kill", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerYesNo, self, "killen", "Kill")
	GUIButton:new(260, 350, 100, 25, "Repair", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerRepairVehicle, self, "FixVehicle")
	GUIButton:new(370, 350, 100, 25, "Flip", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerFlipVehicle, self, "FlipVehicle")

	GUIButton:new(510, 60, 200, 20, "Dimension", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Dimension", "SetDimension")
	GUIButton:new(510, 85, 200, 20, "Interior", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSet, self, "Interior", "SetInterior")
	GUIButton:new(510, 110, 200, 20, "Position", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSetPosition, self, "SetPosition")
	GUIButton:new(510, 135, 95, 20, "Goto", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerGoto, self)
	GUIButton:new(620, 135, 90, 20, "Get here", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerGetHere, self)
	GUIButton:new(510, 160, 200, 20, "Inventar", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerEditInventory, self)
	GUIButton:new(510, 185, 200, 20, "Fahrzeuge", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerEditVehicles, self)
	GUIButton:new(510, 210, 200, 20, "Spectate", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerSpectate, self)
	GUIButton:new(510, 250, 200, 20, "Anticheat", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerAntiCheat, self)
	GUIButton:new(510, 275, 200, 20, "Screenshot", self.m_PlayerTab).onLeftClick = bind(AdminGUI.playerScreenshot, self)
	
	--self.m_PlayerTab:hide()
	
	self.m_VehicleTab = GUIRectangle:new(0, height*0.1, width, height, tocolor(0, 0, 0, 128), self)
	self.m_VehicleList = GUIGridList:new(30, 55, 200, height-55-30, self.m_VehicleTab)
	GUIEdit:new(30, 20, 35, 30, self.m_VehicleTab)
	GUIEdit:new(70, 20, 160, 30, self.m_VehicleTab)
	
	self.m_VehicleList:addColumn("Id", 20)
	self.m_VehicleList:addColumn("Model", 50)
	self.m_VehicleList:addColumn("Besitzer", 130)
	self.m_VehicleList:addItem("1", "Infernus", "sbx320")
	self.m_VehicleList:addItem("2", "Blista Compact", "Doneasty")
	self.m_VehicleList:addItem("3", "Rhino", "sbx320")
	
	GUILabel:new(250, 30, 300, 30, "Rhino (1)", self.m_VehicleTab)
	GUILabel:new(260, 60, 300, 25, "Besitzer: sbx320", self.m_VehicleTab)
	GUILabel:new(260, 85, 300, 25, "Energie: 1000", self.m_VehicleTab)
	GUILabel:new(260, 110, 300, 25, "Tank: 50%", self.m_VehicleTab)
	
	GUIButton:new(400, 60, 100, 20, "Setzen", self.m_VehicleTab)
	GUIButton:new(400, 85, 100, 20, "Setzen", self.m_VehicleTab)
	GUIButton:new(400, 110, 100, 20, "Setzen", self.m_VehicleTab)
	GUIButton:new(260, 280, 100, 25, "Delete", self.m_VehicleTab)
	GUIButton:new(370, 280, 100, 25, "Freeze", self.m_VehicleTab)
	GUIButton:new(260, 310, 100, 25, "Respawn", self.m_VehicleTab)
	GUIButton:new(370, 310, 100, 25, "Foo", self.m_VehicleTab)
	GUIButton:new(260, 350, 100, 25, "Repair", self.m_VehicleTab)
	GUIButton:new(370, 350, 100, 25, "Flip", self.m_VehicleTab)	

	GUIButton:new(510, 60, 200, 20, "Dimension", self.m_VehicleTab)
	GUIButton:new(510, 85, 200, 20, "Interior", self.m_VehicleTab)
	GUIButton:new(510, 110, 200, 20, "Position", self.m_VehicleTab)
	GUIButton:new(510, 135, 95, 20, "Goto", self.m_VehicleTab)
	GUIButton:new(620, 135, 90, 20, "Get here", self.m_VehicleTab)
	GUIButton:new(510, 160, 200, 20, "Inventar", self.m_VehicleTab)
	GUIButton:new(510, 210, 200, 20, "Spectate", self.m_VehicleTab)
	
		
	self.m_VehicleTab:hide()
	--[[
	Kick, Ban, Freeze, Goto, Gethere, Set Pos, Set Interior, Set Dimension, Set Job, Set Money, Set Karma, Set XP, Screenshot, 
Kill, Fahrzeug list, Repair, Flip, Delete, Respawn, Spectate, Mute, Waffen, Inventar, Jail / Unjail, Gruppe
 Anticheat Browser, 
 ]]
end

function AdminGUI:onSelectPlayer(item)
	local name = item:getColumnText(1)
	self:selectPlayer(getPlayerFromName(name))
end

function AdminGUI:selectPlayer(player)
	self.m_SelectedPlayer = player
end

function AdminGUI:preparePrompt()
	if not self.m_SelectedPlayer then
		self:selectPlayer(false)
		return false
	end
	if self.m_PromptWindow then
		self.m_PromptWindow:delete()
	end
	return true
end

function AdminGUI:makeCall(call, ...)
	triggerServerEvent("AdminGUICall", root, ...)
end

function AdminGUI:playerSet(key, call, gui)
	if not self:preparePrompt() then return end
	
	local sw, sh = guiGetScreenSize()
	self.m_PromptWindow = CacheArea:new(sw/2-sw/6, sh/3, sw/3, sh/4)
	GUIRectangle:new(0, 0, sw/3, sh/4, tocolor(0, 0, 0, 200), self.m_PromptWindow)
	VRPButton:new(0, 0, sw/3, sh/20, ("%s von %s setzen"):format(key, getPlayerName(self.m_SelectedPlayer)), false, self.m_PromptWindow)
	GUILabel:new(sw/3*0.05, sh/3*0.25, 300, 30, "Aktuell: 1212", self.m_PromptWindow)
	GUILabel:new(sw/3*0.05, sh/3*0.375, 300, 30, "Neu: ", self.m_PromptWindow)
	GUIEdit:new(sw/3*0.25, sh/3*0.375, sw/3-sw/3*0.05-sw/3*0.25, 25, self.m_PromptWindow)
	
	GUIButton:new(sw/6-190, sh/4-sh/20, 150, 20, "Setzen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.makeCall(call, self.m_SelectedPlayer, tonumber(self.m_PromptData:getText())))
	GUIButton:new(sw/6+10, sh/4-sh/20, 150, 20, "Abbrechen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.preparePrompt, self)
end

function AdminGUI:playerYesNo(action, call, gui)
	if not self:preparePrompt() then return end
	
	local sw, sh = guiGetScreenSize()
	self.m_PromptWindow = CacheArea:new(sw/2-sw/6, sh/3, sw/3, sh/4)
	GUIRectangle:new(0, 0, sw/3, sh/4, tocolor(0, 0, 0, 200), self.m_PromptWindow)
	VRPButton:new(0, 0, sw/3, sh/20, ("%s %s"):format(getPlayerName(self.m_SelectedPlayer), action), false, self.m_PromptWindow)
	GUIButton:new(sw/6-190, sh/4-sh/20, 150, 20, "Bestätigen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.makeCall(call, self.m_SelectedPlayer))
	GUIButton:new(sw/6+10, sh/4-sh/20, 150, 20, "Abbrechen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.preparePrompt, self)
end

function AdminGUI:playerYesNoReason(action, call, gui)
	if not self:preparePrompt() then return end
	
	local sw, sh = guiGetScreenSize()
	self.m_PromptWindow = CacheArea:new(sw/2-sw/6, sh/3, sw/3, sh/4)
	GUIRectangle:new(0, 0, sw/3, sh/4, tocolor(0, 0, 0, 200), self.m_PromptWindow)
	VRPButton:new(0, 0, sw/3, sh/20, ("%s %s"):format(getPlayerName(self.m_SelectedPlayer), action), false, self.m_PromptWindow)
	
	GUILabel:new(sw/3*0.05, sh/3*0.375, 300, 30, "Grund: ", self.m_PromptWindow)
	self.m_PromptReason = GUIEdit:new(sw/3*0.25, sh/3*0.375, sw/3-sw/3*0.05-sw/3*0.25, 25, self.m_PromptWindow)
	
	GUIButton:new(sw/6-190, sh/4-sh/20, 150, 20, "Bestätigen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.makeCall(call, self.m_SelectedPlayer, self.m_PromptReason:getText()))
	GUIButton:new(sw/6+10, sh/4-sh/20, 150, 20, "Abbrechen", self.m_PromptWindow).onLeftClick = bind(AdminGUI.preparePrompt, self)
end

function AdminGUI:playerRepairVehicle()
end
function AdminGUI:playerFlipVehicle()
end
function AdminGUI:playerEditGroup()
end
function AdminGUI:playerEditInventory()
end
function AdminGUI:playerEditVehicles()
end
function AdminGUI:playerGoto()
end
function AdminGUI:playerSetPosition()
end
function AdminGUI:playerGetHere()
end
function AdminGUI:playerSpectate()
end
function AdminGUI:playerAntiCheat()
end
function AdminGUI:playerScreenshot()
end
