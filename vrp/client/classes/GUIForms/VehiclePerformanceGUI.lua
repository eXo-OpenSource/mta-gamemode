-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehiclePerformanceGUI.lua
-- *  PURPOSE:     VehiclePerformanceGUI Progress Bar class
-- *
-- ****************************************************************************
VehiclePerformanceGUI = inherit(GUIForm)
inherit(Object, VehiclePerformanceGUI)
function VehiclePerformanceGUI:constructor( vehicle )
	self.m_Vehicle = vehicle
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window
	GUIForm.constructor(self, screenWidth-450, screenHeight-450, 450, 450, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Performance", true, true, self)
	self.m_DriveTypeValues = 
	{
		["rwd"] = 0,
		["awd"] = 1, 
		["fwd"] = 2,
	}
	self.m_TabNames = {
		"Alles", 
		"Motor", 
		"Reifen",
		"Fahrwerk", 
		"Bremsen"
	}
	
	self:setupPanels()

end	

function VehiclePerformanceGUI:setupPanels()
	self.m_ProgressBars = {}
	self.m_SliderBars = {}
	self.m_Labels = {}
	self.m_LabelValues = {}
	self.m_LabelDescription = {}
	self.m_ScrollAreas = {}
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel(self.m_TabNames) 
	self.m_TabPanel:updateGrid()
	self:fillAllTabs()
end

function VehiclePerformanceGUI:fillAllTabs(  )
	
	local documentHeight = 0
	for i = 1, #self.m_Tabs do 
		tab = self.m_Tabs[i]
		if i == 1 then
			
			for category, handling in pairs(VEHICLE_TUNINGKIT_CATEGORIES) do 
				for i = 1, #handling do documentHeight = documentHeight + 2 end
			end
			
			self.m_ScrollAreas[i] = GUIGridScrollableArea:new(1, 1, 11, 12, 16, documentHeight+4, true, false, tab)
			self.m_Offset = 1
			for category, handling in pairs(VEHICLE_TUNINGKIT_CATEGORIES) do 
				self:fillTab(handling, self.m_ScrollAreas[i])
			end
		else 
			self.m_ScrollAreas[i] = GUIGridScrollableArea:new(1, 1, 11, 12, 16, documentHeight+4, true, false, tab)
			
			self.m_Offset = 1
			self:fillTab(VEHICLE_TUNINGKIT_CATEGORIES[self.m_TabNames[i]], self.m_ScrollAreas[i])
		end
	end
	for i = 1, #self.m_Tabs do 
		self.m_ScrollAreas[i]:updateGrid()
	end
end

function VehiclePerformanceGUI:fillTab(handling, scroll)
	for i = 1, #handling do 
		local propName, infoName = unpack(handling[i])
		if not self.m_ProgressBars[propName] then 
			self.m_ProgressBars[propName] = {}
		end
		if not self.m_SliderBars[propName] then 
			self.m_SliderBars[propName] = {}
		end
		if not self.m_LabelDescription[propName] then 
			self.m_LabelDescription[propName] = {}
		end
		if not self.m_LabelValues[propName] then
			self.m_LabelValues[propName] = {}
		end
		GUIGridRectangle:new(0, self.m_Offset, 12, 2, tocolor(0, 0, 0, 150), scroll)
		self.m_Labels[infoName] = GUIGridLabel:new(1, self.m_Offset, 6, 1, infoName..":", scroll):setHeader("sub")
		GUIGridRectangle:new(7, self.m_Offset+0.1, 2, 1, tocolor(255, 255, 255, 200), scroll)
		table.insert(self.m_LabelValues[propName],  GUIGridLabel:new(7.1, self.m_Offset, 2, 1, "", scroll):setHeader("sub"))
		
		table.insert(self.m_ProgressBars[propName], GUIGridProgressBar:new(1, self.m_Offset+1, 10, 0.4, scroll))
		table.insert(self.m_SliderBars[propName], GUIGridSlider:new(1, self.m_Offset+1, 10, 0.4, scroll))
		if VEHICLE_TUNINGKIT_DESCRIPTION[propName] then
			local propRange, propDescription, propUnit = unpack(VEHICLE_TUNINGKIT_DESCRIPTION[propName])
			self.m_ProgressBars[propName][#self.m_ProgressBars[propName]]:setTooltip(propDescription, "top"):setForegroundColor(tocolor(50,200,255)):setBackgroundColor(tocolor(180,240,255))
			self.m_LabelDescription[propDescription] = { }
			if propName ~= "driveType" and not (propName:lower()):find("bias") and not propUnit then
				table.insert( self.m_LabelDescription[propName], GUIGridLabel:new(1, self.m_Offset+1, 16, 1, "0%", scroll))
				table.insert( self.m_LabelDescription[propName], GUIGridLabel:new(10, self.m_Offset+1, 2, 1, "100%", scroll))
				self.m_SliderBars[propName][#self.m_SliderBars[propName]]:setRange(0, 100):setEnabled(false)
			elseif propName == "driveType" then 
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(1, self.m_Offset+1, 16, 1, "RWD", scroll))
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(5, self.m_Offset+1, 2, 1, "AWD", scroll))
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(10, self.m_Offset+1, 2, 1, "FWD", scroll))
				self.m_SliderBars[propName][#self.m_SliderBars[propName]]:setRange(0, 100):setEnabled(false)
			elseif propUnit then 
				local min, max  = self:transformRange(propRange)
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(1, self.m_Offset+1, 2, 1, ("%i %s"):format(min, propUnit), scroll))
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(10 , self.m_Offset+1, 2, 1, ("%i %s"):format(max, propUnit), scroll))
				self.m_SliderBars[propName][#self.m_SliderBars[propName]]:setRange(0, 100):setEnabled(false)
			else
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(1, self.m_Offset+1, 2, 1, "Hinten", scroll))
				table.insert(self.m_LabelDescription[propName], GUIGridLabel:new(10 , self.m_Offset+1, 2, 1, "Vorne", scroll))
				self.m_SliderBars[propName][#self.m_SliderBars[propName]]:setRange(0, 100):setEnabled(false)
			end
		end
		self.m_Offset = self.m_Offset + 2 
	end
end


function VehiclePerformanceGUI:updateValues( vehicle )
	self.m_Vehicle = vehicle or self.m_Vehicle
	if self.m_Vehicle then 
		local handling = self.m_Vehicle:getHandling() 
		for prop, sliders in pairs( self.m_SliderBars ) do 
			for i, slider in ipairs(sliders) do
				local value = handling[prop]
				if tonumber(value) then
					local range, desc, unit = unpack(VEHICLE_TUNINGKIT_DESCRIPTION[prop])
					local min, max = self:transformRange(range)
					if not unit then
						value = ((math.abs(value)) / max)*100
						slider:setValue(math.clamp(0, value, 100))
					else 
						slider:setRange(range[1], range[2])
						slider:setValue(math.clamp(range[1], value, range[2]))
					end
				else 
					if prop == "driveType" then 
						local range, desc, unit = unpack(VEHICLE_TUNINGKIT_DESCRIPTION[prop])
						slider:setRange(range[1], range[2])
						slider:setValue(self.m_DriveTypeValues[value])
					end
				end
			end
		end
		for prop, labels in pairs( self.m_LabelValues ) do 
			for i, label in ipairs(labels) do
				local value = handling[prop]
				if tonumber(value) then
					local range, desc, unit = unpack(VEHICLE_TUNINGKIT_DESCRIPTION[prop])
					local min, max = self:transformRange(range)
					if not unit then
						value = ((math.abs(value)) / max)*100
						label:setText(math.floor(value).."%")
					else 
						label:setText(math.floor(value)..unit)
					end
					label:setColor(tocolor(0, 0, 0, 255))
				else 
					if prop == "driveType" then 
						label:setText(value)
						label:setColor(tocolor(0, 0, 0, 255))
					end
				end
			end
		end
	end
end

function VehiclePerformanceGUI:transformRange(range)
	return math.abs(range[1]), math.abs(range[1])+range[2]
end

function VehiclePerformanceGUI:destructor()
	GUIForm.destructor(self)
end