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

addRemoteEvents{"dmHalloweenRefreshGUI", "dmHalloweenCloseGUI", "dmHalloweenRefreshMarkerGUI", "dmHalloweenToggleDamageEvent"}

function DmHalloweenGUI:constructor(playerData, roundData)
	GUIForm.constructor(self, screenWidth-310, screenHeight-410, 300, 400, false)
	self.m_Window = GUIWindow:new(0, 50, self.m_Width, 350, _"Player vs. Zombie", true, false, self)
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

	self.m_MarkerBG = GUIRectangle:new(0, 0, self.m_Width, 50, Color.Primary, self):setVisible(false)
	self.m_MarkerText = GUILabel:new(self.m_Width*0.02, 5, self.m_Width*0.96, 20, "Marker gehört: Bewohner", self.m_MarkerBG)
	self.m_Progress = GUIProgressBar:new(self.m_Width*0.02, 25, self.m_Width*0.96, 20, self.m_MarkerBG)

	self:refresh(playerData, roundData)

	DeathmatchManager.CurrentGUI = self

	self.m_DamageBind = bind(self.onPedDamage, self)

	addEventHandler("dmHalloweenToggleDamageEvent", root, function(state)
		if state == true then
			addEventHandler("onClientPlayerDamage", localPlayer, self.m_DamageBind)
		else
			removeEventHandler("onClientPlayerDamage", localPlayer, self.m_DamageBind)
		end
	end)

end

function DmHalloweenGUI:destructor()
	GUIForm.destructor(self)
	DeathmatchManager.CurrentGUI = false
	removeEventHandler("onClientPlayerDamage", localPlayer, self.m_DamageBind)
end

function DmHalloweenGUI:onPedDamage(attacker, weapon)
	triggerServerEvent("dmHalloweenOnDamage", source, attacker, weapon)
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
		if player == localPlayer then
			self.m_Team = data.Team
		end
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

function DmHalloweenGUI:refreshMarker(markerData)
	if markerData then
		self.m_MarkerBG:setVisible(true)
		self.m_MarkerText:setText(_("Marker gehört: %s", markerData.Owner))
		local p
		if markerData.AttackerTeam == "Zombies" then
			p = markerData.Score * -10
		else
			p = markerData.Score * 10
		end
		--outputChatBox("Score: " ..markerData.Score.." Prozent: "..math.abs(p))

		self.m_Progress:setProgress(math.abs(p))
	else
		self.m_MarkerBG:setVisible(false)
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

addEventHandler("dmHalloweenRefreshMarkerGUI", root, function(markerData)
	if DmHalloweenGUI.Current then
		DmHalloweenGUI.Current:refreshMarker(markerData)
	end
end)


DmHalloweenFinishedGUI = inherit(GUIForm)
inherit(Singleton, DmHalloweenFinishedGUI)

function DmHalloweenFinishedGUI:constructor(header, text)
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 20) 	-- width of the window
	self.m_Height = grid("y", 3) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", false, false, self)
	GUIGridLabel:new(0, 0, 20, 2, header, self.m_Window):setFont(VRPFont(50)):setAlignX("center")
	GUIGridLabel:new(0, 1, 20, 2, text, self.m_Window):setFont(VRPFont(30)):setAlignX("center")
	setTimer(function() delete(self) end, 7000, 1)
end

function DmHalloweenFinishedGUI:destructor()
	GUIForm.destructor(self)
end

addRemoteEvents{"showDmHalloweenFinishedGUI"}

addEventHandler("showDmHalloweenFinishedGUI", root, function(header, text)
	DmHalloweenFinishedGUI:new(header, text)
end)
