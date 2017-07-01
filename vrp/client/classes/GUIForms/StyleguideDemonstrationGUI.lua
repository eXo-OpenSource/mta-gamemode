-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StyleguideDemonstrationGUI.lua
-- *  PURPOSE:     overview of world items of a specified owner
-- *
-- ****************************************************************************


StyleguideDemonstrationGUI = inherit(GUIForm)
inherit(Singleton, StyleguideDemonstrationGUI)


function StyleguideDemonstrationGUI:constructor()
	--main
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 15)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"StyleguideDemonstrationGUI", true, true, self)

    GUILabel:new(grid("x"), grid("y"), grid("d", 5), grid("d"), _"Zwischenüberschrift", self) 
    GUILabel:new(grid("x"), grid("y", 2), grid("d", 5), grid("d"), _"Infotext / Label", self):setFont(VRPFont(25)):setAlignY("center")

    VRPButton:new(grid("x"), grid("y", 3), grid("d", 3), grid("d"), "1331", true, self)

    GUILabel:new(grid("x", 11), grid("y"), grid("d", 9), grid("d"), _"Eine tolle Liste", self) 
    GUIGridList:new(grid("x", 11), grid("y", 2), grid("d", 9), grid("d", 10), self)
		:addColumn(_"Name", 0.4)
		:addColumn(_"Position", 0.6)
    self.m_ListRefreshButton = GUIButton:new(grid("x", 19), grid("y", 2), grid("d"), grid("d"), " "..FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1)
    self.m_ListRefreshButton:setBackgroundColor(Color.LightBlue)
    

    VRPButton:new(grid("x", 7), grid("y", 2), grid("d", 4), grid("d"), _"Hinzufügen", true, self):setBarColor(Color.Red)
    VRPButton:new(grid("x", 7), grid("y", 3), grid("d", 4), grid("d"), _"Entfernen", true, self):setBarColor(Color.Green)
    VRPButton:new(grid("x", 7), grid("y", 4), grid("d", 4), grid("d"), _"Nach oben", true, self)
    VRPButton:new(grid("x", 7), grid("y", 5), grid("d", 4), grid("d"), _"Nach unten",  true, self)
    GUILabel:new(grid("x", 7), grid("y", 6), grid("d", 4), grid("d", 2), _"Mehrzeiliger\nInfotext", self):setFont(VRPFont(25)):setAlignY("center")


    self.m_PrimaryBtn = GUIButton:new(grid("x", 16), grid("y", 14), grid("d", 4), grid("d"), "Übernehmen", self)
        self.m_PrimaryBtn:setFont(VRPFont(30)):setFontSize(1)
        self.m_PrimaryBtn:setBackgroundColor(Color.Green)

end

function StyleguideDemonstrationGUI:destructor()
	GUIForm.destructor(self)
end

addCommandHandler("styleguide", function(cmd)
	StyleguideDemonstrationGUI:getSingleton()
end)