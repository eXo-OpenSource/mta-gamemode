-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GUIForms/JobBoxerTopList.lua
-- *  PURPOSE:     Boxer job toplist gui class
-- *
-- ****************************************************************************

JobBoxerTopList = inherit(GUIForm)

function JobBoxerTopList:constructor(table, playertable)
    GUIWindow.updateGrid()			
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 11)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Top Liste", true, true, self)

    self.m_GridList = GUIGridGridList:new(1, 1, 11, 10, self.m_Window)
    self.m_GridList:addColumn(_"Platz", 0.25)
    self.m_GridList:addColumn(_"Name", 0.5)
    self.m_GridList:addColumn(_"Boxerlevel", 0.25)
    for i = 1, 10 do
        if table[i] then
            self.m_GridList:addItem(("#%s"):format(i), ("%s"):format(table[i][1]), ("%s"):format(table[i][2]))
        end
    end
    self.m_GridList:addItem(("#%s"):format(playertable[1]), ("%s"):format(playertable[2]), ("%s"):format(playertable[3])):setColumnColor(1, Color.LightBlue):setColumnColor(2, Color.LightBlue):setColumnColor(3, Color.LightBlue)
    ShortMessage:new(_("Achtung! Deine eigenen Statistiken werden nur alle 30 Minuten aktualisiert (sofern nicht in den Top-Ten)!"), _"Bestenliste" , {180, 130, 0})
end