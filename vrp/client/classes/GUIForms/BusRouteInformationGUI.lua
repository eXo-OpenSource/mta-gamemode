-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BusRouteInformationGUI.lua
-- *  PURPOSE:     Special progressbar which supports positive as well as negative values
-- *
-- ****************************************************************************


BusRouteInformationGUI = inherit(GUIForm)
inherit(Singleton, BusRouteInformationGUI)

function BusRouteInformationGUI:constructor(element)
	--main
    --[[if not element then return self:close() end -- close if there is no element bound
    if not element:getData("EPT_bus_station") then -- close if element has no route
        ErrorBox:new(_"An dieser Bushaltestelle halten leider keine Busse")
        nextframe(function()
            self:close()
        end)
        return
    end]]

    local header = "Busfahrplan"

    if element:getType() == "vehicle" and element:getData("EPT_bus_duty") then
        self.m_CurrentBus = element
        self.m_Line = element:getData("EPT_bus_duty")
        self.m_Lines = {self.m_Line}
        header = header .. " Linie "..self.m_Line
    elseif element:getType() == "object" and element:getData("EPT_bus_station") then
        self.m_Station  = element
        self.m_StationName  = element:getData("EPT_bus_station")
        self.m_Lines  = element:getData("EPT_bus_station_lines")
        self.m_Line = tonumber(self.m_Lines[1])
    end

    self.m_Width = 350
	self.m_Height = 451
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)


	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _(header), true, true, self)
    local baseHeight = 31 -- header  + line
    if #self.m_Lines > 1 then
        self.m_Line1Btn = VRPButton:new(5, baseHeight + 5, self.m_Width/2-7.5, 30, "Linie 1", true, self)
            :setBarColor(tocolor(unpack(EPTBusData.lineData.lineDisplayData[1].color)))
        self.m_Line1Btn.onLeftClick = function()
            self.m_BusRoute:setLine(1)
        end
        self.m_Line2Btn = VRPButton:new(self.m_Width/2 + 2.5, baseHeight + 5, self.m_Width/2-7.5, 30, "Linie 2", true, self)
            :setBarColor(tocolor(unpack(EPTBusData.lineData.lineDisplayData[2].color)))
        self.m_Line2Btn.onLeftClick = function()
            self.m_BusRoute:setLine(2)
        end
        baseHeight = baseHeight + 40
    end

    if self.m_Line then
        self.m_BusRoute = BusRoutePlan:new(0, baseHeight, self.m_Width, self.m_Height - baseHeight, baseHeight, self)
        self.m_BusRoute:setLine(self.m_Line, self.m_StationName)
        self.m_UpdatePlanTimer = setTimer(function()
            self.m_BusRoute:updateBusPositions()
        end, 1000, 0)
    end    
end

function BusRouteInformationGUI:destructor()
    if self.m_UpdatePlanTimer and isTimer(self.m_UpdatePlanTimer) then
        killTimer(self.m_UpdatePlanTimer)
    end
    GUIForm.destructor(self)
end