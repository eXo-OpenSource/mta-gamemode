-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/VehicleMechanicTakeGUI.lua
-- *  PURPOSE:     GUI form class
-- *
-- ****************************************************************************
VehicleMechanicTakeGUI = inherit(GUIForm)

function VehicleMechanicTakeGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.2/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.2, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeuge abholen", true, true, self)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.8, self.m_Window)
		:addColumn("Fahrzeugname", 1)

	self.m_TakeButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Reparieren (500$)", true, self.m_Window)
	self.m_TakeButton.onLeftClick = bind(self.TakeButton_Click, self)
end

function VehicleMechanicTakeGUI:setVehicles(vehicles)
	self.m_Grid:clear()
	for k, vehicle in pairs(vehicles) do
		local item = self.m_Grid:addItem(vehicle:getName())
		item.Vehicle = vehicle
	end
end

function VehicleMechanicTakeGUI:TakeButton_Click()
	local selectedItem = self.m_Grid:getSelectedItem()
	if not selectedItem then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	if selectedItem.Vehicle then
		triggerServerEvent("mechanicTakeVehicle", selectedItem.Vehicle)
	end
	delete(self)
end


addEvent("vehicleTakeMarkerGUI", true)
addEventHandler("vehicleTakeMarkerGUI", root,
	function(vehicles)
		local gui = VehicleMechanicTakeGUI:new()
		gui:setVehicles(vehicles)
	end
)
