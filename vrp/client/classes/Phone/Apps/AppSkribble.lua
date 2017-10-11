-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppNotes.lua
-- *  PURPOSE:     A nicer notes app vong nicigkeit her
-- *
-- ****************************************************************************
AppSkribble = inherit(PhoneApp)
addRemoteEvents{"skribbleReceiveLobbys"}

function AppSkribble:constructor()
	PhoneApp.constructor(self, "Skribble", "IconScribble.png")
end

function AppSkribble:onOpen(form)
	local tabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)

	local infoTab = tabPanel:addTab("Info", FontAwesomeSymbols.Info)
	local lobbyTab = tabPanel:addTab("Lobbys", FontAwesomeSymbols.List)
	local createTab = tabPanel:addTab("Erstellen", FontAwesomeSymbols.Plus)
	local toplistTab = tabPanel:addTab("Top", FontAwesomeSymbols.Star)

	-- infoTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Skribble", infoTab)
	GUILabel:new(10, 60, form.m_Width-20, 30, "Skribble ist ein Mehrspieler mal und rate Spiel. Während ein Spieler ein Wort malt, müssen andere das Wort erraten um Punkte zu bekommen.\nDer Spieler mit den meisten Punkte am Ende des Spiels gewinnt!", infoTab)

	-- lobbyTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Lobbys", lobbyTab)
	self.m_LobbyGrid = GUIGridList:new(10, 60, form.m_Width-20, form.m_Height-120, lobbyTab)
	--self.m_LobbyGrid:addColumn(_"PW", .1)
	self.m_LobbyGrid:addColumn(_"Name", .7)
	--self.m_LobbyGrid:addColumn(_"Ersteller", .2)
	self.m_LobbyGrid:addColumn(_"S", .1)
	self.m_LobbyGrid:addColumn(_"R", .25)

	local refreshButton = GUIButton:new(form.m_Width-40, 20, 30, 30, FontAwesomeSymbols.Refresh, lobbyTab):setFont(FontAwesome(20)):setFontSize(1)--:setBarEnabled(false)
	refreshButton.onLeftClick =
		function()
			triggerServerEvent("skribbleRequestLobbys", localPlayer)
		end

	local infoButton = GUIButton:new(form.m_Width-80, 20, 30, 30, FontAwesomeSymbols.Info, lobbyTab):setFont(FontAwesome(20)):setFontSize(1)--:setBarEnabled(false)
	infoButton:setTooltip("  Weiß = Öffentliche Lobby\n  Orange = Private Lobby\n  S = Spieler\n  R = Runden\n  Doppelklick zum beitreten", "bottom", true)

	-- createTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Lobby erstellen", createTab)

	GUILabel:new(10, 60, form.m_Width-20, 30, "Name:", createTab)
	GUILabel:new(10, 130, form.m_Width-20, 30, "Passwort:", createTab)
	GUILabel:new(10, 200, form.m_Width-20, 30, "Runden:", createTab)

	self.m_Name = GUIEdit:new(10, 85, form.m_Width-20, 30, createTab):setText(("%s's Lobby"):format(localPlayer:getName()))
	self.m_Password = GUIEdit:new(10, 155, form.m_Width-20, 30, createTab):setMasked()--:setTooltip("Leer lassen für eine öffentliche Lobby!", "bottom")
	self.m_Rounds = GUIChanger:new(10, 225, form.m_Width-20, 30, createTab)
	for i = 3, 10 do
		self.m_Rounds:addItem(i)
	end

	GUIButton:new(10, form.m_Height-90, form.m_Width-20, 30, "Erstellen", createTab).onLeftClick =
		function()
			triggerServerEvent("skribbleCreateLobby", localPlayer, self.m_Name:getText(), self.m_Password:getText(), self.m_Rounds:getSelectedItem())
		end

	-- toplistTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Bestenliste", toplistTab)
	-- todo

	---
	self.m_ReceiveLobbys = bind(AppSkribble.receiveLobbys, self)
	addEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)

	triggerServerEvent("skribbleRequestLobbys", localPlayer)
end

function AppSkribble:onClose()
	removeEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)
end

function AppSkribble:receiveLobbys(lobbys)
	self.m_LobbyGrid:clear()

	for id, lobby in pairs(lobbys) do
		--local item = self.m_LobbyGrid:addItem(lobby.password ~= "" and FontAwesomeSymbols.Lock or FontAwesomeSymbols.Group, lobby.name, lobby.owner:getName(), lobby.players, ("%s/%s"):format(lobby.currentRound, lobby.rounds))
		--item:setColumnFont(1, FontAwesome(25), 1):setColumnColor(1, lobby.password ~= "" and Color.Red or Color.Green)

		local item = self.m_LobbyGrid:addItem(lobby.name, lobby.players, ("%s/%s"):format(lobby.currentRound, lobby.rounds))
		item.onLeftDoubleClick = function()	triggerServerEvent("skribbleJoinLobby", localPlayer, id) end

		if lobby.password ~= "" then
			item:setColor(Color.Orange)
		end
	end
end
