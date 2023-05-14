-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HousesForSaleGUI.lua
-- *  PURPOSE:     HousesForSale GUI class
-- *
-- ****************************************************************************
HousesForSaleGUI = inherit(GUIForm)
inherit(Singleton, HousesForSaleGUI)

function HousesForSaleGUI:constructor(ped)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 25)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, ped)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Zum Verkauf stehende Häuser", true, true, self)
	self.m_Grid = GUIGridGridList:new(1, 1, 24, 9, self.m_Window)
	self.m_Grid:addColumn(_"Haus Nr", 0.08)
	self.m_Grid:addColumn(_"Aktueller Besitzer", 0.27)	
	self.m_Grid:addColumn(_"Ort", 0.27)
	self.m_Grid:addColumn(_"Garagen", 0.10)
	self.m_Grid:addColumn(_"Grundpreis", 0.13)
	self.m_Grid:addColumn(_"Verkaufspreis", 0.15)
	
	self.m_LocateButton = GUIGridButton:new(1, 11, 24, 1, _"Position vom Haus anzeigen", self.m_Window)
	self.m_LocateButton.onLeftClick = bind(self.onLocateButtonClick, self)

	addRemoteEvents{"sendHousesForSale"}
	addEventHandler("sendHousesForSale", localPlayer, bind(self.recieveHouseData, self))

	triggerServerEvent("requestHousesForSale", localPlayer)
end

function HousesForSaleGUI:destructor()
	GUIForm.destructor(self)
end

function HousesForSaleGUI:recieveHouseData(houseTbl)
	for houseId, data in pairs(houseTbl) do
		local garageText = data["GarageCount"] > 0 and ("%sx"):format(data["GarageCount"]) or "Keine"
		local item = self.m_Grid:addItem("#"..houseId, data["OwnerName"], data["ZoneName"], _(garageText) , toMoneyString(data["HousePrice"]), toMoneyString(data["SalePrice"]))
		item.Id = houseId
		item.Position = data["Position"]
	end
end

function HousesForSaleGUI:onLocateButtonClick()
	if self.m_Grid:getSelectedItem() then
		local item = self.m_Grid:getSelectedItem()
		if item.Position then
			local blipPos = Vector2(item.Position.x, item.Position.y)
			ShortMessage:new("Klicke um das Haus auf der Karte zu markieren.\n(Beachte, dass du nicht in einem Interior sein darfst)", "Haus", false, -1, function()
				GPS:getSingleton():startNavigationTo(item.Position)
			end, false, blipPos, {{path = "Marker.png", pos = blipPos}})
		else
			ErrorBox:new(_"Fehler: Haus hat keine Position")
		end
	else
		WarningBox:new(_"Kein Haus ausgewählt!")
	end
end
