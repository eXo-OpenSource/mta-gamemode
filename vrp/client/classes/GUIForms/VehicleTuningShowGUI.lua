VehicleTuningShowGUI = inherit(GUIForm)
inherit(Singleton, VehicleTuningShowGUI)

function VehicleTuningShowGUI:constructor(tuning, specialTuning)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeugtunings", true, true, self)
	
	self.m_ListStandard = GUIGridGridList:new(1, 1, 7, 5, self.m_Window)
	self.m_ListStandard:addColumn("Tuningteile", 0.5)
    self.m_ListStandard:addColumn("", 0.5)
    for i,v in pairs(tuning) do
        self.m_ListStandard:addItem(tostring(i), getVehicleUpgradeNameFromID(v) or "")
    end
	self.m_ListSpecial = GUIGridGridList:new(1, 6, 7, 4, self.m_Window)
	self.m_ListSpecial:addColumn("Spezialtunings", 0.5)
    self.m_ListSpecial:addColumn("", 0.5)
    for i,v in pairs(specialTuning) do
        if i == "Neon" then 
            local item = self.m_ListSpecial:addItem(tostring(i), "████")
            item:setColumnColor(2, tocolor(unpack(v)))
        else
            self.m_ListSpecial:addItem(tostring(i), tostring(v))
        end
    end
end

function VehicleTuningShowGUI:destructor()
	GUIForm.destructor(self)
end
