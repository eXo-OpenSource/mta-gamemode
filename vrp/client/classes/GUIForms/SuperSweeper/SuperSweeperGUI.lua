-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DeathmatchGUI.lua
-- *  PURPOSE:     Deathmatch Lobby GUI
-- *
-- ****************************************************************************
SuperSweeperGUI = inherit(GUIForm)
SuperSweeperGUI.Current = false
inherit(Singleton, SuperSweeperGUI)

addRemoteEvents{"superSweeperRefreshGUI", "superSweeperCloseGUI"}

function SuperSweeperGUI:constructor(data)
	GUIForm.constructor(self, screenWidth-310, screenHeight-360, 300, 350, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Super Sweeper", true, false, self)

	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.8, self.m_Window)
	self.m_LobbyGrid:setFont(VRPFont(20))
	self.m_LobbyGrid:setItemHeight(20)
	self.m_LobbyGrid:addColumn(_"Name", 0.55)
	self.m_LobbyGrid:addColumn(_"K", 0.15)
	self.m_LobbyGrid:addColumn(_"D", 0.15)
	self.m_LobbyGrid:addColumn(_"P", 0.15)

	self.m_LeaveButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Lobby verlassen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_LeaveButton.onLeftClick = bind(self.leaveLobby, self)

	SuperSweeperManager.CurrentGUI = self

	self:refresh(data)
end

function SuperSweeperGUI:destructor()
	GUIForm.destructor(self)
	SuperSweeperManager.CurrentGUI = false
end

function SuperSweeperGUI:leaveLobby()
	if localPlayer:isDead() then
		ErrorBox:new(_"Bitte warte bis du wieder gespawnt bist!")
		return
	end
	triggerServerEvent("superSweeperLeaveLobby", localPlayer)
end

function SuperSweeperGUI:refresh(dataTable)
	local i = 1
	local scoreTable = {}
	for player, data in pairs(dataTable) do
		scoreTable[i] = {}
		scoreTable[i].Name = player:getName()
		scoreTable[i].Kills = data.Kills
		scoreTable[i].Deaths = data.Deaths
		scoreTable[i].Points = data.Kills-data.Deaths
		i = i+1
	end

	table.sort(scoreTable,
			function(a, b)
				return a.Points > b.Points
			end
		)

	self.m_LobbyGrid:clear()
	for index, value in ipairs(scoreTable) do
		local item = self.m_LobbyGrid:addItem(value.Name, value.Kills, value.Deaths, value.Points)
		item:setFont(VRPFont(20))
	end
end

addEventHandler("superSweeperRefreshGUI", root, function(data)
	if not SuperSweeperGUI.Current then
		SuperSweeperGUI.Current = SuperSweeperGUI:new(data)
	else
		SuperSweeperGUI.Current:refresh(data)
	end
end)

addEventHandler("superSweeperCloseGUI", root, function()
	delete(SuperSweeperGUI:getSingleton())
	SuperSweeperGUI.Current = nil
end)
