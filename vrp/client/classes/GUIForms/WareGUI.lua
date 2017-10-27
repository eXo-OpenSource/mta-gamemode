-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WareGUI.lua
-- *  PURPOSE:     Training Lobby GUI
-- *
-- ****************************************************************************
WareGUI = inherit(GUIForm)
inherit(Singleton, WareGUI)

local MAX_PLAYERS_PER_WARE = 12
addRemoteEvents{"Ware:wareOpenGUI", "Ware:closeGUI"}

function WareGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 15) 	-- width of the window
	self.m_Height = grid("y", 8) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)

	self.m_LobbyGrid = GUIGridGridList:new(1, 1, 14, 7, self.m_Window)
	self.m_LobbyGrid:addColumn("ID", .2)
	self.m_LobbyGrid:addColumn("Spieler", .5)

	local refreshButton = GUIGridIconButton:new(14, 1, FontAwesomeSymbols.Refresh, self.m_Window)
	refreshButton.onLeftClick =
		function()
			triggerServerEvent("Ware:requestLobbys", localPlayer)
		end
end

function WareGUI:receiveLobbys(tbl)
	self.m_LobbyGrid:clear()

	for id, ware in ipairs(tbl) do
		local item = self.m_LobbyGrid:addItem(id, #ware.m_Players.."/"..MAX_PLAYERS_PER_WARE)
		item.onLeftDoubleClick =
			function()
				triggerServerEvent("Ware:tryJoinLobby", localPlayer, id)
			end
	end
end

addEventHandler("Ware:wareOpenGUI", root,
	function(lobbyTable)
		if not WareGUI:isInstantiated() then
			WareGUI:new()
		end

		WareGUI:getSingleton():receiveLobbys(lobbyTable)
	end
)

addEventHandler("Ware:closeGUI", root,
	function()
		if WareGUI:isInstantiated() then
			delete(WareGUI:getSingleton())
		end
	end
)

