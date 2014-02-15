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
	self.m_CloseButton.onLeftClick = function() self:hide() end
	
	-- Tab: Info
	-- Todo
	local tabInfo = self.m_TabPanel:addTab(_"Info")
	
	-- Tab: Achievements
	-- Todo
	local tabAchievements = self.m_TabPanel:addTab(_"Erfolge")
	
	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Gruppen")
	local color = tocolor(209, 82, 227)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.05, _"Gruppe:", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.05, "Die_Hustler", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.05, _"Gruppenrank:", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.05, "Canny.H (Rang 3)", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	self.m_GroupCreateButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Erstellen", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupQuitButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", tabGroups):setBackgroundColor(Color.Red)
	self.m_GroupDeleteButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", tabGroups):setBackgroundColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.05, _"Kasse:", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.05, "1.000.000$", 1, tabGroups):setFont(VRPFont(self.m_Height * 0.05))
	self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	self.m_GroupMoneyDepositButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", tabGroups):setBackgroundColor(color):setColor(Color.Black)
	self.m_GroupMoneyWithdrawButton = GUIButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", tabGroups):setBackgroundColor(color):setColor(Color.Black)
	self.m_GroupPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.4, self.m_Height*0.5, tabGroups)
	self.m_GroupPlayersGrid:addColumn(_"Spieler", 0.7)
	self.m_GroupPlayersGrid:addColumn(_"Rang", 0.3)
	self.m_GroupPlayersGrid:addItem("Doneasty", 1)
	self.m_GroupPlayersGrid:addItem("Jusonex", 3)
	self.m_GroupPlayersGrid:addItem("sbx320", 1)
	self.m_GroupPlayersGrid:addItem("Verax", 1)
	self.m_GroupAddPlayerButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupRemovePlayerButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.48, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", tabGroups):setBackgroundColor(Color.Red)
	self.m_GroupRankUpButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.56, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", tabGroups):setBackgroundColor(color):setColor(Color.Black)
	self.m_GroupRankDownButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.64, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", tabGroups):setBackgroundColor(color):setColor(Color.Black)
end
