-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/VehicleMechanicTakeGUI.lua
-- *  PURPOSE:     GUI form class
-- *
-- ****************************************************************************
PremiumVehicleGUI = inherit(GUIForm)

function PremiumVehicleGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.2/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.2, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeuge abholen", true, true, self)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.8, self.m_Window)
		:addColumn("Fahrzeugname", 1)

	self.m_TakeButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Freikaufen (500$)", self.m_Window):setBarEnabled(true)
	self.m_TakeButton.onLeftClick = bind(self.TakeButton_Click, self)
end

function PremiumVehicleGUI:setVehicles(vehicles)
	self.m_Grid:clear()
	for k, vehicle in pairs(vehicles) do
		local item = self.m_Grid:addItem(vehicle:getName())
		item.Vehicle = vehicle
		item.onLeftDoubleClick = bind(self.TakeButton_Click, self)
	end
end

function PremiumVehicleGUI:setCallback(callback)
	if type(callback) == "string" then
		self.m_Callback = function ()
			local selectedItem = self.m_Grid:getSelectedItem()
			if not selectedItem then
				ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
				return
			end

			if selectedItem.Vehicle then
				triggerServerEvent(callback, selectedItem.Vehicle)
			end
		end
	else
		self.m_Callback = callback
	end
end

function PremiumVehicleGUI:TakeButton_Click()
	if self.m_Callback then
		self.m_Callback()
	end
	delete(self)
end


addEvent("openPremiumVehicleGUI", true)
addEventHandler("openPremiumVehicleGUI", root,
	function(vehicles, callbackEvent)
		local gui = PremiumVehicleGUI:new()
		gui:setVehicles(vehicles)
		gui:setCallback(callbackEvent)
	end
)
