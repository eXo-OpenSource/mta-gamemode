-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WareGUI.lua
-- *  PURPOSE:     Training Lobby GUI
-- *
-- ****************************************************************************
WareGUI = inherit(GUIForm)
inherit(Singleton, WareGUI)
local ware_gui
local MAX_PLAYERS_PER_WARE = 12
addRemoteEvents{"Ware:wareOpenGUI", "Ware:closeGUI"}

function WareGUI:constructor( tbl )
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Mini-Ware", true, true, self)
	GUILabel:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.05, "Warnung: Alle deine Waffen werden beim betreten des Ware-Modes gelöscht!", self.m_Window):setColor(Color.Red)
	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, 40+self.m_Height*0.05, self.m_Width*0.96, self.m_Height*0.6, self.m_Window)
	self.m_LobbyGrid:addColumn(_"ID", 0.2)
	self.m_LobbyGrid:addColumn(_"Spieler", 0.5)
	

	self.m_RefreshButton = GUIButton:new(self.m_Width*0.5-self.m_Width*0.3, self.m_Height-self.m_Height*0.18, self.m_Width*0.6, self.m_Height*0.07, _"Aktualisieren", self.m_Window)
	self.m_RefreshButton.onLeftClick = bind(self.refreshAll, self)

	setElementFrozen(localPlayer, true)
	self:receiveLobbys(tbl)
end

function WareGUI:tryJoinWare()
	local selectedItem = self.m_LobbyGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("Ware:tryJoinLobby", localPlayer, selectedItem.Id)
	end
end


function WareGUI:refreshAll() 
	triggerServerEvent("Ware:refreshGUI", localPlayer)
end

function WareGUI:receiveLobbys(tbl)
	local item, pw
	for id, ware in ipairs(tbl) do
		item = self.m_LobbyGrid:addItem(id, #ware.m_Players.."/"..MAX_PLAYERS_PER_WARE)
		item.onLeftDoubleClick = bind(self.tryJoinWare, self)
		item.Id = id
	end
end

function WareGUI:destructor()
	GUIForm.destructor(self)
	setElementFrozen(localPlayer, false)
end

function WareGUI:onHide()
end

addEventHandler("Ware:wareOpenGUI", root, function(tbl)
	if ware_gui then 
		ware_gui:delete()
	end
	ware_gui = WareGUI:new(tbl)
end)

addEventHandler("Ware:closeGUI", root, function()
	if ware_gui then 
		ware_gui:delete()
	end
end)

