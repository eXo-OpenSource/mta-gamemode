-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminGUI = inherit(GUIForm)
AdminGUI.playerFunctions = {"gethere", "goto", "kick", "prison", "warn", "timeban", "permaban", "setCompany", "setFaction", "showVehicles", "unban"}

for i, v in pairs(AdminGUI.playerFunctions) do
	AdminGUI.playerFunctions[v] = i
end

inherit(Singleton, AdminGUI)

addRemoteEvents{"showAdminMenu", "announceText", "setDamageFree", "adminReceiveSeachedPlayers"}

function AdminGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-200, 600, 400, false, false)

	self.m_adminButton = {}

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
	--self.m_BackButton.onHover = function () self.m_BackButton:setColor(Color.LightBlue) end
	--self.m_BackButton.onUnhover = function () self.m_BackButton:setColor(Color.White) end
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	GUILabel:new(10, 10, 150, 30, _"Adminansage:", tabAllgemein):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(150, 10, 330, 30,tabAllgemein)
	self:addAdminButton("adminAnnounce", "senden", 490, 10, 100, 30, Color.LightBlue, tabAllgemein)

	self:addAdminButton("supportMode", "Support-Modus aktivieren/deaktivieren", 10, 50, 250, 30, Color.Green, tabAllgemein)
	GUILabel:new(self.m_Width-150, 50, 140, 20, _"selbst teleportieren:", tabAllgemein):setColor(Color.White):setAlignX("right")
	self.m_portNorth = GUIButton:new(self.m_Width-105, 75, 30, 30, _"N",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portNorth.onLeftClick = function () self:portAdmin("N") end
	self.m_portEast = GUIButton:new(self.m_Width-70, 110, 30, 30, _"O",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portEast.onLeftClick = function () self:portAdmin("O") end
	self.m_portSouth = GUIButton:new(self.m_Width-105, 145, 30, 30, _"S",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portSouth.onLeftClick = function () self:portAdmin("S") end
	self.m_portWest = GUIButton:new(self.m_Width-140, 110, 30, 30, _"W",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portWest.onLeftClick = function () self:portAdmin("W") end
	self.m_portUp = GUIButton:new(self.m_Width-70, 75, 60, 30, _"Rauf",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portUp.onLeftClick = function () self:portAdmin("U") end
	self.m_portDown = GUIButton:new(self.m_Width-70, 145, 60, 30, _"Runter",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portDown.onLeftClick = function () self:portAdmin("D") end

	local tabSpieler = self.m_TabPanel:addTab(_"Spieler")
	self.m_PlayersGrid = GUIGridList:new(10, 10, 200, 380, tabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)

	self.m_PlayerNameLabel = GUILabel:new(220, 10, 180, 20, _"Spieler: -", tabSpieler)
	self.m_PlayerTimeLabel = GUILabel:new(220, 35, 180, 20, _"Spielstunden: -", tabSpieler)
	self.m_PlayerJobLabel = GUILabel:new(220, 60, 180, 20, _"Job: -", tabSpieler)
	self.m_PlayerMoneyLabel = GUILabel:new(220, 85, 180, 20, _"Geld: -", tabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(410, 10, 180, 20, _"Fraktion: -", tabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(410, 35, 180, 20, _"Unternehmen: -", tabSpieler)
	self.m_PlayerGroupLabel = GUILabel:new(410, 60, 180, 20, _"Gang/Firma: -", tabSpieler)

	self:addAdminButton("showVehicles", "Fahrzeuge anzeigen", 220, 130, 180, 30, Color.LightBlue, tabSpieler)
	self:addAdminButton("goto", "hin porten", 220, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("gethere", "her porten", 410, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("kick", "kicken", 220, 210, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("warn", "Warns verwalten", 410, 210, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("prison", "ins Prison", 220, 250, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("unprison", "aus Prison entlassen", 410, 250, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("timeban", "Timeban", 220, 290, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("permaban", "Permaban", 410, 290, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("setFaction", "in Fraktion setzen", 220, 330, 180, 30, Color.Blue, tabSpieler)
	self:addAdminButton("setCompany", "in Unternehmen setzen", 410, 330, 180, 30, Color.Blue, tabSpieler)

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
	self:addAdminButton("offlineTimeban", "Timeban", 220, 290, 180, 30, Color.Red, tabOffline)
	self:addAdminButton("offlinePermaban", "Permaban", 410, 290, 180, 30, Color.Red, tabOffline)


	local tabTicket = self.m_TabPanel:addTab(_"Tickets")
	local url = ("http://exo-reallife.de/ingame/ticketSystem/admin.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId())
	self.m_WebView = GUIWebView:new(0, 0, self.m_Width, self.m_Height, 	url, true, tabTicket)

	for key, playeritem in ipairs(getElementsByType("player")) do
		local item = self.m_PlayersGrid:addItem(playeritem:getName())
		item.player = playeritem
		item.onLeftClick = function()
			self:onSelectPlayer(playeritem)
		end
	end

	addEventHandler("adminReceiveSeachedPlayers", root,
		function(resultPlayers)
			AdminGUI:getSingleton():insertSearchResult(resultPlayers)
		end
	)

	self:refreshButtons()
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
	local item

	for index, pname in pairs(resultPlayers) do
		item = self.m_PlayersOfflineGrid:addItem(pname)
		item.name = pname
	end
end

function AdminGUI:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	local hours, minutes = math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60)
	self.m_PlayerTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keine -"))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_PlayerJobLabel:setText(_("Job: %s", player:getJobName()))
	self.m_PlayerMoneyLabel:setText(_("Geld: %d$", player:getMoney()))


	self.m_SelectedPlayer = player
	self:refreshButtons()
end

function AdminGUI:portAdmin(direction)
	local element = localPlayer

	if localPlayer:getOccupiedVehicle() then element = localPlayer:getOccupiedVehicle()	end

	local pos = element:getPosition()
		if direction == "N" then pos.y = pos.y+2
	elseif direction == "O" then pos.x = pos.x+2
	elseif direction == "S" then pos.y = pos.y-2
	elseif direction == "W" then pos.x = pos.x-2
	elseif direction == "U" then pos.z = pos.z+2
	elseif direction == "D" then pos.z = pos.z-2
	end
	element:setPosition(pos)
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
	elseif func == "gethere" or func == "goto" then
		triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer)
	elseif func == "kick" then
		InputBox:new(_("Spieler %s kicken", self.m_SelectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s vom Server kicken?", self.m_SelectedPlayer:getName()),
				function (reason)
					triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason)
				end)
	elseif func == "prison" then
		AdminInputBox:new(
				_("Spieler %s ins Prison schicken", self.m_SelectedPlayer:getName()),
				_"Dauer in Minuten:",
				function (reason, duration)
					triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason, duration)
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
					triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason, duration)
				end)
	elseif func == "warn" then
				WarnManagement:new(self.m_SelectedPlayer, self)
				self:close()
	elseif func == "permaban" then
		InputBox:new(_("Spieler %s permanent Bannen", self.m_SelectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s permanent bannen?", self.m_SelectedPlayer:getName()),
				function (reason)
					triggerServerEvent("adminTriggerFunction", root, func, self.m_SelectedPlayer, reason)
				end)
	elseif func == "setCompany" then
		local companyTable = {[0] = "Kein Unternehmen", [1] = "Fahrschule", [2] = "Mech & Tow", [3] = "San News", [4] = "Public Transport"}
		ChangerBox:new(_"Unternehmen setzten",
				_"Bitte wähle das gewünschte Unternehmen aus:",companyTable,
				function (companyId)
					triggerServerEvent("adminSetPlayerCompany", root, self.m_SelectedPlayer,companyId)
				end)
	elseif func == "setFaction" then
		local factionTable = FactionManager:getSingleton():getFactionNames()
		factionTable[0] = "Keine Fraktion"
		ChangerBox:new(_"Fraktion setzten",
				_"Bitte wähle die gewünschte Fraktion aus:",factionTable,
				function (factionId)
					triggerServerEvent("adminSetPlayerFaction", root, self.m_SelectedPlayer,factionId)
				end)
	elseif func == "supportMode" then
		triggerServerEvent("adminTriggerFunction", root, func)
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
	else
		outputDebug("Under Developement", 255, 0 ,0)
	end
end

function AdminGUI:AnnounceButton_Click()

end

addEventHandler("showAdminMenu", root,
	function(...)
		AdminGUI:new()
	end
)

addEventHandler("setDamageFree", root,
	function(...)
		AdminGUI:new()
	end
)

addEventHandler("announceText", root,
	function(message)
		AdminGUI.m_MoveText = GUIMovetext:new(0, 0, screenWidth, screenHeight*0.05,message,"",1,(screenWidth*0.1)*-1, "files/images/GUI/megafone.png",true)
		playSound("files/audio/announcment.mp3")
	end
)

AdminInputBox = inherit(GUIForm)

function AdminInputBox:constructor(title, durationText, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, durationText, self.m_Window)
	self.m_DurationBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_DurationBox:setNumeric(true)
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

function AdminVehicleGUI:constructor(player, adminGui)
	self.m_Player = player
	self.m_AdminGui = adminGui
	GUIForm.constructor(self, screenWidth/2-500/2, screenHeight/2-300/2, 500, 300)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Fahrzeuge von %s", player:getName()), true, true, self)
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

	triggerServerEvent("adminGetPlayerVehicles", localPlayer, player)
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
	self.m_AdminGui = adminGui
	GUIForm.constructor(self, screenWidth/2-500/2, screenHeight/2-270/2, 500, 270)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Warns von %s", player:getName()), true, true, self)
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
				triggerServerEvent("adminTriggerFunction", root, "addWarn", player, reason, duration)
				setTimer(function()
					self:loadWarns()
				end	,500, 1)
			end)
		end

	self:loadWarns()
end

function WarnManagement:loadWarns()
	if self.m_WarnGrid then delete(self.m_WarnGrid) end
	if self.m_NoWarnLabel then delete(self.m_NoWarnLabel) end

	if #self.m_Player:getPublicSync("Warns") > 0 then
		self.m_WarnGrid = GUIGridList:new(10, 30, self.m_Width-20, 200, self)
		self.m_WarnGrid:addColumn(_"Grund", 0.3)
		self.m_WarnGrid:addColumn(_"Admin", 0.2)
		self.m_WarnGrid:addColumn(_"Datum", 0.25)
		self.m_WarnGrid:addColumn(_"Ablauf", 0.25)
		local item
		for index, row in pairs(self.m_Player:getPublicSync("Warns")) do
			item = self.m_WarnGrid:addItem(row.reason, row.adminName, getOpticalTimestamp(row.created), getOpticalTimestamp(row.expires))
			item.Id = row.Id
		end
		self.m_removeWarn:setEnabled(true)
	else
		self.m_NoWarnLabel = GUILabel:new(10,115,self.m_Width-20,30, _("Der Spieler %s hat keine Warns!", self.m_Player:getName()), self):setAlignX("center")
		self.m_removeWarn:setEnabled(false)
	end
end
