-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminEventGUI = inherit(GUIForm)
inherit(Singleton, AdminEventGUI)

addRemoteEvents{"adminEventReceiveData"}

function AdminEventGUI:constructor(money)
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-540/2, 800, 540)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() AdminGUI:getSingleton():show() Cursor:show() end

	self.m_TabGeneral = self.m_TabPanel:addTab(_"Allgemein")

	self.m_EventToggleButton = GUIButton:new(10, 50, 250, 30, "Event starten",  self.m_TabGeneral):setFontSize(1):setBackgroundColor(Color.Blue)
	self.m_EventToggleButton.onLeftClick = function() triggerServerEvent("adminEventToggle", localPlayer) end

	self.m_EventButton = {}

	self.m_EventButton["setPortPoint"] = GUIButton:new(10, 85, 250, 30, "Teleportpunkt setzen",  self.m_TabGeneral):setFontSize(1):setBackgroundColor(Color.Orange)
	self.m_EventButton["setPortPoint"].onLeftClick = function() triggerServerEvent("adminEventTrigger", localPlayer, "setTeleportPoint") end

	self.m_EventButton["portPlayers"] = GUIButton:new(10, 120, 250, 30, "Spieler porten",  self.m_TabGeneral):setFontSize(1):setBackgroundColor(Color.Orange)
	self.m_EventButton["portPlayers"].onLeftClick = function() triggerServerEvent("adminEventTrigger", localPlayer, "teleportPlayers") end

	---------------------------------------

	self.m_TabPlayer = self.m_TabPanel:addTab(_"Teilnehmer")

	self.m_PlayerSearch = GUIEdit:new(10, 10, 200, 30, self.m_TabPlayer)
	self.m_PlayerSearch.onChange = function () self:searchPlayer() end

	self.m_PlayersGrid = GUIGridList:new(10, 45, 200, 425, self.m_TabPlayer)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)
	self.m_RefreshButton = GUIButton:new(10, 470, 30, 30, FontAwesomeSymbols.Refresh, self.m_TabPlayer):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		triggerServerEvent("adminEventRequestData", localPlayer)
	end


	---------------------------------------

	self.m_TabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")

	self.m_VehiclesGrid = GUIGridList:new(10, 35, 400, 425, self.m_TabVehicles)
	self.m_VehiclesGrid:addColumn(_"Fahrzeuge", 0.4)
	self.m_VehiclesGrid:addColumn(_"Gefreezt", 0.2)
	self.m_VehiclesGrid:addColumn(_"Spieler", 0.4)
	self.m_RefreshButton = GUIButton:new(10, 470, 30, 30, FontAwesomeSymbols.Refresh, self.m_TabVehicles):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		triggerServerEvent("adminEventRequestData", localPlayer)
	end

	GUILabel:new(420, 35, 300, 30, "Fahrzeuge erstellen:", self.m_TabVehicles)

	GUILabel:new(420, 65, 50, 20, "Anzahl", self.m_TabVehicles)
	self.m_Amount = GUIEdit:new(420, 85, 50, 30, self.m_TabVehicles)
	self.m_Amount:setNumeric(true, true)

	GUILabel:new(480, 65, 70, 20, "Richtung", self.m_TabVehicles)
	self.m_DirectionChanger = GUIChanger:new(480, 85, 90, 30, self.m_TabVehicles)
	self.m_DirectionChanger:addItem("L")
	self.m_DirectionChanger:addItem("R")
	self.m_DirectionChanger:addItem("V")
	self.m_DirectionChanger:addItem("H")
	self.m_EventButton["createVehicles"] = GUIButton:new(580, 85, 190, 30, "Fahrzeug duplizieren", self.m_TabVehicles):setFontSize(1)
	self.m_EventButton["createVehicles"].onLeftClick = function()
		if self.m_Amount:getText() and tonumber(self.m_Amount:getText()) and tonumber(self.m_Amount:getText()) > 0 then
			local direction = self.m_DirectionChanger:getSelectedItem()
			triggerServerEvent("adminEventCreateVehicles", localPlayer, tonumber(self.m_Amount:getText()), direction)
		end
	end

	GUILabel:new(420, 130, 300, 30, "Alle Fahrzeuge:", self.m_TabVehicles)
	self.m_EventButton["unfreezeAllVehicles"] = GUIButton:new(420, 160, 100, 30, "entfreezen", self.m_TabVehicles):setBackgroundColor(Color.Green):setFontSize(1)
	self.m_EventButton["unfreezeAllVehicles"].onLeftClick = function() triggerServerEvent("adminEventAllVehiclesAction", localPlayer, "unfreeze") end
	self.m_EventButton["freezeAllVehicles"] = GUIButton:new(530, 160, 100, 30, "freezen", self.m_TabVehicles):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_EventButton["freezeAllVehicles"].onLeftClick = function() triggerServerEvent("adminEventAllVehiclesAction", localPlayer, "freeze") end
	self.m_EventButton["deleteAllVehicles"] = GUIButton:new(640, 160, 100, 30, "löschen", self.m_TabVehicles):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_EventButton["deleteAllVehicles"].onLeftClick = function() triggerServerEvent("adminEventAllVehiclesAction", localPlayer, "delete") end

	addEventHandler("adminEventReceiveData", root, bind(self.onReceiveData, self))
end

function AdminEventGUI:onShow()
	AntiClickSpam:getSingleton():setEnabled(false)
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("adminEventRequestData", localPlayer)
end

function AdminEventGUI:onHide()
	AntiClickSpam:getSingleton():setEnabled(true)
	SelfGUI:getSingleton():removeWindow(self)
end

function AdminEventGUI:onReceiveData(eventActive, players, vehicles)
	self.m_EventToggleButton:setText(eventActive and _"Event beenden" or _"Event starten")
	self.m_PlayersGrid:clear()
	self.m_VehiclesGrid:clear()
	if eventActive then
		for index, button in pairs(self.m_EventButton) do
			button:setEnabled(true)
		end

		for index, player in pairs(players) do
			self.m_PlayersGrid:addItem(player:getName())
		end

		for index, vehicle in pairs(vehicles) do
			if vehicle and isElement(vehicle) then
				self.m_VehiclesGrid:addItem(vehicle:getName(), vehicle:isFrozen() and _"Ja" or _"Nein", vehicle:getOccupant(1) or "keiner")
			end
		end
	else
		for index, button in pairs(self.m_EventButton) do
			button:setEnabled(false)
		end
	end
end

function AdminEventGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabPlayer.TabIndex then
		triggerServerEvent("adminEventRequestData", localPlayer)
	end
end
