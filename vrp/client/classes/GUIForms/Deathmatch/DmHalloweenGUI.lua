-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DmHalloweenGUI.lua
-- *  PURPOSE:     Deathmatch Lobby GUI
-- *
-- ****************************************************************************
DmHalloweenGUI = inherit(GUIForm)
DmHalloweenGUI.Current = false
inherit(Singleton, DmHalloweenGUI)

addRemoteEvents{"dmHalloweenRefreshGUI", "dmHalloweenCloseGUI"}

function DmHalloweenGUI:constructor(data)
	GUIForm.constructor(self, screenWidth-310, screenHeight-360, 300, 350, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Player vs. Zombie", true, false, self)
	self.m_LobbyGrids = {}
	self.m_LobbyGrids["Bewohner"] = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.38, self.m_Window)
	self.m_LobbyGrids["Bewohner"]:setFont(VRPFont(20))
	self.m_LobbyGrids["Bewohner"]:setItemHeight(20)
	self.m_LobbyGrids["Bewohner"]:addColumn(_"Bewohner", 0.55)
	self.m_LobbyGrids["Bewohner"]:addColumn(_"K", 0.15)
	self.m_LobbyGrids["Bewohner"]:addColumn(_"D", 0.15)
	self.m_LobbyGrids["Bewohner"]:addColumn(_"P", 0.15)

	self.m_LobbyGrids["Zombie"] = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.96, self.m_Height*0.38, self.m_Window)
	self.m_LobbyGrids["Zombie"]:setFont(VRPFont(20))
	self.m_LobbyGrids["Zombie"]:setItemHeight(20)
	self.m_LobbyGrids["Zombie"]:addColumn(_"Zombies", 0.55)
	self.m_LobbyGrids["Zombie"]:addColumn(_"K", 0.15)
	self.m_LobbyGrids["Zombie"]:addColumn(_"D", 0.15)
	self.m_LobbyGrids["Zombie"]:addColumn(_"P", 0.15)

	self.m_LeaveButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Lobby verlassen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_LeaveButton.onLeftClick = bind(self.leaveLobby, self)

	self:refresh(data)
end

function DmHalloweenGUI:destructor()
	GUIForm.destructor(self)
end

function DmHalloweenGUI:leaveLobby()
	if localPlayer:isDead() then
		ErrorBox:new(_"Bitte warte bis du wieder gespawnt bist!")
		return
	end
	triggerServerEvent("deathmatchLeaveLobby", localPlayer)
end

function DmHalloweenGUI:refresh(dataTable)
	local i = 1
	local scoreTable = {}
	for player, data in pairs(dataTable) do
		scoreTable[i] = {}
		scoreTable[i].Name = player:getName()
		scoreTable[i].Kills = data.Kills
		scoreTable[i].Deaths = data.Deaths
		scoreTable[i].Points = data.Kills-data.Deaths
		scoreTable[i].Team = data.Team
		i = i+1
	end

	table.sort(scoreTable,
			function(a, b)
				return a.Points > b.Points
			end
		)

	self.m_LobbyGrids["Bewohner"]:clear()
	self.m_LobbyGrids["Zombie"]:clear()

	for index, value in ipairs(scoreTable) do
		outputChatBox(value.Team)
		local item = self.m_LobbyGrids[value.Team]:addItem(value.Name, value.Kills, value.Deaths, value.Points)
		item:setFont(VRPFont(20))
	end
end

addEventHandler("dmHalloweenRefreshGUI", root, function(data)
	if not DmHalloweenGUI.Current then
		DmHalloweenGUI.Current = DmHalloweenGUI:new(data)
	else
		DmHalloweenGUI.Current:refresh(data)
	end
end)

addEventHandler("dmHalloweenCloseGUI", root, function()
	delete(DmHalloweenGUI:getSingleton())
	DmHalloweenGUI.Current = nil
end)
