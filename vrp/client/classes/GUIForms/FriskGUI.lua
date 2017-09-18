-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FriskGUI.lua
-- *  PURPOSE:     Frisk GUI
-- *
-- ****************************************************************************
FriskGUI = inherit(GUIForm)
inherit(Singleton, FriskGUI)

addRemoteEvents{"showFriskGUI" }

function FriskGUI:constructor(player, weapons, drugs)
	GUIForm.constructor(self, screenWidth/2-320/2, screenHeight/2-250/2, 320, 250)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	local tabWeapons = self.m_TabPanel:addTab(_("Waffen"))
	local tabDrugs = self.m_TabPanel:addTab(_("Drogen"))

	self.m_WeaponList = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-50, tabWeapons)
	self.m_WeaponList:addColumn("Waffen", .6)
	self.m_WeaponList:addColumn("Munition", .4)

	self.m_DrugList = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-50, tabDrugs)
	self.m_DrugList:addColumn("Drogen", .6)
	self.m_DrugList:addColumn("Gewicht", .4)

	for weaponID, totalAmmo in pairs(weapons) do
		self.m_WeaponList:addItem(WEAPON_NAMES[weaponID], totalAmmo)
	end

	for drug, amount in pairs(drugs) do
		self.m_DrugList:addItem(drug, ("%dg"):format(amount))
	end
end

addEventHandler("showFriskGUI", root,
	function(...)
		FriskGUI:new(...)
	end
)
