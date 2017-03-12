-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PublicTransportTaxoMeterGUI.lua
-- *  PURPOSE:     Public Transport TaxoMeter
-- *
-- ****************************************************************************
PublicTransportTaxoMeterGUI = inherit(GUIForm)
inherit(Singleton, PublicTransportTaxoMeterGUI)

addRemoteEvents{"showTaxoMeter", "hideTaxoMeter", "syncTaxoMeter", "syncDriverTaxoMeter"}

function PublicTransportTaxoMeterGUI:constructor(type)
	GUIForm.constructor(self, screenWidth/2-(400/2), 10, 400, 176, false)
	GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Other/TaxoMeter.png", self)
	self.m_Driver = false

	if localPlayer:getOccupiedVehicleSeat() == 0 then
		self.m_Driver = true
		self.m_CustomerName, self.m_CustomerDistance, self.m_CustomerPrice = {}, {}, {}
		for i = 1, 3 do
			self.m_CustomerName[i] = GUILabel:new(50+120*(i-1), 75, 195, 20, _"kein Kunde", self)
			self.m_CustomerDistance[i] = GUILabel:new(50+120*(i-1), 95, 195, 20, "0 km", self)
			self.m_CustomerPrice[i] = GUILabel:new(50+120*(i-1), 115, 195, 20, "0 $", self)
		end
	else
		self.m_Driver = false
		GUILabel:new(50, 75, 195, 30, _"Zurückgelegte Strecke:", self)
		self.m_Distance = GUILabel:new(270, 75, 80, 30, _"0 km", self):setAlignX("right")
		GUILabel:new(50, 100, 195, 30, _"Fahrpreis:", self)
		self.m_Price = GUILabel:new(270, 100, 80, 30, _"0 $", self):setAlignX("right")
	end
	self.m_Vehicle = localPlayer:getOccupiedVehicle()
	addEventHandler("syncTaxoMeter", root, bind(self.syncTaxoMeter, self))
	addEventHandler("syncDriverTaxoMeter", root, bind(self.syncDriverTaxoMeter, self))
end

function PublicTransportTaxoMeterGUI:syncTaxoMeter(distance, price)
	if self.m_Driver == false then
		self.m_Distance:setText(_("%s km", math.round(distance,2)))
		self.m_Price:setText(_("%d $", price))
	end
end

function PublicTransportTaxoMeterGUI:syncDriverTaxoMeter(customerTable)
	if self.m_Driver == true then
		for i = 1, 3 do
			if customerTable[i] then
				self.m_CustomerName[i]:setText(customerTable[i]["customer"]:getName())
				self.m_CustomerDistance[i]:setText(_("%s km", math.round(customerTable[i]["diff"],2)))
				self.m_CustomerPrice[i]:setText(_("%d $", customerTable[i]["price"]))
			else
				self.m_CustomerName[i]:setText("kein Kunde")
				self.m_CustomerDistance[i]:setText("0 km")
				self.m_CustomerPrice[i]:setText("0 $")
			end
		end
	end
end

addEventHandler("showTaxoMeter", root,
	function(type)
		PublicTransportTaxoMeterGUI:new(type)
	end
)

addEventHandler("hideTaxoMeter", root,
	function()
		delete(PublicTransportTaxoMeterGUI:getSingleton())
	end
)
