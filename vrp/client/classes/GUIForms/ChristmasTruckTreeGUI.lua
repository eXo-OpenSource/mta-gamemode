-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ChristmasTruckTreeGUI.lua
-- *  PURPOSE:     ChristmasTruckTreeGUI class
-- *
-- ****************************************************************************
ChristmasTruckTreeGUI = inherit(GUIForm)
inherit(Singleton, ChristmasTruckTreeGUI)

function ChristmasTruckTreeGUI:constructor(rangeElement, data)
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)	
	self.m_Height = grid("y", 15)
    GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, rangeElement)

    self.m_Window = GUIWindow:new(0, 0,  self.m_Width, self.m_Height, _"Geschenke unterm Weihnachtsbaum", true, true, self)
    
    self.m_Grid = GUIGridGridList:new(1, 1, 9, 14, self.m_Window)
    self.m_Grid:addColumn(_"Geschenke", 0.4)
    self.m_Grid:addColumn(_"Ablaufdatum", 0.6)

    for index, expireStamp in pairs(data) do
        self.m_Grid:addItem(_("Geschenk Nr. %d", index), getOpticalTimestamp(expireStamp))
    end
end

addEvent("ChristmasTruckTreeGUI:open", true)
addEventHandler("ChristmasTruckTreeGUI:open", localPlayer, function(rangeElement, data)
    ChristmasTruckTreeGUI:new(rangeElement, data)
end)