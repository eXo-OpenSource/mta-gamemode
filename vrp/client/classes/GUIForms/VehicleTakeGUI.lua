-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/VehicleMechanicTakeGUI.lua
-- *  PURPOSE:     GUI form class
-- *
-- ****************************************************************************
VehicleTakeGUI = inherit(GUIForm)

function VehicleTakeGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.2/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.2, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeuge abholen", true, true, self)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 35, self.m_Width*0.96, self.m_Height*0.8, self.m_Window)
		:addColumn("Fahrzeugname", 1)

	self.m_TakeButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.9, self.m_Width*0.96, self.m_Height*0.08, _"Freikaufen (500$)", true, self.m_Window)
	self.m_TakeButton.onLeftClick = bind(self.TakeButton_Click, self)
end

function VehicleTakeGUI:setVehicles(vehicles)
	self.m_Grid:clear()
	for k, vehicle in pairs(vehicles) do
		local name = type(vehicle) == "userdata" and vehicle:getName() or getVehicleNameFromModel(vehicle)
		local item = self.m_Grid:addItem(name)
		item.Vehicle = vehicle
		item.onLeftDoubleClick = bind(self.TakeButton_Click, self)
	end
end

function VehicleTakeGUI:setCallback(callback)
	if type(callback) == "string" then
		self.m_Callback = function ()
			local selectedItem = self.m_Grid:getSelectedItem()
			if not selectedItem then
				ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
				return
			end

			if selectedItem.Vehicle and type(selectedItem.Vehicle) == "userdata" then
				triggerServerEvent(callback, selectedItem.Vehicle)
			else
				triggerServerEvent(callback, localPlayer, selectedItem.Vehicle)
			end
		end
	else
		self.m_Callback = callback
	end
end

function VehicleTakeGUI:TakeButton_Click()
	if self.m_Callback then
		self.m_Callback()
	end
	delete(self)
end


addEvent("vehicleTakeMarkerGUI", true)
addEventHandler("vehicleTakeMarkerGUI", root,
	function(vehicles, callbackEvent, buttonText)
		if MechanicTow:getSingleton().ms_SelectionGUI then
			MechanicTow:getSingleton().ms_SelectionGUI:delete()
		end

		local gui = VehicleTakeGUI:new()
		gui:setVehicles(vehicles)
		gui:setCallback(callbackEvent)
		if buttonText then
			gui.m_TakeButton:setText(buttonText)
		end
	end
)
