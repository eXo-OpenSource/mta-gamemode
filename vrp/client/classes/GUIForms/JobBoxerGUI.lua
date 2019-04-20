-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JobBoxerGUI.lua
-- *  PURPOSE:     Boxer job gui class
-- *
-- ****************************************************************************
JobBoxerGUI = inherit(GUIForm)
inherit(Singleton, JobBoxerGUI)

function JobBoxerGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Gewichtsklassen", true, true, self)
    self.m_GridList = GUIGridGridList:new(1, 1, 6, 8, self.m_Window)
    self.m_GridList:addColumn("", 0.95)
    self.m_GridList:addItemNoClick(_"Verfügbare Kämpfe")
    for i = 1, #JobBoxerFights do
        local item = self.m_GridList:addItem(("  %s"):format(JobBoxerFights[i][1]))
        item.onLeftClick = function()
            self.m_Headline:setText(_"Informationen")
            self.m_Label:setText(("Gewichtsklasse %s\n\nLeben: %s%%\nMin. Level: %s\n\nDein Level: %s"):format(JobBoxerFights[i][1], JobBoxerFights[i][2], JobBoxerFights[i][3], localPlayer:getPrivateSync("Stat_BoxerLevel")))
            self.m_Type = i
        end
    end

    self.m_Headline = GUIGridLabel:new(7, 1, 5, 1, "", self.m_Window):setHeader()
    self.m_Label = GUIGridLabel:new(7, 3, 5, 3, "", self.m_Window)
    self.m_Button = GUIGridButton:new(7, 8, 5, 1, _"Starten", self.m_Window)
    self.m_Button.onLeftClick = bind(self.startButtonClick, self)
end

function JobBoxerGUI:startButtonClick()
    if self.m_Type then
        JobBoxer:getSingleton():startJob(self.m_Type)
        self:close()
        self.m_Window:close()
    end
end
