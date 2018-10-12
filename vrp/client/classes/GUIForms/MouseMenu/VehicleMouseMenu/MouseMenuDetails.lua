-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuDetails.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuDetails = inherit(GUIMouseMenu)

function VehicleMouseMenuDetails:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	self:addItem(_"Tunings anzeigen",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleGetTuningList", self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Search)

	self:addItem(_"Fahrzeug-Performance",
		function()
			if self:getElement() then
				if VehiclePerformanceGUI.Map[self:getElement()]  then
					VehiclePerformanceGUI.Map[self:getElement()]:delete()
				end
				VehiclePerformanceGUI.Map[self:getElement()] = VehiclePerformanceGUI:new(self:getElement(), false)
			end
		end
	):setIcon(FontAwesomeSymbols.Search)

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["tuneVehicle"] then
		self:addItem(_"Handling",
			function()
				if self:getElement() then
					if VehiclePerformanceGUI.Map[self:getElement()]  then
						VehiclePerformanceGUI.Map[self:getElement()]:delete()
					end
					VehiclePerformanceGUI.Map[self:getElement()] = VehiclePerformanceGUI:new(self:getElement(), true)
				end
			end
		)
	end

	self:addItem(_("Fahrgestellnr: %s", element:getData("ID") or -1)):setTextColor(Color.White)
	self:addItem(_("Kategorie: %s", element:getCategoryName())):setTextColor(Color.White)
	self:addItem(_("Steuern: %s $ / PayDay", element:getTax())):setTextColor(Color.White)
	self:addItem(_("Sprittyp: %s", FUEL_NAME[element:getFuelType()])):setTextColor(Color.White)
	self:addItem(_("Tankgröße: %s Liter", element:getFuelTankSize())):setTextColor(Color.White)
	if DEBUG then
		self:addItem(_("Tankinhalt: %s  Liter (%s%%)",element:getFuel()/100*element:getFuelTankSize(), element:getFuel())):setTextColor(Color.White)
		self:addItem(_("Verbrauchsmult.: %s",element:getFuelConsumptionMultiplicator())):setTextColor(Color.White)
	end
	
	self:adjustWidth()
end
