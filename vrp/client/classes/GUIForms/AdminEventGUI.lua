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

	self.m_EventButton["setPortPoint"] = GUIButton:new(10, 85, 250, 30, "Teleport-Punkt setzen",  self.m_TabGeneral):setFontSize(1):setBackgroundColor(Color.Orange)
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

function AdminEventGUI:onReceiveData(eventActive, players)
	self.m_EventToggleButton:setText(eventActive and _"Event beenden" or _"Event starten")
	self.m_PlayersGrid:clear()
	if eventActive then
		for index, button in pairs(self.m_EventButton) do
			button:setEnabled(true)
		end

		for index, player in pairs(players) do
			self.m_PlayersGrid:addItem(player:getName())
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
