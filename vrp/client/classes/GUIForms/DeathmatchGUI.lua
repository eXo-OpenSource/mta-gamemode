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

addRemoteEvents{"deathmatchRefreshGUI", "deathmatchCloseGUI"}

function DeathmatchGUI:constructor(data)
	GUIForm.constructor(self, screenWidth-310, screenHeight-360, 300, 350, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch", true, false, self)

	self.m_LobbyGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.8, self.m_Window)
	self.m_LobbyGrid:setFont(VRPFont(20))
	self.m_LobbyGrid:setItemHeight(20)
	self.m_LobbyGrid:addColumn(_"Name", 0.55)
	self.m_LobbyGrid:addColumn(_"K", 0.15)
	self.m_LobbyGrid:addColumn(_"D", 0.15)
	self.m_LobbyGrid:addColumn(_"P", 0.15)

	self.m_LeaveButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Lobby verlassen", self.m_Window):setBarColor(Color.Red):setBarEnabled(true)
	self.m_LeaveButton.onLeftClick = bind(self.leaveLobby, self)

	self:refresh(data)
end

function DeathmatchGUI:destructor()
	GUIForm.destructor(self)
end

function DeathmatchGUI:leaveLobby()
	if localPlayer:isDead() then
		ErrorBox:new(_"Bitte warte bis du wieder gespawnt bist!")
		return
	end
	triggerServerEvent("deathmatchLeaveLobby", localPlayer)
end

function DeathmatchGUI:refresh(dataTable)
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

addEventHandler("deathmatchRefreshGUI", root, function(data)
	if not DeathmatchGUI.Current then
		DeathmatchGUI.Current = DeathmatchGUI:new(data)
	else
		DeathmatchGUI.Current:refresh(data)
	end
end)

addEventHandler("deathmatchCloseGUI", root, function()
	delete(DeathmatchGUI:getSingleton())
	DeathmatchGUI.Current = nil
end)
