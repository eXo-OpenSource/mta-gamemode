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

	-- update faction list
	for id, fac in pairs(FactionManager.Map) do
		AppNavigator.Positions["Fraktionen"][fac:getName()] = fac:getNavigationPosition()
	end

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
		["Noobspawn"] = Vector3(1481.33, -1765.05, 18.80),
		["Flughafen LS"] = Vector3(1993.06, -2187.38, 13.23),
		["Premium-Bereich"] = Vector3(1246.52, -2055.33, 59.53),
		["Stadthalle"] = Vector3(1481.22, -1749.11, 15.45),
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
		["Holzfäller"] = Vector3(1026.51, -437.73, 54.24)
	},
	["Unternehmen"] = {
		["San News"] =     Vector3(762.05, -1343.33, 13.20),
		["Fahrschule"] =  Vector3(1372.30, -1655.55, 13.38),
		["Mechaniker"] =  Vector3(886.21, -1220.47, 16.97),
		["Public Transport"] =	 Vector3(1791.10, -1901.46, 13.08),
	},
	["Fraktionen"] = {}, -- get loaded dynamically!

}

AppNavigator.Icons = {
	["Allgemein"] = FontAwesomeSymbols.Info,
	["Jobs"] = FontAwesomeSymbols.Suitcase,
	["Unternehmen"] = FontAwesomeSymbols.Book,
	["Fraktionen"] = FontAwesomeSymbols.Group,
}
