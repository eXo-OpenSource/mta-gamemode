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

	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[<]", self):setFont(VRPFont(35))
	self.m_BackButton.onLeftClick = function() self:close() AdminGUI:getSingleton():show() Cursor:show() end

	self.m_TabGeneral = self.m_TabPanel:addTab(_"Allgemein")

	self.m_EventToggleButton = GUIButton:new(10, 100, 250, 30, "Event starten",  self.m_TabGeneral):setFontSize(1):setBackgroundColor(Color.Blue)
	self.m_EventToggleButton.onLeftClick = function() triggerServerEvent("adminEventToggle", localPlayer) end

	self.m_TabPlayer = self.m_TabPanel:addTab(_"Teilnehmer")

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

function AdminEventGUI:onReceiveData(eventActive)
	self.m_EventToggleButton:setText(eventActive and _"Event beenden" or _"Event starten")
end

function AdminEventGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabPlayer.TabIndex then
		self:refreshEventPlayers()
	end
end

function AdminEventGUI:refreshEventPlayers()

end
