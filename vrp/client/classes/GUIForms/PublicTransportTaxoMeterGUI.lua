-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PublicTransportTaxoMeterGUI.lua
-- *  PURPOSE:     Public Transport TaxoMeter
-- *
-- ****************************************************************************
PublicTransportTaxoMeterGUI = inherit(GUIForm)
inherit(Singleton, PublicTransportTaxoMeterGUI)

addRemoteEvents{"showTaxoMeter", "hideTaxoMeter", "syncTaxoMeter"}

function PublicTransportTaxoMeterGUI:constructor(type)
	GUIForm.constructor(self, screenWidth/2-(400/2), 10, 400, 176, false)
	GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Other/TaxoMeter.png", self)
	GUILabel:new(50, 75, 195, 30, _"Zurückgelegte Strecke:", self)
	self.m_Distance = GUILabel:new(270, 75, 80, 30, _"0 km", self):setAlignX("right")
	GUILabel:new(50, 100, 195, 30, _"Fahrpreis:", self)
	self.m_Price = GUILabel:new(270, 100, 80, 30, _"0 $", self):setAlignX("right")

	self.m_Vehicle = localPlayer:getOccupiedVehicle()
	addEventHandler("syncTaxoMeter", root, bind(self.syncTaxoMeter, self))

end

function PublicTransportTaxoMeterGUI:syncTaxoMeter(distance, price)
	self.m_Distance:setText(_("%s km", math.round(distance,2)))
	self.m_Price:setText(_("%d $", price))
end

addEventHandler("showTaxoMeter", root,
	function(type)
		PublicTransportTaxoMeterGUI:new(type)
	end
)

addEventHandler("hideTaxoMeter", root,
	function()
		PublicTransportTaxoMeterGUI:getSingleton():delete()
	end
)
