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
    self.m_BusGUIElements = {}
    self.m_BusStationNames = {}
    self.m_UpdatePlanTimer = setTimer(function()
		self:updateBusPositions()
	end, 1000, 0)
end

function BusRoutePlan:setLine(line, highlightStationName)
    self.m_Line = line
    self.m_HighlightStationName = highlightStationName
    if EPTBusData.lineData then
        self.m_Color = tocolor(unpack(EPTBusData.lineData.lineDisplayData[line].color))
       
        self:resize(self.m_Width, (#EPTBusData.lineData.line[line] + 1)*30)
        self:updateList(self.m_Color)
    end
end

function BusRoutePlan:setBackgroundDisabled(state)
    self.m_BGDisabled = state
end

function BusRoutePlan:setCompactView(state)
    self.m_Compact = state
end

function BusRoutePlan:updateList(color)
    self:clear()
    self.m_BusStationNames = {}
    for i,v in pairs(self.m_BusGUIElements) do
        delete(v)
    end

    if not self.m_BGDisabled then GUIRectangle:new(0, 0, self.m_Width, self.m_DocumentHeight, tocolor(0, 0, 0, 150), self) end --bg
    local header = self.m_Compact and EPTBusData.lineData.lineDisplayData[self.m_Line].displayName or "Linie "..self.m_Line.." ("..(EPTBusData.lineData.lineDisplayData[self.m_Line].displayName)..")"
    GUILabel:new(5, 0, self.m_Width-10, 30, _(header), self)
    GUIRectangle:new(0, 28, self.m_Width, 2, color, self) --underline

    for i, v in ipairs(EPTBusData.lineData.line[self.m_Line]) do -- draw Line
        GUIImage:new(self.m_Compact and 5 or 25, 30*i + 7.5, 15, 15, "files/images/GUI/FullCircle.png", self):setColor(color) --dot
        GUILabel:new(self.m_Compact and 30 or 65, 30*i, self.m_Width-40, 30, v.name, self):setColor(v.name == self.m_HighlightStationName and color or Color.White) --station name

        self.m_BusStationNames[v.name] = {30*i + 7.5, normaliseVector(v.position)}
    end
    GUIRectangle:new(self.m_Compact and 10 or 30, 40, 5, self.m_DocumentHeight-60, color, self) --line
end

function BusRoutePlan:updateBusPositions()
    for i,v in pairs(self.m_BusGUIElements) do
        delete(v)
    end
    local _, baseY = self:getScrollPosition()

    for vehicle, line in pairs(PublicTransport:getSingleton():getActiveBusVehicles()) do 
        if self.m_Line == line and vehicle.controller then
            local name1, name2 = vehicle:getData("EPT:Bus_LastStopName"), vehicle:getData("EPT:Bus_NextStopName")
            if self.m_BusStationNames[name1] and self.m_BusStationNames[name2] then
                local distToLast = getDistanceBetweenPoints3D(self.m_BusStationNames[name1][2], vehicle.position)
                local distToNext = getDistanceBetweenPoints3D(self.m_BusStationNames[name2][2], vehicle.position)
                local prog = distToLast / (distToLast + distToNext)
                local diff = self.m_BusStationNames[name1][1] - self.m_BusStationNames[name2][1]
                self.m_BusGUIElements[vehicle] = GUIImage:new(self.m_Compact and 0 or 20, baseY - 5 + self.m_BusStationNames[name1][1] - diff * prog, 25, 25, "files/images/Company/EPT/Bus.png", self):setColor(Color.White) --dot
            end
        end
    end
end

function BusRoutePlan:destructor()
    if isTimer(self.m_UpdatePlanTimer) then
        killTimer(self.m_UpdatePlanTimer)
    end
    GUIScrollableArea.destructor(self)
end


--util to store route data even if the ui itself got closed
addRemoteEvents{"recieveEPTBusData"}

EPTBusData = {}
addEventHandler("recieveEPTBusData", resourceRoot, function(lineData, activeBusVehicles)
    EPTBusData.lineData = lineData
    PublicTransport:getSingleton():setActiveBusVehicles(activeBusVehicles)
end)



