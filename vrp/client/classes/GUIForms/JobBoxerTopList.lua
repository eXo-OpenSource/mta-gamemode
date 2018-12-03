-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GUIForms/JobBoxerTopList.lua
-- *  PURPOSE:     Boxer job toplist gui class
-- *
-- ****************************************************************************

JobBoxerTopList = inherit(GUIForm)

function JobBoxerTopList:constructor(table, playertable)
    local width, height = 500, 420
    GUIForm.constructor(self, screenWidth/2-(width/2), screenHeight/2-(height/2), width, height)

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Top 10 Boxer", true, true, self)

    self.m_GridList = GUIGridList:new(10, 40, self.m_Width-20, self.m_Height-50, self.m_Window)
    self.m_GridList:addColumn(_"Platz", 0.25)
    self.m_GridList:addColumn(_"Name", 0.5)
    self.m_GridList:addColumn(_"Boxerlevel", 0.25)
    for i = 1, #table do
        self.m_GridList:addItem(("#%s"):format(i), ("%s"):format(table[i][1]), ("%s"):format(table[i][2]))
    end
    self.m_GridList:addItem(("#%s"):format(playertable[1]), ("%s"):format(playertable[2]), ("%s"):format(playertable[3])):setColumnColor(1, Color.LightBlue):setColumnColor(2, Color.LightBlue):setColumnColor(3, Color.LightBlue)
end