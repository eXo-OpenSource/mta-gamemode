-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminGUI = inherit(GUIForm)
inherit(Singleton, AdminGUI)
AdminGUI.playerFunctions = {"gethere", "goto", "kick", "prison", "unprison", "freeze", "warn", "timeban", "permaban", "setCompany", "setFaction", "showVehicles", "showGroupVehicles", "unban", "spect", "nickchange"}

for i, v in pairs(AdminGUI.playerFunctions) do
	AdminGUI.playerFunctions[v] = i
end

addRemoteEvents{"showAdminMenu", "announceText", "adminReceiveSeachedPlayers", "adminReceiveSeachedPlayerInfo", "adminRefreshEventMoney"}

function AdminGUI:constructor(money)
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-540/2, 800, 540)

	self.m_adminButton = {}

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")

	GUILabel:new(10, 10, 150, 30, _"Adminansage:", tabAllgemein):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(150, 10, 330, 30,tabAllgemein)

	--Column 1
	self.m_RespawnRadius = GUIEdit:new(10, 180, 60, 30, tabAllgemein)
	self.m_RespawnRadius:setNumeric(true, true)
	self.m_RespawnRadius:setText("50")

	self:addAdminButton("adminAnnounce", "senden", 490, 10, 100, 30, Color.LightBlue, tabAllgemein)
	self:addAdminButton("supportMode", "Support-Modus aktivieren/deaktivieren", 10, 50, 250, 30, Color.Green, tabAllgemein)
	self:addAdminButton("respawnFaction", "Fraktionsfahrzeuge respawnen", 10, 100, 250, 30, Color.LightBlue, tabAllgemein)
	self:addAdminButton("respawnCompany", "Unternehmensfahrzeuge respawnen", 10, 140, 250, 30, Color.LightBlue, tabAllgemein)
	self:addAdminButton("respawnRadius", "im Umkreis respawnen", 75, 180, 185, 30, Color.LightBlue, tabAllgemein)
	self:addAdminButton("clearChat", "Chat löschen / Werbung ausblenden", 10, 230, 250, 30, Color.Red, tabAllgemein)
	self:addAdminButton("resetAction", "Aktions-Sperre resetten", 10, 270, 250, 30, Color.Orange, tabAllgemein)
	self:addAdminButton("vehicleTexture", "Fahrzeug Texturen Menu", 10, 310, 250, 30, Color.Blue, tabAllgemein)

	GUILabel:new(10, 370, 250, 30, _"Zu Koordinaten porten: (x,y,z)", tabAllgemein):setColor(Color.LightBlue)
	self.m_EditPosX = GUIEdit:new(10, 400, 80, 25, tabAllgemein):setNumeric(true, false)
	self.m_EditPosY = GUIEdit:new(95, 400, 80, 25, tabAllgemein):setNumeric(true, false)
	self.m_EditPosZ = GUIEdit:new(180, 400, 80, 25, tabAllgemein):setNumeric(true, false)
	self:addAdminButton("gotocords", "zu Koordinaten porten", 10, 430, 250, 30, Color.Orange, tabAllgemein)

	--Column 2
	GUILabel:new(340, 50, 200, 40, _"Eventkasse:", tabAllgemein):setColor(Color.LightBlue)
	self.m_EventCurrentMoney = GUILabel:new(340, 80, 200, 25, _("Momentan: %d$", money or 0), tabAllgemein)
	GUILabel:new(340, 110, 60, 30, _"Betrag:", tabAllgemein)
	self.m_EventMoneyEdit = GUIEdit:new(410, 110, 140, 30, tabAllgemein):setNumeric(true, true)
	GUILabel:new(340, 150, 60, 30, _"Grund:", tabAllgemein)
	self.m_EventReasonEdit = GUIEdit:new(410, 150, 140, 30, tabAllgemein)
	self:addAdminButton("eventMoneyDeposit", "Einzahlen", 340, 190, 100, 30, Color.Green, tabAllgemein)
	self:addAdminButton("eventMoneyWithdraw", "Auszahlen", 450, 190, 100, 30, Color.Red, tabAllgemein)
	self:addAdminButton("eventMenu", "Event-Menü", 340, 230, 210, 30, Color.Blue, tabAllgemein)
	self:addAdminButton("checkOverlappingVehicles", "Überlappende Fahrzeuge", 340, 310, 210, 30, Color.Red, tabAllgemein)
	self:addAdminButton("pedMenu", "Ped-Menü", 340, 350, 210, 30, Color.Blue, tabAllgemein)


	--Column 3
	GUILabel:new(self.m_Width-150, 50, 140, 20, _"selbst teleportieren:", tabAllgemein):setColor(Color.White):setAlignX("right")
	self.m_portNorth = GUIButton:new(self.m_Width-105, 75, 30, 30, _"↑",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portNorth.onLeftClick = function () self:portAdmin("F") end
	self.m_portEast = GUIButton:new(self.m_Width-70, 110, 30, 30, _"→",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portEast.onLeftClick = function () self:portAdmin("R") end
	self.m_portSouth = GUIButton:new(self.m_Width-105, 145, 30, 30, _"↓",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portSouth.onLeftClick = function () self:portAdmin("B") end
	self.m_portWest = GUIButton:new(self.m_Width-140, 110, 30, 30, _"←",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portWest.onLeftClick = function () self:portAdmin("L") end
	self.m_portUp = GUIButton:new(self.m_Width-70, 75, 60, 30, _"Rauf",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portUp.onLeftClick = function () self:portAdmin("U") end
	self.m_portDown = GUIButton:new(self.m_Width-70, 145, 60, 30, _"Runter",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portDown.onLeftClick = function () self:portAdmin("D") end

	local tabSpieler = self.m_TabPanel:addTab(_"Spieler")
	self.m_TabSpieler = tabSpieler
	self.m_PlayerSearch = GUIEdit:new(10, 10, 200, 30, tabSpieler)
	self.m_PlayerSearch.onChange = function () self:searchPlayer() end

	self.m_PlayersGrid = GUIGridList:new(10, 45, 200, 425, tabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)
	self.m_RefreshButton = GUIButton:new(10, 470, 30, 30, FontAwesomeSymbols.Refresh, tabSpieler):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		self:refreshOnlinePlayers()
	end

	self.m_PlayerNameLabel = GUILabel:new(220, 10, 180, 20, _"Spieler: -", tabSpieler)
	self.m_PlayerTimeLabel = GUILabel:new(220, 35, 180, 20, _"Spielstunden: -", tabSpieler)
	self.m_PlayerJobLabel = GUILabel:new(220, 60, 180, 20, _"Job: -", tabSpieler)
	self.m_PlayerMoneyLabel = GUILabel:new(220, 85, 180, 20, _"Geld: -", tabSpieler)
	self.m_PlayerBankMoneyLabel = GUILabel:new(410, 85, 180, 20, _"Bank-Geld: -", tabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(410, 10, 180, 20, _"Fraktion: -", tabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(410, 35, 180, 20, _"Unternehmen: -", tabSpieler)
	self.m_PlayerGroupLabel = GUILabel:new(410, 60, 180, 20, _"Gang/Firma: -", tabSpieler)

	GUILabel:new(220, 130, 160, 30, _"Strafen:", tabSpieler)
	self:addAdminButton("kick", "kicken", 220, 170, 160, 30, Color.Orange, tabSpieler)
	self:addAdminButton("prison", "ins Prison", 220, 210, 160, 30, Color.Orange, tabSpieler)
	self:addAdminButton("unprison", "aus Prison entlassen", 220, 250, 160, 30, Color.Orange, tabSpieler)
	self:addAdminButton("timeban", "Timeban", 220, 290, 160, 30, Color.Red, tabSpieler)
	self:addAdminButton("permaban", "Permaban", 220, 330, 160, 30, Color.Red, tabSpieler)

	GUILabel:new(440, 130, 160, 30, _"Sonstiges:", tabSpieler)
	self:addAdminButton("spect", "specten", 440, 170, 160, 30, Color.LightRed, tabSpieler)
	self:addAdminButton("freeze", "ent/freezen", 440, 210, 160, 30, Color.LightRed, tabSpieler)
	self:addAdminButton("goto", "hin porten", 440, 250, 160, 30, Color.Green, tabSpieler)
	self:addAdminButton("gethere", "her porten", 440, 290, 160, 30, Color.Green, tabSpieler)
	self:addAdminButton("nickchange", "Nick ändern", 440, 330, 160, 30, Color.Orange, tabSpieler)

	self:addAdminButton("showGroupVehicles", "Firma/Gruppen Fahrzeuge", 610, 130, 160, 30, Color.LightBlue, tabSpieler)
	self:addAdminButton("showVehicles", "Fahrzeuge anzeigen", 610, 170, 160, 30, Color.LightBlue, tabSpieler)
	self:addAdminButton("warn", "Warns verwalten", 610, 210, 160, 30, Color.Orange, tabSpieler)
	self:addAdminButton("setFaction", "in Fraktion setzen", 610, 250, 160, 30, Color.Blue, tabSpieler)
	self:addAdminButton("setCompany", "in Unternehmen setzen", 610, 290, 160, 30, Color.Blue, tabSpieler)

	local tabOffline = self.m_TabPanel:addTab(_"Offline")
	GUILabel:new(10, 10, 200, 20, "Suche:", tabOffline)
	self.m_SeachText = GUIEdit:new(10, 30, 170, 30, tabOffline)
	self.m_SeachButton = GUIButton:new(180, 30, 30, 30, FontAwesomeSymbols.Search, tabOffline):setFont(FontAwesome(15))
	self.m_SeachButton.onLeftClick = function ()
		if #self.m_SeachText:getText() >= 3 then
			triggerServerEvent("adminSeachPlayer", localPlayer, self.m_SeachText:getText())
		else
			ErrorBox:new(_"Bitte gib mindestens 3 Zeichen ein!")
		end
	end

	self.m_PlayersOfflineGrid = GUIGridList:new(10, 70, 200, 300, tabOffline)
	self.m_PlayersOfflineGrid:addColumn(_"Spieler", 1)
	self.m_PlayerOfflineNameLabel = GUILabel:new(220, 10, 180, 20, _"Spieler: -", tabOffline)
	self.m_PlayerOfflineTimeLabel = GUILabel:new(220, 35, 180, 20, _"Spielstunden: -", tabOffline)
	self.m_PlayerOfflineJobLabel = GUILabel:new(220, 60, 180, 20, _"Job: -", tabOffline)
	self.m_PlayerOfflineMoneyLabel = GUILabel:new(220, 85, 180, 20, _"Geld: -", tabOffline)
	self.m_PlayerOfflineKarmaLabel = GUILabel:new(220, 110, 180, 20, _"Karma: -", tabOffline)
	self.m_PlayerOfflineBankMoneyLabel = GUILabel:new(410, 85, 180, 20, _"Bank-Geld: -", tabOffline)
	self.m_PlayerOfflineFactionLabel = GUILabel:new(410, 10, 180, 20, _"Fraktion: -", tabOffline)
	self.m_PlayerOfflineCompanyLabel = GUILabel:new(410, 35, 180, 20, _"Unternehmen: -", tabOffline)
	self.m_PlayerOfflineGroupLabel = GUILabel:new(410, 60, 180, 20, _"Gang/Firma: -", tabOffline)
	self.m_PlayerOfflineBanLabel = GUILabel:new(410, 110, 180, 20, _"Gebannt: -", tabOffline)

	self:addAdminButton("offlineTimeban", "Timeban", 220, 290, 180, 30, Color.Red, tabOffline)
	self:addAdminButton("offlinePermaban", "Permaban", 410, 290, 180, 30, Color.Red, tabOffline)
	self:addAdminButton("offlineUnban", "Unban", 220, 330, 180, 30, Color.Blue, tabOffline)
	self:addAdminButton("offlineNickchange", "NickChange", 410, 330, 180, 30, Color.Orange, tabOffline)


	self.m_TicketTab = self.m_TabPanel:addTab(_"Tickets")
	local url = ("http://exo-reallife.de/ingame/ticketSystem/admin.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId())
	self.m_TicketsBrowser = GUIWebView:new(0, 0, self.m_Width, self.m_Height, 	url, true, self.m_TicketTab)

	self:refreshOnlinePlayers()

	local tabWeb = self.m_TabPanel:addTab(_"WebPanel")
	local webPanelUrl = ("https://exo-reallife.de/index.php?page=admin&site=ingame&player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId())
	self.m_WebPanel = GUIWebView:new(0, 0, self.m_Width, self.m_Height, webPanelUrl, true, tabWeb)
	self.m_FullScreen = GUIButton:new(self.m_Width-50, 5, 30, 30, FontAwesomeSymbols.Expand, tabWeb):setFont(FontAwesome(15))
	self.m_FullScreen.onLeftClick = function ()
		self:close()
		local url = self.m_WebPanel:getUnderlyingBrowser():getURL()
		WebBrowser:new(url)
	end

	local tabDev = self.m_TabPanel:addTab(_"DevPanel")
	local devPanelUrl = "http://exo-reallife.de/dev"
	self.m_DevPanel = GUIWebView:new(0, 0, self.m_Width, self.m_Height, devPanelUrl, true, tabDev)
	self.m_FullScreenDev = GUIButton:new(self.m_Width-50, 5, 30, 30, FontAwesomeSymbols.Expand, tabDev):setFont(FontAwesome(15))
	self.m_FullScreenDev.onLeftClick = function ()
		self:close()
		local url = self.m_DevPanel:getUnderlyingBrowser():getURL()
		WebBrowser:new(url)
	end

	addEventHandler("adminReceiveSeachedPlayers", root,
		function(resultPlayers)
			self:insertSearchResult(resultPlayers)
		end
	)
	addEventHandler("adminReceiveSeachedPlayerInfo", root,
		function(data)
			self:onOfflinePlayerInfo(data)
		end
	)

	addEventHandler("adminRefreshEventMoney", root,
		function(money)
			self.m_EventCurrentMoney:setText(_("Momentan: %d$", money or 0))
		end
	)


	self:refreshButtons()
end

function AdminGUI:onShow()
	AntiClickSpam:getSingleton():setEnabled(false)
	self:refreshButtons()
	self:refreshOnlinePlayers()

	SelfGUI:getSingleton():addWindow(self)
end

function AdminGUI:onHide()
	AntiClickSpam:getSingleton():setEnabled(true)
	self.m_SelectedPlayer = nil

	SelfGUI:getSingleton():removeWindow(self)
end

function AdminGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabSpieler.TabIndex then
		self:refreshOnlinePlayers()
	elseif tabId == self.m_TicketTab.TabIndex then
		self.m_TicketsBrowser:reload()
	end
end

function AdminGUI:searchPlayer()
	self:refreshOnlinePlayers()
end

function AdminGUI:refreshOnlinePlayers()
	local players = getElementsByType("player")
	table.sort(players, function(a, b) return a.name < b.name  end)

	self.m_PlayersGrid:clear()
	for key, playeritem in ipairs(players) do
		if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(playeritem:getName()), string.lower(self.m_PlayerSearch:getText())) then
			local item = self.m_PlayersGrid:addItem(playeritem:getName())
			item.player = playeritem
			item.onLeftClick = function()
				self:onSelectPlayer(playeritem)
			end
		end
	end
end

function AdminGUI:addAdminButton(func, text, x, y, width, height, color, parent)
	self.m_adminButton[func] = GUIButton:new(x, y, width, height, _(text),  parent):setFontSize(1):setBackgroundColor(color)
	self.m_adminButton[func].func = func
	self.m_adminButton[func].onLeftClick = function () self:onButtonClick(func) end
	if AdminGUI.playerFunctions[func] then
		self.m_adminButton[func]:setEnabled(false)
	end
end

function AdminGUI:insertSearchResult(resultPlayers)
	self.m_PlayersOfflineGrid:clear()
	for index, pname in pairs(resultPlayers) do
		local item = self.m_PlayersOfflineGrid:addItem(pname)
		item.name = pname
		item.onLeftClick = function ()
			self:onOfflinePlayerInfo() -- Reset
			triggerServerEvent("adminSeachPlayerInfo", root, index, pname)
		end
	end
end

function AdminGUI:onOfflinePlayerInfo(info)
	local info = info
	if not info then
		info = {
			Name = false;
			PlayTime = 0;
			Faction = false;
			Company = false;
			Group = false;
			Job = false;
			Money = false;
			BankMoney = false;
			Ban = true;
			Kamra = false;
		}
	end

	self.m_PlayerOfflineNameLabel:setText(_("Spieler: %s", info.Name or "-"))
	local hours, minutes = math.floor(info.PlayTime/60), (info.PlayTime - math.floor(info.PlayTime/60)*60)
	self.m_PlayerOfflineTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerOfflineFactionLabel:setText(_("Fraktion: %s", info.Faction or _"-"))
	self.m_PlayerOfflineCompanyLabel:setText(_("Unternehmen: %s", info.Company or _"-"))
	self.m_PlayerOfflineGroupLabel:setText(_("Gang/Firma: %s", info.Group or _"-"))
	self.m_PlayerOfflineJobLabel:setText(_("Job: %s", info.Job and JobManager:getSingleton():getFromId(info.Job):getName() or _"-"))
	self.m_PlayerOfflineMoneyLabel:setText(_("Geld: %s$", info.Money or "-"))
	self.m_PlayerOfflineBankMoneyLabel:setText(_("Bank-Geld: %s$", info.BankMoney or "-"))
	local banString = "Nein"
	if info.Ban == true or tonumber(info.Warn) >= 3 then
		banString = "Ja"
	end
	self.m_PlayerOfflineBanLabel:setText(_("Gebannt: %s",  banString))
	self.m_PlayerOfflineKarmaLabel:setText(_("Karma: %s", info.Karma or "-"))

end

function AdminGUI:onSelectPlayer(player)
	if not isElement(player) then
		ErrorBox:new(_"Der Spieler ist nicht mehr online!")
		return
	end

	if not player:getPublicSync("Money") then
		ErrorBox:new(_"Der Spieler ist nicht eingeloggt!")
		return
	end

	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	local hours, minutes = math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60)
	self.m_PlayerTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keins -"))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_PlayerJobLabel:setText(_("Job: %s", player:getJobName()))
	self.m_PlayerMoneyLabel:setText(_("Geld: %d$", player:getPublicSync("Money") or 0))
	self.m_PlayerBankMoneyLabel:setText(_("Bank-Geld: %d$", player:getPublicSync("BankMoney") or 0))

	self.m_SelectedPlayer = player
	self:refreshButtons()
end

function AdminGUI:portAdmin(direction)
	if localPlayer:getRank() < ADMIN_RANK_PERMISSION["direction"] then
		ErrorBox:new(_"Du bist nicht berechtigt!")
		return false
	end

	local element = localPlayer

	if localPlayer:getOccupiedVehicle() then element = localPlayer:getOccupiedVehicle()	end
	element:setPosition(
		switch(direction) {
			case "F" (element.position + element.matrix.forward);
			case "B" (element.position - element.matrix.forward);
			case "R" (element.position + element.matrix.right);
			case "L" (element.position - element.matrix.right);
			case "U" (element.position + Vector3(0, 0, 1));
			case "D" (element.position - Vector3(0, 0, 1));
		}
	)
end

function AdminGUI:refreshButtons()
	for index, btn in pairs(self.m_adminButton) do
		if localPlayer:getRank() < ADMIN_RANK_PERMISSION[btn.func] then
			btn:setEnabled(false)
		else
			if AdminGUI.playerFunctions[btn.func] then
				if self.m_SelectedPlayer then
					btn:setEnabled(true)
				else
					btn:setEnabled(false)
				end
			else
				btn:setEnabled(true)
			end
		end
	end
end

function AdminGUI:onButtonClick(func)
	if AdminGUI.playerFunctions[func] then
		if not self.m_SelectedPlayer then
			ErrorBox:new(_"Kein Spieler ausgewählt!")
			return
		end
	end
	if func == "showVehicles" then
		AdminVehicleGUI:new(self.m_SelectedPlayer, self)
		self:close()
	elseif func == "showGroupVehicles" then
		AdminVehicleGUI:new(self.m_SelectedPlayer, self, true)
		self:close()
	elseif func == "gethere" or func == "goto" or func == "spect" or func == "freeze" then
		triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer)
	elseif func == "kick" then
		InputBox:new(_("Spieler %s kicken", self.m_SelectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s vom Server kicken?", self.m_SelectedPlayer:getName()),
				function (reason)
					if reason then
						triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason)
					else
						ErrorBox:new("Kein Grund angegeben!")
					end
				end)
	elseif func == "prison" then
		AdminInputBox:new(
				_("Spieler %s ins Prison schicken", self.m_SelectedPlayer:getName()),
				_"Dauer in Minuten:",
				function (reason, duration)
					if reason and duration then
						triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason, duration)
					else
						ErrorBox:new("Kein Grund oder Dauer angegeben!")
					end
				end)
	elseif func == "unprison" then
		QuestionBox:new(
				_("Spieler %s aus dem Prison entlassen?", self.m_SelectedPlayer:getName()),
				function ()
					triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer)
				end)
	elseif func == "timeban" then
		AdminInputBox:new(
				_("Spieler %s time bannen", self.m_SelectedPlayer:getName()),
				_"Dauer in Stunden:",
				function (reason, duration)
					if reason and duration then
						triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason, duration)
					else
						ErrorBox:new("Kein Grund oder Dauer angegeben!")
					end
				end)
	elseif func == "warn" then
				WarnManagement:new(self.m_SelectedPlayer, self)
				self:close()
	elseif func == "permaban" then
		InputBox:new(_("Spieler %s permanent Bannen", self.m_SelectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s permanent bannen?", self.m_SelectedPlayer:getName()),
				function (reason)
					if reason then
						triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason)
					end
				end)
	elseif func == "setCompany" then
		local companyTable = {[0] = "Kein Unternehmen", [1] = "Fahrschule", [2] = "Mech & Tow", [3] = "San News", [4] = "Public Transport"}
		ChangerBox:new(_"Unternehmen setzten",
				_"Bitte wähle das gewünschte Unternehmen aus:",companyTable,
				function (companyId)
					triggerServerEvent("adminSetPlayerCompany", root, self.m_SelectedPlayer, companyId)
				end)
	elseif func == "setFaction" then
		local factionTable = FactionManager:getSingleton():getFactionNames()
		factionTable[0] = "Keine Fraktion"
		ChangerBox:new(_"Fraktion setzten",
				_"Bitte wähle die gewünschte Fraktion aus:",factionTable,
				function (factionId)
					triggerServerEvent("adminSetPlayerFaction", root, self.m_SelectedPlayer, factionId)
				end)
	elseif func == "respawnCompany" then
		local companyTable = {[1] = "Fahrschule", [2] = "Mech & Tow", [3] = "San News", [4] = "Public Transport"}
		ChangerBox:new(_"Unternehmens-Fahrzeuge respawnen",
				_"Bitte wähle das gewünschte Unternehmen aus:",companyTable,
				function (companyId)
					triggerServerEvent("adminRespawnCompanyVehicles", root, companyId)
				end)
	elseif func == "respawnFaction" then
		local factionTable = FactionManager:getSingleton():getFactionNames()
		ChangerBox:new(_"Fraktions-Fahrzeuge respawnen",
				_"Bitte wähle die gewünschte Fraktion aus:",factionTable,
				function (factionId)
					triggerServerEvent("adminRespawnFactionVehicles", root, factionId)
				end)
	elseif func == "supportMode" or func == "clearChat" or func == "resetAction" then
		triggerServerEvent("adminTriggerFunction", root, func)
	elseif func == "respawnRadius" then
		local radius = self.m_RespawnRadius:getText()
		if radius and tonumber(radius) and tonumber(radius) > 0 then
			triggerServerEvent("adminTriggerFunction", root, func, radius)
		else
			ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
		end
	elseif func == "adminAnnounce" then
		local announceString = self.m_AdminAnnounceText:getText()
		if announceString ~= "" and #announceString > 0 then
			QuestionBox:new(
					_"Admin-Ankündigung senden?",
					function ()
						triggerServerEvent("adminTriggerFunction", root, func, announceString)
						self.m_AdminAnnounceText:setText(" ")
					end)
		else
			ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
		end
	elseif func == "offlineTimeban" then
		if self.m_PlayersOfflineGrid:getSelectedItem() then
			AdminInputBox:new(
				_("Spieler %s time bannen", self.m_PlayersOfflineGrid:getSelectedItem().name),
				_"Dauer in Stunden:",
				function (reason, duration)
					triggerServerEvent("adminTriggerFunction", root, func, self.m_PlayersOfflineGrid:getSelectedItem().name, reason, duration)
				end)
		else
			ErrorBox:new("Kein Spieler ausgewählt!")
		end
	elseif func == "offlinePermaban" then
		if self.m_PlayersOfflineGrid:getSelectedItem() then
			InputBox:new(_("Spieler %s permanent Bannen", self.m_PlayersOfflineGrid:getSelectedItem().name),
					_("Aus welchem Grund möchtest du den Spieler %s permanent bannen?", self.m_PlayersOfflineGrid:getSelectedItem().name),
					function (reason)
						triggerServerEvent("adminTriggerFunction", root, func, self.m_PlayersOfflineGrid:getSelectedItem().name, reason)
					end)
		else
			ErrorBox:new("Kein Spieler ausgewählt!")
		end
	elseif func == "offlineUnban" then
		if self.m_PlayersOfflineGrid:getSelectedItem() then
			QuestionBox:new(
					_("Spieler %s entbannen", self.m_PlayersOfflineGrid:getSelectedItem().name),
					function ()
						triggerServerEvent("adminTriggerFunction", root, func, self.m_PlayersOfflineGrid:getSelectedItem().name)
					end)
		else
			ErrorBox:new("Kein Spieler ausgewählt!")
		end
	elseif func == "eventMoneyDeposit" or func == "eventMoneyWithdraw" then
		local reason = self.m_EventReasonEdit:getText()
		local amount = tonumber(self.m_EventMoneyEdit:getText())
		if reason and string.len(reason) >= 3 and amount and amount > 0 then
			triggerServerEvent("adminTriggerFunction", root, func, amount, reason)
		else
			ErrorBox:new("Kein Grund oder Betrag angegeben!")
		end
	elseif func == "eventMenu" then
		self:close()
		AdminEventGUI:getSingleton():open()
	elseif func == "pedMenu" then
		self:close()
		AdminPedGUI:getSingleton():open()
	elseif func == "vehicleTexture" then
		self:close()
		TexturePreviewGUI:getSingleton():openAdmin()
	elseif func == "checkOverlappingVehicles" then
		triggerServerEvent("checkOverlappingVehicles", localPlayer)
	elseif func == "gotocords" then
		local x, y, z = self.m_EditPosX:getText(), self.m_EditPosY:getText(), self.m_EditPosZ:getText()
		if x and y and z and tonumber(x) and tonumber(y) and tonumber(z) then
			local pos = {x, y, z}
			triggerServerEvent("adminTriggerFunction", root, func, pos)
		else
			ErrorBox:new("Ungültige Koordinaten-Angabe")
		end
	elseif func == "nickchange" then
		InputBox:new(_("Spieler %s umbenennen", self.m_SelectedPlayer:getName()),
				_("Welchen Usernamen möchtest du dem Spieler %s geben?", self.m_SelectedPlayer:getName()),
				function (newName)
					if newName then
						triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, newName)
					end
				end)
	elseif func == "offlineNickchange" then
		if self.m_PlayersOfflineGrid:getSelectedItem() then
			InputBox:new(_("Spieler %s umbenennen", self.m_PlayersOfflineGrid:getSelectedItem().name),
					_("Welchen Usernamen möchtest du dem Spieler %s geben?", self.m_PlayersOfflineGrid:getSelectedItem().name),
					function (newName)
						if newName then
							triggerServerEvent("adminTriggerFunction", root, func, self.m_PlayersOfflineGrid:getSelectedItem().name, newName)
						end
					end)
		else
			ErrorBox:new("Kein Spieler ausgewählt!")
		end
	else
		outputDebug("Under Developement", 255, 0 ,0)
	end

end

function AdminGUI:AnnounceButton_Click()

end

addEventHandler("showAdminMenu", root,
	function(...)
		--if AdminGUI:getSingleton() then delete(AdminGUI:getSingleton()) end
		AdminGUI:getSingleton(...):show()
	end
)

addEventHandler("announceText", root,
	function(message)
		AdminGUI.m_MoveText = GUIMovetext:new(0, 0, screenWidth, screenHeight*0.05,message,"",1,(screenWidth*0.1)*-1, false,true)
		playSound("files/audio/announcment.mp3")
	end
)

AdminInputBox = inherit(GUIForm)

function AdminInputBox:constructor(title, durationText, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, durationText, self.m_Window)
	self.m_DurationBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_DurationBox:setNumeric(true, true)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.46, self.m_Width*0.5, self.m_Height*0.17, _"Grund:", self.m_Window)
	self.m_ReasonBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.46, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.45, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)

	self.m_SubmitButton.onLeftClick =
	function()
		if callback then
			callback(self.m_ReasonBox:getText(), tonumber(self.m_DurationBox:getText()))
		end
		delete(self)
	end
end

AdminVehicleGUI = inherit(GUIForm)

function AdminVehicleGUI:constructor(player, adminGui, isGroup)
	self.m_Player = player
	self.m_AdminGui = adminGui
	GUIForm.constructor(self, screenWidth/2-500/2, screenHeight/2-300/2, 500, 300)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Fahrzeuge von %s", isGroup and (player:getGroupName() and player:getGroupName() or "-") or player:getName()), true, true, self)
	self.m_Window:addBackButton(function () AdminGUI:getSingleton():show() end)
	self.m_VehiclesGrid = GUIGridList:new(10, 40, 300, 250, self.m_Window)
	self.m_VehiclesGrid:addColumn(_"Name", 0.5)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.5)

	self.m_portHere = GUIButton:new(320, 40, 170, 30, _"Fahrzeug her porten",  self):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_portTo = GUIButton:new(320, 80, 170, 30, _"zum Fahrzeug porten",  self):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_portHere.onLeftClick = function()
		if not self.m_VehiclesGrid:getSelectedItem() then
			ErrorBox:new(_"Kein Fahrzeug ausgewählt!")
			return
		end
		triggerServerEvent("adminPortVehicle", localPlayer, self.m_VehiclesGrid:getSelectedItem().VehicleElement)
	end
	self.m_portTo.onLeftClick = function()
		if not self.m_VehiclesGrid:getSelectedItem() then
			ErrorBox:new(_"Kein Fahrzeug ausgewählt!")
			return
		end
		triggerServerEvent("adminPortToVehicle", localPlayer, self.m_VehiclesGrid:getSelectedItem().VehicleElement)
	end

	addRemoteEvents{"adminVehicleRetrieveInfo"}
	addEventHandler("adminVehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))

	triggerServerEvent("adminGetPlayerVehicles", localPlayer, player, isGroup)
end

function AdminVehicleGUI:Event_vehicleRetrieveInfo(vehiclesInfo)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			local element, positionType = unpack(vehicleInfo)
			local x, y, z = getElementPosition(element)
			if positionType == VehiclePositionType.World then
				positionType = getZoneName(x, y, z, false)
			elseif positionType == VehiclePositionType.Garage then
				positionType = _"Garage"
			elseif positionType == VehiclePositionType.Mechanic then
				positionType = _"Autohof"
			elseif positionType == VehiclePositionType.Hangar then
				positionType = _"Hangar"
			else
				positionType = _"Unbekannt"
			end
			local item = self.m_VehiclesGrid:addItem(element:getName(), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = vehicleInfo[2]
		end
	end
end


WarnManagement = inherit(GUIForm)

function WarnManagement:constructor(player, adminGui)
	self.m_Player = player
	self.m_AdminGui = adminGui or false
	GUIForm.constructor(self, screenWidth/2-750/2, screenHeight/2-270/2, 750, 270)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Warns von %s", player:getName()), true, true, self)

	if self.m_AdminGui then
		self.m_Window:addBackButton(function () AdminGUI:getSingleton():show() end)
		self.m_addWarn = GUIButton:new(10, 235, self.m_Width/2-15, 30, _"Verwarnen",  self):setBackgroundColor(Color.Orange):setFontSize(1)
		self.m_removeWarn = GUIButton:new(self.m_Width/2+5, 235, self.m_Width/2-15, 30, _"Warn löschen",  self):setBackgroundColor(Color.Red):setFontSize(1)

		self.m_removeWarn.onLeftClick = function()
			if not self.m_WarnGrid:getSelectedItem() then
				ErrorBox:new(_"Kein Warn ausgewählt!")
				return
			end
			triggerServerEvent("adminTriggerFunction", root, "removeWarn", player, self.m_WarnGrid:getSelectedItem().Id)
			setTimer(function()
				self:loadWarns()
			end	,500, 1)
		end

		self.m_addWarn.onLeftClick = function()
			AdminInputBox:new(
				_("Spieler %s verwarnen", player:getName()),
				_"Dauer in Tagen:",
				function (reason, duration)
					if reason and duration then
						triggerServerEvent("adminTriggerFunction", root, "addWarn", player, reason, duration)
						setTimer(function()
							self:loadWarns()
						end	,500, 1)
					else
						ErrorBox:new("Ungültige Dauer oder Grund!")
					end
				end)
			end
	else
		self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)
	end
	self:loadWarns()
end

function WarnManagement:loadWarns()
	if self.m_WarnGrid then delete(self.m_WarnGrid) end
	if self.m_NoWarnLabel then delete(self.m_NoWarnLabel) end

	if #self.m_Player:getPublicSync("Warns") > 0 then
		self.m_WarnGrid = GUIGridList:new(10, 30, self.m_Width-20, 200, self)
		self.m_WarnGrid:addColumn(_"Grund", 0.25)
		self.m_WarnGrid:addColumn(_"Admin", 0.25)
		self.m_WarnGrid:addColumn(_"Datum", 0.25)
		self.m_WarnGrid:addColumn(_"Ablauf", 0.25)
		local item
		for index, row in pairs(self.m_Player:getPublicSync("Warns")) do
			item = self.m_WarnGrid:addItem(row.reason, row.adminName, getOpticalTimestamp(row.created), getOpticalTimestamp(row.expires))
			item.Id = row.Id
		end
		if self.m_AdminGui then
			self.m_removeWarn:setEnabled(true)
		end
	else
		self.m_NoWarnLabel = GUILabel:new(10,115,self.m_Width-20,30, _("Der Spieler %s hat keine Warns!", self.m_Player:getName()), self):setAlignX("center")
		if self.m_AdminGui then
			self.m_removeWarn:setEnabled(false)
		end
	end
end

function WarnManagement:onShow()
	SelfGUI:getSingleton():addWindow(self)
end

function WarnManagement:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end
