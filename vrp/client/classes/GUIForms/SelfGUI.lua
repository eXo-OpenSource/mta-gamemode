-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SelfGUI.lua
-- *  PURPOSE:     Self menu GUI class
-- *
-- ****************************************************************************
SelfGUI = inherit(Singleton)
inherit(GUIForm, SelfGUI)

function SelfGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", 1, self):setFont(VRPFont(28))
	self.m_CloseButton.onHover = function(btn) btn:setColor(Color.Red) end
	self.m_CloseButton.onUnhover = function(btn) btn:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = bind(GUIWindow.CloseButton_Click, self)
	
	-- Tab: Info
	-- Todo
	local tabInfo = self.m_TabPanel:addTab(_"Info")
	
	-- Tab: Achievements
	-- Todo
	local tabAchievements = self.m_TabPanel:addTab(_"Erfolge")
	
	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Gruppen")
	self.m_GroupsLabel = GUILabel:new(self.m_Width * 0.02, self.m_Height*0.02, self.m_Width * 0.3, self.m_Height * 0.05, "Gruppe: Die_Hustler", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
end
