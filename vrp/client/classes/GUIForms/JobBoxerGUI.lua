-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GUIForms/JobBoxerGUI.lua
-- *  PURPOSE:     Boxer job gui class
-- *
-- ****************************************************************************

JobBoxerGUI = inherit(GUIForm)

function JobBoxerGUI:constructor()
    local width, height = 500, 400
    GUIForm.constructor(self, screenWidth/2-(width/2), screenHeight/2-(height/2), width, height)

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kampf Liste", true, true, self)

    self.m_GridList = GUIGridList:new(10, 40, 200, self.m_Height-50, self.m_Window)
    self.m_GridList:addColumn("", 0.95)
    self.m_GridList:addItemNoClick(_"Verfügbare Kämpfe")
    for i = 1, #JobBoxerFights do
        local item = self.m_GridList:addItem(("  %s"):format(JobBoxerFights[i][1]))
        item.onLeftClick = function()
            self.m_Headline:setText(_"Informationen")
            self.m_Label:setText(("Gewichtsklasse %s\nLeben: %s"):format(JobBoxerFights[i][1], JobBoxerFights[i][2]))
            self.m_Type = i
        end
    end

    self.m_Headline = GUILabel:new(235, 40, self.m_Width-230, self.m_Height-10, "", self.m_Window)
    self.m_Headline:setFont(VRPFont(34))

    self.m_Label = GUILabel:new(235, 80, self.m_Width-230, self.m_Height-10, "", self.m_Window)
    self.m_Label:setFont(VRPFont(28))

    self.m_Button = VRPButton:new(240, 330, 230, 50, _"Starten", true, self.m_Window)
    self.m_Button.onLeftClick = bind(self.startButtonClick, self)
end

function JobBoxerGUI:startButtonClick()
    JobBoxer:getSingleton():startJob(self.m_Type)
    self:close()
end