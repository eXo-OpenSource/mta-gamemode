-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/IDCardGUI.lua
-- *  PURPOSE:     ID-Card GUI
-- *
-- ****************************************************************************
IDCardGUI = inherit(GUIForm)
inherit(Singleton, IDCardGUI)

addRemoteEvents{"showIDCard"}

function IDCardGUI:constructor(player)

	if not player then player = localPlayer end

	GUIForm.constructor(self, screenWidth/2-400/2, screenHeight/2-250/2, 400, 250)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Ausweis/Führerschein", true, true, self)
	GUIWebView:new(10, 30, 140, 160, "http://exo-reallife.de/ingame/skinPreview/skinPreviewHead.php?skin="..player:getModel(), true, self)

	GUILabel:new(200, 40, 160, 30, player:getName(), self)

	GUILabel:new(200, 75, 140, 25, _"Lizenzen:", self)

	GUILabel:new(200, 100, 140, 20, _"Autoführerschein:", self)
	GUILabel:new(200, 120, 140, 20, _"Motorradschein:", self)
	GUILabel:new(200, 140, 140, 20, _"LKW-Schein:", self)
	GUILabel:new(200, 160, 140, 20, _"Flugschein:", self)
	GUILabel:new(200, 190, 140, 20, _"GWD-Note:", self)
	GUILabel:new(200, 210, 140, 20, _"StVO-Punkte:", self)



	self.m_LicenseLabels = {}

	self.m_LicenseLabels["car"] = GUILabel:new(370, 100, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["bike"] = GUILabel:new(370, 120, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["truck"] = GUILabel:new(370, 140, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_LicenseLabels["pilot"] = GUILabel:new(370, 160, 40, 25, FontAwesomeSymbols.Square, self)

	self.m_PaNote = GUILabel:new(340, 190, 40, 20, "-keine-", self):setAlignX("right")
	self.m_STVO = GUILabel:new(320, 210, 60, 20, "-keine-", self):setAlignX("right")

	GUILabel:new(10, 160, 140, 20, _"Joblevel:", self)
	GUILabel:new(10, 180, 140, 20, _"Waffenlevel:", self)
	GUILabel:new(10, 200, 140, 20, _"Fahrzeuglevel:", self)
	GUILabel:new(10, 220, 140, 20, _"Skinlevel:", self)

	self.m_LevelLabels = {}
	self.m_LevelLabels["job"] = GUILabel:new(140, 160, 40, 20, "0", self)
	self.m_LevelLabels["weapon"] = GUILabel:new(140, 180, 40, 20, "0", self)
	self.m_LevelLabels["vehicle"] = GUILabel:new(140, 200, 40, 20, "0", self)
	self.m_LevelLabels["skin"] = GUILabel:new(140, 220, 40, 20, "0", self)

	--self.m_RegistrationLabel = GUILabel:new(200, 220, 190, 18, _"Registriert seit: -", self)


	for index, label in pairs(self.m_LicenseLabels) do
		label:setFont(FontAwesome(20))
		label:setColor(Color.Red)
	end

	triggerServerEvent("Event_getIDCardData", localPlayer, player)

	addRemoteEvents{"Event_receiveIDCardData"}
	addEventHandler("Event_receiveIDCardData", root, bind(self.Event_receiveIDCardData, self))
end

function IDCardGUI:Event_receiveIDCardData(car, bike, truck, pilot, registrationDate, paNote, stvo, jobLevel, weaponLevel, vehicleLevel, skinLevel)
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

	self.m_LevelLabels["job"]:setText(tostring(jobLevel))
	self.m_LevelLabels["weapon"]:setText(tostring(weaponLevel))
	self.m_LevelLabels["vehicle"]:setText(tostring(vehicleLevel))
	self.m_LevelLabels["skin"]:setText(tostring(skinLevel))

	self.m_PaNote:setText(paNote == 0 and "-keine-" or paNote.."%")
	self.m_STVO:setText(stvo == 0 and "-keine-" or stvo.." Punkt/e")

	--self.m_RegistrationLabel:setText(_("Registriert seit: %s", registrationDate))
end

function IDCardGUI:getSymbol(bool)
	if bool == true then
		return FontAwesomeSymbols.CheckSquare, Color.Green
	else
		return FontAwesomeSymbols.Square, Color.Red
	end
end

addEventHandler("showIDCard", root, function(target)
	IDCardGUI:new(target)
end)
