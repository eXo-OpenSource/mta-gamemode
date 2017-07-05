-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/BusRoutePlan.lua
-- *  PURPOSE:     utility element to create a simple route view for bus routes
-- *
-- ****************************************************************************
BusRoutePlan = inherit(GUIScrollableArea)

function BusRoutePlan:constructor(x, y, w, h, scrollBarOffset, parent)
	GUIScrollableArea.constructor(self, x, y, w, h, 0, 0, true, false, parent, scrollBarOffset) --gets resized later on

end

function BusRoutePlan:setLine(line)
    self.m_Line = line
    if EPTBusData.lineData then
        self:resize(self.m_Width, (#EPTBusData.lineData.line[line] + 1)*30)
        self:updateList(tocolor(unpack(EPTBusData.lineData.lineDisplayData[line].color)))
    end
end

function BusRoutePlan:updateList(color)
    self:clear()

    GUIRectangle:new(0, 0, self.m_Width, self.m_DocumentHeight, tocolor(0, 0, 0, 150), self) --bg
    GUILabel:new(5, 0, self.m_Width-10, 30, "Linie "..self.m_Line.." ("..(EPTBusData.lineData.lineDisplayData[self.m_Line].displayName)..")", self)
    GUIRectangle:new(0, 28, self.m_Width, 2, color, self) --underline

    for i, v in ipairs(EPTBusData.lineData.line[self.m_Line]) do
        GUIImage:new(25, 30*i + 7.5, 15, 15, "files/images/GUI/FullCircle.png", self):setColor(color) --dot
        GUILabel:new(65, 30*i, self.m_Width-40, 30, v.name, self) --station name
    end

    GUIRectangle:new(30, 40, 5, self.m_DocumentHeight-60, color, self) --line

end





TestGUI = inherit(GUIForm)

function TestGUI:constructor(line)
	GUIForm.constructor(self, screenWidth*0.1, screenHeight*0.3, screenWidth/5, screenHeight*0.3)
    BusRoutePlan:new(5, 5, self.m_Width - 10, self.m_Height - 10, self):setLine(tonumber(line))
end

addCommandHandler("bus", function(cmd, line)

      TestGUI:new(line)

end)

--util to store route data even if the ui itself got closed
addRemoteEvents{"recieveEPTBusData"}

EPTBusData = {}
addEventHandler("recieveEPTBusData", resourceRoot, function(lineData)
    EPTBusData.lineData = lineData
end)



