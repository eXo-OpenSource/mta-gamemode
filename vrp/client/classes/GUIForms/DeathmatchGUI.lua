-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DeathmatchGUI.lua
-- *  PURPOSE:     Deathmatch Lobby GUI
-- *
-- ****************************************************************************
DeathmatchGUI = inherit(GUIForm)
DeathmatchGUI.Current = false
inherit(Singleton, DeathmatchGUI)

addRemoteEvents{"deathmatchRefreshGUI"}

function DeathmatchGUI:constructor(data)
	GUIForm.constructor(self, screenWidth-210, screenHeight-410, 200, 400, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch", true, false, self)

	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.07, self.m_Width*0.96, self.m_Height*0.9+40, self.m_Window)
	self.m_LobbyGrid:addColumn(_"Name", 0.4)
	self.m_LobbyGrid:addColumn(_"Kills", 0.2)
	self.m_LobbyGrid:addColumn(_"Tode", 0.2)
	self.m_LobbyGrid:addColumn(_"Punkte", 0.2)
	self:refresh(data)
end

function DeathmatchGUI:destructor()
	GUIForm.destructor(self)
end

function DeathmatchGUI:refresh(dataTable)
	self.m_LobbyGrid:clear()
	for player, data in pairs(dataTable) do
		self.m_LobbyGrid:addItem(player:getName(), player.Kills, player.Deaths, player.Kills-player.Deaths)
	end
end

addEventHandler("deathmatchRefreshGUI", root, function(data)
	if not DeathmatchGUI.Current then
		DeathmatchGUI.Current = DeathmatchGUI:new(data)
	else
		DeathmatchGUI.Current:refresh(data)
	end
end)

addEventHandler("deathmatchCloseGUI", root, function(data)
	if DeathmatchGUI.Current then
		delete(DeathmatchGUI.Current)
		DeathmatchGUI.Current = false
	end
end)
