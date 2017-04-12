-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppBank.lua
-- *  PURPOSE:     AppBank app class
-- *
-- ****************************************************************************
AppNavigator = inherit(PhoneApp)

function AppNavigator:constructor()
	PhoneApp.constructor(self, "eXo Navigator", "IconNavigator.png")
end

function AppNavigator:onOpen(form)

	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_LocationsGrid = {}
	self.m_StartNavigation = {}

	local item

	for category, data in pairs(AppNavigator.Positions) do
		self.m_Tabs[category] = self.m_TabPanel:addTab(category, AppNavigator.Icons[category])
		self.m_LocationsGrid[category] = GUIGridList:new(10, 10, form.m_Width-20, form.m_Height-110, self.m_Tabs[category])
		self.m_LocationsGrid[category]:addColumn(category, 1)

		for name, pos in pairs(data) do
			item = self.m_LocationsGrid[category]:addItem(name)
			item.Position = pos
			item.onLeftDoubleClick = function() self:startNavigationClick(pos) end
		end

		self.m_StartNavigation[category] = GUILabel:new(10, 360, form.m_Width-20, 25, _"Doppelklick um die \nNavigation zu starten!", self.m_Tabs[category]):setMultiline(true):setAlignX("center")

	end


end

function AppNavigator:startNavigationClick(pos)
	if pos then
		GPS:getSingleton():startNavigationTo(pos)
	else
		ErrorBox:new(_"Keinen Punkt ausgewählt!")
		return
	end
end

AppNavigator.Positions = {
	["Allgemein"] = {
		["Noobspawn"] = Vector3(1479.99, -1747.69, 13.55),
		["Flughafen LS"] = Vector3(1993.06, -2187.38, 13.23),
		["Premium-Bereich"] = Vector3(1246.52, -2055.33, 59.53),
		["Stadthalle"] = Vector3(1802.17, -1284.10, 13.33),
		["Tuning-Shop"] = Vector3(1035.58, -1028.90, 32.10),
		["Gebrauchtwagenhändler"] = Vector3(1098.83, -1240.20, 15.55),
		["Kart-Strecke"] = Vector3(1262.375, 188.479, 19.5),
	},
	["Jobs"] = {
		["Pizza-Lieferant"] = Vector3(2096.89, -1826.28, 13.24),
		["Heli-Transport"] = Vector3(1796.39, -2318.27, 13.11),
		["Müllwagen-Job"] = Vector3(2102.45, -2094.60, 13.23),
		["Logistiker Blueberry"] = Vector3(-234.96, -254.46,  1.11),
		["Logistiker LS Hafen"] = Vector3(2409.07, -2471.10, 13.30),
		["Farmer"] = Vector3(-53.69, 78.28, 2.79),
		["Straßenreinigung"] = Vector3(219.49, -1429.61, 13.0),
		["Schatzsucher"] = Vector3(706.22, -1699.38, 3.12),
		["Gabelstapler"] = Vector3(93.67, -205.68,  1.23),
		["Kiesgruben-Job"] = Vector3(590.71, 868.91, -42.50),
		["Holzfäller"] = Vector3(1104.27, -298.06, 73.99)
	},
	["Unternehmen"] = {
		["San News"] =     Vector3(762.05, -1343.33, 13.20),
		["Fahrschule"] =  Vector3(1372.30, -1655.55, 13.38),
		["Mechaniker"] =  Vector3(886.21, -1220.47, 16.97),
		["Public Transport"] =	 Vector3(1791.10, -1901.46, 13.08),
	},
	["Fraktionen"] = {
		--["Grove Street"] =   Vector3(2492.43, -1664.58, 13.34),
		--["Cosa Nostra"] =     Vector3(722.84, -1196.875, 19.123),
		["Yakuza"] =     Vector3(2414.449, -2090.311, 13.426),
		["Vatos Locos"] =     Vector3(2828.332, -2111.481, 12.206),
		["Rescue Team"] =  Vector3(1727.42, -1738.01, 13.14),
		["FBI"] =     Vector3(1534.83, -1440.72, 13.16),
		["Police Department"] =      Vector3(1536.06, -1675.63, 13.11),
		["SA Army Base"] =    Vector3(134.53, 1929.06,  18.89),
		["Ballas"] =  Vector3(2213.78, -1435.18, 23.83),
		["Outlaws MC"] =   Vector3(684.82, -485.55, 16.19),
	}

}

AppNavigator.Icons = {
	["Allgemein"] = FontAwesomeSymbols.Info,
	["Jobs"] = FontAwesomeSymbols.Suitcase,
	["Unternehmen"] = FontAwesomeSymbols.Book,
	["Fraktionen"] = FontAwesomeSymbols.Group,
}

