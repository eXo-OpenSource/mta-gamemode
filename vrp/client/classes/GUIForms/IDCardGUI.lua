-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/IDCardGUI.lua
-- *  PURPOSE:     ID-Card GUI
-- *
-- ****************************************************************************
IDCardGUI = inherit(GUIForm)

function IDCardGUI:constructor(player)

	if not player then player = localPlayer end

	GUIForm.constructor(self, screenWidth/2-400/2, screenHeight/2-250/2, 400, 250)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Ausweis/Führerschein", true, true, self)
	GUIWebView:new(20, 40, 200, 200, "http://exo-reallife.de/ingame/skinPreview/skinPreviewHead.php?skin="..player:getModel(), true, self)

	GUILabel:new(220, 40, 160, 30, player:getName(), self)

	GUILabel:new(220, 80, 130, 20, _"Auto-Führerschein:", self)
	GUILabel:new(220, 100, 140, 20, _"Motorrad-Schein:", self)
	GUILabel:new(220, 120, 140, 20, _"LKW-Schein:", self)
	GUILabel:new(220, 140, 140, 20, _"Flugschein:", self)

	self.m_Car = GUILabel:new(370, 80, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_Car:setFont(FontAwesome(20))
	self.m_Bike = GUILabel:new(370, 100, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_Bike:setFont(FontAwesome(20))
	self.m_Truck = GUILabel:new(370, 120, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_Truck:setFont(FontAwesome(20))
	self.m_Pilot = GUILabel:new(370, 140, 40, 25, FontAwesomeSymbols.Square, self)
	self.m_Pilot:setFont(FontAwesome(20))

	triggerServerEvent("Event_getIDCardData", localPlayer, player)

	addRemoteEvents{"Event_receiveIDCardData"}
	addEventHandler("Event_receiveIDCardData", root, bind(self.Event_receiveIDCardData, self))
end

function IDCardGUI:Event_receiveIDCardData(car, bike, truck, pilot)
	local carSymbol, carColor = self:getSymbol(car)
	self.m_Car:setText(carSymbol)
	self.m_Car:setColor(carColor)
	local bikeSymbol, bikeColor = self:getSymbol(bike)
	self.m_Bike:setText(bikeSymbol)
	self.m_Bike:setColor(bikeColor)
	local truckSymbol, truckColor = self:getSymbol(truck)
	self.m_Truck:setText(truckSymbol)
	self.m_Truck:setColor(truckColor)
	local pilotSymbol, pilotColor = self:getSymbol(pilot)
	self.m_Pilot:setText(pilotSymbol)
	self.m_Pilot:setColor(pilotColor)
end

function IDCardGUI:getSymbol(bool)
	if bool == true then
		return FontAwesomeSymbols.Check, Color.Green
	else
		return FontAwesomeSymbols.Square, Color.Red
	end
end
