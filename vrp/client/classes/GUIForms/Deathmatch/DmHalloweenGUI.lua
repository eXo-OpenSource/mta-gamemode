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

function DmHalloweenGUI:constructor(playerData, roundData)
	GUIForm.constructor(self, screenWidth-310, screenHeight-360, 300, 350, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Player vs. Zombie", true, false, self)
	self.m_LobbyGrids = {}
	self.m_LobbyGrids["Bewohner"] = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.38, self.m_Window)

	self.m_LobbyGrids["Zombies"] = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.96, self.m_Height*0.38, self.m_Window)


	for key, grid in pairs(self.m_LobbyGrids) do
		grid:setFont(VRPFont(20))
		grid:setItemHeight(20)
		grid:addColumn(key, 0.55)
		grid:addColumn(_"K", 0.15)
		grid:addColumn(_"D", 0.15)
		grid:addColumn(_"P", 0.15)
		grid:setVisible(false)
	end

	self.m_LeaveButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Lobby verlassen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_LeaveButton.onLeftClick = bind(self.leaveLobby, self)

	self.m_CountdownElements = {
		["DescLabel"] = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.08, "Die Runde startet in", self.m_Window),
		["CountdownLabel"] = GUILabel:new(self.m_Width*0.02, self.m_Height*0.2, self.m_Width*0.96, self.m_Height*0.2, "--", self.m_Window),
		["SecondsLabel"] = GUILabel:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.96, self.m_Height*0.08, "Sekunden", self.m_Window),
		["PlayerAmount"] = GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.96, self.m_Height*0.08, "1 Spieler in der Lobby", self.m_Window),
	}

	for key, element in pairs(self.m_CountdownElements) do
		element:setAlignX("center")
	end

	self:refresh(playerData, roundData)

	DeathmatchManager.CurrentGUI = self
end

function DmHalloweenGUI:destructor()
	GUIForm.destructor(self)
	DeathmatchManager.CurrentGUI = false
end

function DmHalloweenGUI:leaveLobby()
	if localPlayer:isDead() then
		ErrorBox:new(_"Bitte warte bis du wieder gespawnt bist!")
		return
	end
	triggerServerEvent("deathmatchLeaveLobby", localPlayer)
end

function DmHalloweenGUI:refresh(playerData, roundData)
	local i = 1
	local scoreTable = {}
	for player, data in pairs(playerData) do
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
	self.m_LobbyGrids["Zombies"]:clear()

	for index, value in ipairs(scoreTable) do
		local item = self.m_LobbyGrids[value.Team]:addItem(value.Name, value.Kills, value.Deaths, value.Points)
		item:setFont(VRPFont(20))
	end

	if roundData.started == true then
		self.m_LobbyGrids["Bewohner"]:setVisible(true)
		self.m_LobbyGrids["Zombies"]:setVisible(true)

		for index, element in pairs(self.m_CountdownElements) do
			element:setVisible(false)
		end
	else
		if not self.m_CountdownTimer then
			self.m_CountdownAmount = math.floor(roundData.timeToStart/1000)
			self.m_CountdownTimer = setTimer(function()
				self.m_CountdownElements["CountdownLabel"]:setText(tostring(self.m_CountdownAmount))
				self.m_CountdownAmount = self.m_CountdownAmount - 1
			end, 1000, self.m_CountdownAmount)
		end
		self.m_CountdownElements["PlayerAmount"]:setText(_("%s Spieler in der Lobby", roundData.playersCount))
	end
end

addEventHandler("dmHalloweenRefreshGUI", root, function(playerData, roundData)
	if not DmHalloweenGUI.Current then
		DmHalloweenGUI.Current = DmHalloweenGUI:new(playerData, roundData)
	else
		DmHalloweenGUI.Current:refresh(playerData, roundData)
	end
end)

addEventHandler("dmHalloweenCloseGUI", root, function()
	delete(DmHalloweenGUI:getSingleton())
	DmHalloweenGUI.Current = nil
end)
