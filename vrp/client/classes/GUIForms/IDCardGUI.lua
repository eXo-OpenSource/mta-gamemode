-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/IDCardGUI.lua
-- *  PURPOSE:     ID-Card GUI
-- *
-- ****************************************************************************
IDCardGUI = inherit(GUIForm)

addRemoteEvents{"showIDCard"}

function IDCardGUI:constructor(player)

	if not player then player = localPlayer end

	GUIForm.constructor(self, screenWidth/2-400/2, screenHeight/2-250/2, 400, 250)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Ausweis/Führerschein", true, true, self)
	GUIWebView:new(10, 40, 160, 180, "http://exo-reallife.de/ingame/skinPreview/skinPreviewHead.php?skin="..player:getModel(), true, self)

	GUILabel:new(200, 40, 160, 30, player:getName(), self)

	GUILabel:new(200, 75, 140, 25, _"Lizenzen:", self)

	GUILabel:new(200, 100, 140, 20, _"Auto-Führerschein:", self)
	GUILabel:new(200, 120, 140, 20, _"Motorrad-Schein:", self)
	GUILabel:new(200, 140, 140, 20, _"LKW-Schein:", self)
	GUILabel:new(200, 160, 140, 20, _"Flugschein:", self)

	self.m_LicenseLabels = {}

	self.m_LicenseLabels["car"] = GUILabel:new(370, 100, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["bike"] = GUILabel:new(370, 120, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["truck"] = GUILabel:new(370, 140, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["pilot"] = GUILabel:new(370, 160, 40, 25, FontAwesomeSymbols.Square, self)

	self.m_RegistrationLabel = GUILabel:new(200, 215, 190, 18, _"Registriert seit: -", self)


	for index, label in pairs(self.m_LicenseLabels) do
		label:setFont(FontAwesome(20))
		label:setColor(Color.Red)
	end

	triggerServerEvent("Event_getIDCardData", localPlayer, player)

	addRemoteEvents{"Event_receiveIDCardData"}
	addEventHandler("Event_receiveIDCardData", root, bind(self.Event_receiveIDCardData, self))
end

function IDCardGUI:Event_receiveIDCardData(car, bike, truck, pilot, registrationDate)
	local carSymbol, carColor = self:getSymbol(car)
	self.m_LicenseLabels["car"]:setText(carSymbol)
	self.m_LicenseLabels["car"]:setColor(carColor)
	local bikeSymbol, bikeColor = self:getSymbol(bike)
	self.m_LicenseLabels["bike"]:setText(bikeSymbol)
	self.m_LicenseLabels["bike"]:setColor(bikeColor)
	local truckSymbol, truckColor = self:getSymbol(truck)
	self.m_LicenseLabels["truck"]:setText(truckSymbol)
	self.m_LicenseLabels["truck"]:setColor(truckColor)
	local pilotSymbol, pilotColor = self:getSymbol(pilot)
	self.m_LicenseLabels["pilot"]:setText(pilotSymbol)
	self.m_LicenseLabels["pilot"]:setColor(pilotColor)

	self.m_RegistrationLabel:setText(_("Registriert seit: %s", getOpticalTimestamp(registrationDate)))
end

function IDCardGUI:getSymbol(bool)
	if bool == true then
		return FontAwesomeSymbols.Check, Color.Green
	else
		return FontAwesomeSymbols.Square, Color.Red
	end
end

addEventHandler("showIDCard", root, function(target)
	IDCardGUI:new(target)
end)
