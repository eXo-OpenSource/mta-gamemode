-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminTransactionGUI.lua
-- *  PURPOSE:     Admin Transaction GUI class
-- *
-- ****************************************************************************
AdminTransactionGUI = inherit(GUIForm)
inherit(Singleton, AdminTransactionGUI)

function AdminTransactionGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 14)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Admin: Transaktionen", true, true, self)
	self.m_Amount = GUIGridEdit:new(1, 1, 13, 1, self.m_Window):setCaption("Geldbetrag"):setNumeric(true)

	self.m_From = GUIGridEdit:new(1, 2, 6, 1, self.m_Window):setCaption("Name")
	self.m_FromPlayer = GUIGridCheckbox:new(1, 3, 1, 1, "Spieler", self.m_Window)
	self.m_FromPlayer.onChange = function() self.m_FromFaction:setChecked(false) self.m_FromCompany:setChecked(false) self.m_FromGroup:setChecked(false) self.m_FromAdmin:setChecked(false) end

	self.m_FromFaction = GUIGridCheckbox:new(1, 4, 1, 1, "Fraktion", self.m_Window)
	self.m_FromFaction.onChange = function() self.m_FromPlayer:setChecked(false) self.m_FromCompany:setChecked(false) self.m_FromGroup:setChecked(false) self.m_FromAdmin:setChecked(false) end

	self.m_FromCompany = GUIGridCheckbox:new(1, 5, 1, 1, "Unternehmen", self.m_Window)
	self.m_FromCompany.onChange = function() self.m_FromPlayer:setChecked(false) self.m_FromFaction:setChecked(false) self.m_FromGroup:setChecked(false) self.m_FromAdmin:setChecked(false) end

	self.m_FromGroup = GUIGridCheckbox:new(1, 6, 1, 1, "Firma/Gang", self.m_Window)
	self.m_FromGroup.onChange = function() self.m_FromPlayer:setChecked(false) self.m_FromFaction:setChecked(false) self.m_FromCompany:setChecked(false) self.m_FromAdmin:setChecked(false) end

	self.m_FromAdmin = GUIGridCheckbox:new(1, 7, 1, 1, "Adminkasse", self.m_Window)
	self.m_FromAdmin.onChange = function() self.m_FromPlayer:setChecked(false) self.m_FromFaction:setChecked(false) self.m_FromCompany:setChecked(false) self.m_FromGroup:setChecked(false) end
	

	self.m_ArrowLabel = GUIGridLabel:new(7, 2, 1, 1, ">>>", self.m_Window):setAlignX("center")

	
	self.m_To = GUIGridEdit:new(8, 2, 6, 1, self.m_Window):setCaption("Name")
	self.m_ToPlayer = GUIGridCheckbox:new(8, 3, 1, 1, "Spieler", self.m_Window)
	self.m_ToPlayer.onChange = function() self.m_ToFaction:setChecked(false) self.m_ToCompany:setChecked(false) self.m_ToGroup:setChecked(false) self.m_ToAdmin:setChecked(false) end

	self.m_ToFaction = GUIGridCheckbox:new(8, 4, 1, 1, "Fraktion", self.m_Window)
	self.m_ToFaction.onChange = function() self.m_ToPlayer:setChecked(false) self.m_ToCompany:setChecked(false) self.m_ToGroup:setChecked(false) self.m_ToAdmin:setChecked(false) end

	self.m_ToCompany = GUIGridCheckbox:new(8, 5, 1, 1, "Unternehmen", self.m_Window)
	self.m_ToCompany.onChange = function() self.m_ToPlayer:setChecked(false) self.m_ToFaction:setChecked(false) self.m_ToGroup:setChecked(false) self.m_ToAdmin:setChecked(false) end

	self.m_ToGroup = GUIGridCheckbox:new(8, 6, 1, 1, "Firma/Gang", self.m_Window)
	self.m_ToGroup.onChange = function() self.m_ToPlayer:setChecked(false) self.m_ToFaction:setChecked(false) self.m_ToCompany:setChecked(false) self.m_ToAdmin:setChecked(false) end

	self.m_ToAdmin = GUIGridCheckbox:new(8, 7, 1, 1, "Adminkasse", self.m_Window)
	self.m_ToAdmin.onChange = function() self.m_ToPlayer:setChecked(false) self.m_ToFaction:setChecked(false) self.m_ToCompany:setChecked(false) self.m_ToGroup:setChecked(false) end
	
	self.m_SendButton = GUIGridButton:new(5, 8, 5, 1, "Überweisen", self.m_Window)
	self.m_SendButton.onLeftClick = bind(self.sendMoney, self)
end

function AdminTransactionGUI:destructor()
	GUIForm.destructor(self)
end

function AdminTransactionGUI:sendMoney()
	local amount = tonumber(self.m_Amount:getText())
	local from = self.m_From:getText()
	local to = self.m_To:getText()
	local fromType = false
	local toType = false
	if self.m_FromPlayer:isChecked() then 	fromType = "player" end
	if self.m_FromFaction:isChecked() then 	fromType = "faction" end
	if self.m_FromCompany:isChecked() then 	fromType = "company" end
	if self.m_FromGroup:isChecked() then 	fromType = "group" end
	if self.m_FromAdmin:isChecked() then 	fromType = "admin" end

	if self.m_ToPlayer:isChecked() then 	toType = "player" end
	if self.m_ToFaction:isChecked() then 	toType = "faction" end
	if self.m_ToCompany:isChecked() then 	toType = "company" end
	if self.m_ToGroup:isChecked() then 		toType = "group" end
	if self.m_ToAdmin:isChecked() then 		toType = "admin" end

	triggerServerEvent("adminTriggerTransaction", localPlayer, amount, from, fromType, to, toType)
end