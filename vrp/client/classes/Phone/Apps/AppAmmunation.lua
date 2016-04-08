-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppAmmunation.lua
-- *  PURPOSE:     AppAmmunation app class
-- *
-- ****************************************************************************
AppAmmunation = inherit(PhoneApp)

function AppAmmunation:constructor()
	PhoneApp.constructor(self, "Ammu Nation", "IconAmmuNation.png")
end

function AppAmmunation:onOpen(form)
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["Info"] = self.m_TabPanel:addTab(_"Information", FontAwesomeSymbols.Info)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Ammunation", self.m_Tabs["Info"])
	self.m_Tabs["Order"] = self.m_TabPanel:addTab(_"Bestellen", FontAwesomeSymbols.CartPlus)
	self.m_Tabs["Basket"] = self.m_TabPanel:addTab(_"Warenkorb", FontAwesomeSymbols.Money)

end

function AppAmmunation:onClose()

end
