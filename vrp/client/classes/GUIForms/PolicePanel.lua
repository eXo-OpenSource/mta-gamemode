-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************

PolicePanel = inherit(GUIForm)
inherit(Singleton, PolicePanel)

local ElementLocateBlip, ElementLocateTimer, GPSEnabled
local GPSUpdateStep = 0

addRemoteEvents{"receiveJailPlayers", "receiveBugs"}

function PolicePanel:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_TabSpieler = self.m_TabPanel:addTab(_"Spieler")

	self.m_PlayersGrid = GUIGridList:new(10, 10, 300, 370, self.m_TabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 0.5)
	self.m_PlayersGrid:addColumn(_"Fraktion", 0.3)

	--self.m_FactionLogo = GUIWebView:new(360, 10, 100, 135, "http://exo-reallife.de/images/fraktionen/"..localPlayer:getFactionId().."-logo.png", true, self.m_TabSpieler)

	--self.m_Skin = GUIWebView:new(490, 10, 100, 220, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, self.m_TabSpieler)

	self.m_PlayerNameLabel = 	GUILabel:new(320, 150, 180, 20, _"Spieler: -", self.m_TabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(320, 175, 180, 20, _"Fraktion: -", self.m_TabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(320, 200, 180, 20, _"Unternehmen: -", self.m_TabSpieler)
	self.m_PlayerGroupLabel = 	GUILabel:new(320, 225, 180, 20, _"Gang/Firma: -", self.m_TabSpieler)
	self.m_PhoneStatus = 		GUILabel:new(320, 250, 180, 20, _"Handy: -", self.m_TabSpieler)
	self.m_STVO = 				GUILabel:new(320, 275, 180, 20, _"STVO-Punkte: -", self.m_TabSpieler)

	self.m_GPS = GUICheckbox:new(490, 275, 100, 20, "GPS", self.m_TabSpieler)
	self.m_GPS:setChecked(GPSEnabled)
	self.m_GPS.onChange = function() GPSEnabled = self.m_GPS:isChecked() end

	self.m_RefreshBtn = GUIButton:new(280, 390, 30, 30, FontAwesomeSymbols.Refresh, self.m_TabSpieler):setFont(FontAwesome(20)):setFontSize(1)
	self.m_RefreshBtn.onLeftClick = function() self:loadPlayers() end

	self.m_PlayerSearch = GUIEdit:new(10, 390, 260, 30, self.m_TabSpieler)
	self.m_PlayerSearch.onChange = function () self:loadPlayers() end

	self.m_LocatePlayerBtn = GUIButton:new(320, 305, 125, 30, "Spieler orten", self.m_TabSpieler):setBackgroundColor(Color.Green):setFontSize(1)
	self.m_LocatePlayerBtn.onLeftClick = function() self:locatePlayer() end

	self.m_StopLocateBtn = GUIButton:new(450, 305, 125, 30, "Ortung beenden", self.m_TabSpieler):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_StopLocateBtn.onLeftClick = function() self:stopLocating() end

	self.m_AddWantedsBtn = GUIButton:new(320, 340, 125, 30, "Wanteds geben", self.m_TabSpieler):setFontSize(1)
	self.m_AddWantedsBtn.onLeftClick = function() self:giveWanteds() end

	self.m_DeleteWantedsBtn = GUIButton:new(450, 340, 125, 30, "Wanteds löschen", self.m_TabSpieler):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_DeleteWantedsBtn.onLeftClick = function() QuestionBox:new(
		_("Möchtest du wirklich alle Wanteds von %s löschen?", self.m_SelectedPlayer:getName()),
		function() triggerServerEvent("factionStateClearWanteds", localPlayer, self.m_SelectedPlayer) end)
	end

	self.m_AddSTVOBtn = GUIButton:new(320, 375, 125, 30, "STVO-Punkte geben", self.m_TabSpieler):setBackgroundColor(Color.LightRed):setFontSize(1)
	self.m_AddSTVOBtn.onLeftClick = function() self:giveSTVO("give") end
	self.m_SetSTVOBtn = GUIButton:new(450, 375, 125, 30, "STVO-Punkte setzen", self.m_TabSpieler):setBackgroundColor(Color.LightRed):setFontSize(1)
	self.m_SetSTVOBtn.onLeftClick = function() self:giveSTVO("set") end

	self.m_TabJail = self.m_TabPanel:addTab(_"Knast")

	self.m_JailPlayersGrid = GUIGridList:new(10, 10, 300, 370, self.m_TabJail)
	self.m_JailPlayersGrid:addColumn(_"Spieler", 0.5)
	self.m_JailPlayersGrid:addColumn(_"Knastzeit", 0.3)

	--self.m_FactionLogo2 = GUIWebView:new(360, 10, 100, 135, "http://exo-reallife.de/images/fraktionen/"..localPlayer:getFactionId().."-logo.png", true, self.m_TabJail)

	--self.m_JailSkin = GUIWebView:new(490, 10, 100, 220, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, self.m_TabJail)

	self.m_JailPlayerNameLabel = 	GUILabel:new(320, 150, 180, 20, _"Spieler: -", self.m_TabJail)
	self.m_JailPlayerFactionLabel = GUILabel:new(320, 175, 180, 20, _"Fraktion: -", self.m_TabJail)
	self.m_JailPlayerCompanyLabel = GUILabel:new(320, 200, 180, 20, _"Unternehmen: -", self.m_TabJail)
	self.m_JailPlayerGroupLabel = 	GUILabel:new(320, 225, 180, 20, _"Gang/Firma: -", self.m_TabJail)
	self.m_JailPhoneStatus = 		GUILabel:new(320, 250, 180, 20, _"Handy: -", self.m_TabJail)

	self.m_JailRefreshBtn = GUIButton:new(10, 380, 300, 30, "Aktualisieren", self.m_TabJail):setBackgroundColor(Color.LightBlue)
	self.m_JailRefreshBtn.onLeftClick = function()
		triggerServerEvent("factionStateLoadJailPlayers", root)
	end

	self.m_FreePlayerBtn = GUIButton:new(320, 305, 250, 30, "Spieler frei lassen", self.m_TabJail):setBackgroundColor(Color.Green)
	self.m_FreePlayerBtn.onLeftClick = function()
		if self.m_JailSelectedPlayer and isElement(self.m_JailSelectedPlayer) then
			QuestionBox:new(
				_("Möchtest du %s wirklich aus dem Knast befreien?", self.m_JailSelectedPlayer:getName()),
				function()
					triggerServerEvent("factionStateFreePlayer", localPlayer, self.m_JailSelectedPlayer)
				end
			)
		else
			ErrorBox:new(_"Der Spieler ist nicht mehr online!")
		end
	end

	self:loadPlayers()


	self.m_TabBugs = self.m_TabPanel:addTab(_"Wanzen")
	self.m_BugsGrid = GUIGridList:new(10, 10, 150, 370, self.m_TabBugs)
	self.m_BugsGrid:addColumn(_"Wanze", 0.5)
	self.m_BugsGrid:addColumn(_"Aktiv", 0.5)

	self.m_BugState = GUILabel:new(170, 10, 240, 25, _"Status: -", self.m_TabBugs)
	self.m_BugType = GUILabel:new(170, 35, 350, 25, _"angebracht an: -", self.m_TabBugs)
	self.m_BugOwner = GUILabel:new(170, 60, 350, 25, _"Besitzer: -", self.m_TabBugs)

	self.m_BugLogGrid = GUIGridList:new(170, 100, 390, 275, self.m_TabBugs)
	self.m_BugLogGrid:setItemHeight(20)
	self.m_BugLogGrid:setFont(VRPFont(20))
	self.m_BugLogGrid:addColumn(_"Log", 1)

	self.m_BugLocate = GUIButton:new(430, 10, 140, 25, _"orten", self.m_TabBugs)
	self.m_BugLocate:setBackgroundColor(Color.Green)
	self.m_BugLocate:setEnabled(false)
	self.m_BugLocate.onLeftClick = function() self:bugAction("locate") end

	self.m_BugClearLog = GUIButton:new(430, 40, 140, 25, _"Log löschen", self.m_TabBugs)
	self.m_BugClearLog:setBackgroundColor(Color.Blue)
	self.m_BugClearLog:setEnabled(false)
	self.m_BugClearLog.onLeftClick = function() self:bugAction("clearLog") end

	self.m_BugRefresh = GUIButton:new(400, 70, 25, 25, FontAwesomeSymbols.Refresh, self.m_TabBugs):setFont(FontAwesome(12))
	self.m_BugRefresh:setBackgroundColor(Color.LightBlue)
	self.m_BugRefresh:setEnabled(false)
	self.m_BugRefresh.onLeftClick = function()
		triggerServerEvent("factionStateLoadBugs", root)
	end

	self.m_BugDisable = GUIButton:new(430, 70, 140, 25, _"deaktivieren", self.m_TabBugs)
	self.m_BugDisable:setBackgroundColor(Color.Red)
	self.m_BugDisable:setEnabled(false)
	self.m_BugDisable.onLeftClick = function() self:bugAction("disable") end

	self.m_TabWantedRules = self.m_TabPanel:addTab(_"W. Regeln")
	self.m_WantedRules = GUIWebView:new(10, 10, self.m_Width-20, self.m_Height-20, "http://exo-reallife.de/ingame/other/wanteds.php", true, self.m_TabWantedRules)

	addEventHandler("receiveJailPlayers", root, bind(self.receiveJailPlayers, self))
	addEventHandler("receiveBugs", root, bind(self.receiveBugs, self))
end

function PolicePanel:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabJail.TabIndex then
		triggerServerEvent("factionStateLoadJailPlayers", root)
	elseif tabId == self.m_TabBugs.TabIndex then
		triggerServerEvent("factionStateLoadBugs", root)
	end
end

function PolicePanel:loadPlayers()
	self.m_PlayersGrid:clear()
	self.m_Players = {}

	for i = 0, 6 do
		for Id, player in pairs(Element.getAllByType("player")) do
			if player:getWanteds() == i then
				if not self.m_Players[i] then self.m_Players[i] = {} end
				if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(player:getName()), string.lower(self.m_PlayerSearch:getText())) then
					self.m_Players[i][player] = player:getName()
				end
			end
		end

		if self.m_Players[i] then
			table.sort(self.m_Players[i], function(a, b) return a < b end)
		end
	end

	for i = 6, 0, -1 do
		if self.m_Players[i] then
			self.m_PlayersGrid:addItemNoClick(("%s Wanteds"):format(i), "")

			for player, bool in pairs(self.m_Players[i]) do
				if isElement(player) then
					local item = self.m_PlayersGrid:addItem(player:getName(), player:getFaction() and player:getFaction():getShortName() or "- Keine -")
					item.player = player
					item.onLeftClick = function()
						self:onSelectPlayer(player)
					end
				end
			end
		end
	end
end

function PolicePanel:receiveJailPlayers(playerTable)
	self.m_JailPlayersGrid:clear()
	for player, jailtime in pairs(playerTable) do
		local item = self.m_JailPlayersGrid:addItem(player:getName(), jailtime)
		item.player = player
		item.onLeftClick = function()
			self:onSelectJailPlayer(player)
		end
	end
end


function PolicePanel:receiveBugs(bugTable)
	self.m_BugsGrid:clear()
	self.m_BugData = bugTable

	local pos, active = ""

	for id, bugData in ipairs(bugTable) do

		active = _"Nein"
		if bugData["element"] and isElement(bugData["element"]) then
			active = "Ja"
		end

		local item = self.m_BugsGrid:addItem(id, active)

		if id == self.m_CurrentSelectedBugId  then
			item:onInternalLeftClick()
			self:onSelectBug(id)
		end

		item.onLeftClick = function()
			triggerServerEvent("factionStateLoadBugs", root)
			self:onSelectBug(id)
		end
	end
end

function PolicePanel:onSelectBug(id)
	self.m_CurrentSelectedBugId = id
	if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then
		local owner, ownerType, item
		local element = self.m_BugData[id]["element"]

		if element:getType() == "vehicle" then
			owner = element:getData("OwnerName") or "Unbekannt"
			ownerType = "Fahrzeug"
		elseif element:getType() == "player" then
			owner = element:getName() or "Unbekannt"
			ownerType = "Spieler"
		end

		self.m_BugOwner:setText("angebracht an: "..ownerType)
		self.m_BugType:setText("Besitzer: "..owner)
		self.m_BugState:setText(_"Status: aktiv")
		self.m_BugState:setColor(Color.Green)

		self.m_BugLogGrid:clear()
		for index, msg in pairs(self.m_BugData[id]["log"]) do
			item = self.m_BugLogGrid:addItem(msg)
			item:setFont(VRPFont(20))
		end

		self.m_BugDisable:setEnabled(true)
		self.m_BugClearLog:setEnabled(true)
		self.m_BugLocate:setEnabled(true)
		self.m_BugRefresh:setEnabled(true)

	else
		self.m_BugLogGrid:clear()
		self.m_BugState:setText(_"Status: deaktiviert")
		self.m_BugState:setColor(Color.Red)
		self.m_BugDisable:setEnabled(false)
		self.m_BugClearLog:setEnabled(false)
		self.m_BugLocate:setEnabled(false)
		self.m_BugRefresh:setEnabled(false)
	end

end

function PolicePanel:bugAction(func)
	if self.m_CurrentSelectedBugId and self.m_CurrentSelectedBugId > 0 then
		local id = self.m_CurrentSelectedBugId

		if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["active"] and self.m_BugData[id]["active"] == true then
			if func == "locate" then
				if self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then
					self:locateElement(self.m_BugData[id]["element"], "bug")
				else
					ErrorBox:new(_"Die Wanze wurde nicht gefunden!")
				end
			else
				triggerServerEvent("factionStateBugAction", localPlayer, func, id)
			end
		else
			ErrorBox:new("Diese Wanze ist nicht aktiviert!")
		end
	else
		ErrorBox:new("Keine Wanze ausgewählt!")
	end
end

function PolicePanel:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keins -"))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_SelectedPlayer = player
	local phone = "Ausgeschaltet"
	if player:getPublicSync("Phone") == true then phone = "Eingeschaltet" end
	self.m_PhoneStatus:setText(_("Handy: %s", phone))
	self.m_STVO:setText(_("STVO-Punkte: %d", player:getSTVO()))

	--self.m_Skin:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..player:getModel())
end

function PolicePanel:onSelectJailPlayer(player)
	self.m_JailPlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	self.m_JailPlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_JailPlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keins -"))
	self.m_JailPlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_JailSelectedPlayer = player
	local phone = "Ausgeschaltet"
	if player:getPublicSync("Phone") == true then phone = "Eingeschaltet" end
	self.m_JailPhoneStatus:setText(_("Handy: %s", phone))

	--self.m_JailSkin:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..player:getModel())
end

function PolicePanel:locatePlayer()
	local item = self.m_PlayersGrid:getSelectedItem()
	local player = item.player
	if isElement(player) then
		if player:getPublicSync("Phone") == true then
			self:locateElement(player, "phone")
		else
			ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Sein Handy ist ausgeschaltet!")
		end
	else
		ErrorBox:new(_"Spieler nicht mehr online!")
	end
end

function PolicePanel:locateElement(element, locationOf)
	local elementText = element:getType() == "player" and _"Der Spieler" or _"Die Wanze"

	if getElementDimension(element) == 0 and getElementInterior(element) == 0 then
		self:stopLocating()

		local pos = element:getPosition()
		ElementLocateBlip = Blip:new("Marker.png", pos.x, pos.y, 9999)
		ElementLocateBlip:attachTo(element)
		localPlayer.m_LocatingElement = element
		InfoBox:new(_("%s wurde geortet! Folge dem Blip auf der Karte!", elementText))
		GPSUpdateStep = 10
		ElementLocateTimer = setTimer(function(locationOf)
			if localPlayer.m_LocatingElement and isElement(localPlayer.m_LocatingElement) then
				if not localPlayer:getPublicSync("Faction:Duty") then
					self:stopLocating()
				end

				local int = getElementInterior(localPlayer.m_LocatingElement)
				local dim = getElementDimension(localPlayer.m_LocatingElement)
				if int > 0 or dim > 0 then
					ErrorBox:new(_("%s ist in einem Gebäude!", elementText))
					self:stopLocating()
				end
				if locationOf == "bug" then
					if not element:getData("Wanze") == true then
						ErrorBox:new(_"Ortung beendet: Die Wanze ist nicht mehr verfügbar!")
						self:stopLocating()
					end
				elseif locationOf == "phone" then
					if not element:getPublicSync("Phone") == true then
						ErrorBox:new(_"Ortung beendet: Der Spieler hat sein Handy ausgeschaltet!")
						self:stopLocating()
					end
				end

				self:updateGPS()
			else
				self:stopLocating()
			end
		end, 1000, 0, locationOf)
	else
		ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Er ist in einem Gebäude!")
	end
end

function PolicePanel:updateGPS()
	if GPSEnabled then
		if GPSUpdateStep == 10 then
			if ElementLocateBlip and ElementLocateBlip.getPosition then
				local x, y, z = ElementLocateBlip:getPosition()
				GPS:getSingleton():startNavigationTo(Vector3(x, y, z), false, true)
			end
			GPSUpdateStep = 0
		end
		GPSUpdateStep = GPSUpdateStep + 1
	end
end

function PolicePanel:stopLocating()
	if ElementLocateBlip then delete(ElementLocateBlip) end
	if isTimer(ElementLocateTimer) then killTimer(ElementLocateTimer) end
	localPlayer.m_LocatingElement = false
	GPS:getSingleton():stopNavigation()
end

function PolicePanel:giveWanteds()
	local item = self.m_PlayersGrid:getSelectedItem()
	if item then
		local player = item.player
		GiveWantedSTVOBox:new(player, 1, 6, "Wanteds geben", function(player, amount, reason) triggerServerEvent("factionStateGiveWanteds", localPlayer, player, amount, reason) end)
	else
		ErrorBox:new(_"Kein Spieler ausgewählt!")
	end
end

function PolicePanel:giveSTVO(action)
	local item = self.m_PlayersGrid:getSelectedItem()
	if item then
		local player = item.player
		if action == "give" then
			GiveWantedSTVOBox:new(player, 1, 6, "STVO-Punkte geben", function(player, amount, reason) triggerServerEvent("factionStateGiveSTVO", localPlayer, player, amount, reason) end)
		elseif action == "set" then
			GiveWantedSTVOBox:new(player, 0, 20, "STVO-Punkte setzen", function(player, amount, reason) triggerServerEvent("factionStateSetSTVO", localPlayer, player, amount, reason) end)
		end
	else
		ErrorBox:new(_"Kein Spieler ausgewählt!")
	end
end


GiveWantedSTVOBox = inherit(GUIForm)

function GiveWantedSTVOBox:constructor(player, min, max, title, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("%s %s", player:getName(), title), true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, "Anzahl:", self.m_Window)
	self.m_Changer = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.2, self.m_Height*0.2, self.m_Window)
	for i = min, max do
		self.m_Changer:addItem(tostring(i))
	end
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.46, self.m_Width*0.5, self.m_Height*0.17, _"Grund:", self.m_Window)
	self.m_ReasonBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.46, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.45, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)
	self.m_SubmitButton.onLeftClick =
	function()
		callback(player, self.m_Changer:getIndex(), self.m_ReasonBox:getText())
		delete(self)
	end
end
