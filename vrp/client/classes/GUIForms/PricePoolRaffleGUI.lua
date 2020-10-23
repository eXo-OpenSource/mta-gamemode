-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PricePoolRaffleGUI.lua
-- *  PURPOSE:     PricePool Raffle GUI class
-- *
-- ****************************************************************************

PricePoolRaffleGUI = inherit(GUIForm)
inherit(Singleton, PricePoolRaffleGUI)

PricePoolRaffleGUI.WinnerRoll = 15
PricePoolRaffleGUI.RollTime = 20000

function PricePoolRaffleGUI:constructor(players, winner, price)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
    self.m_Height = grid("y", 12)
    self.m_OffsetWidth = grid("x", 16)
    
    self.m_NameTable = players
    self.m_Winner = winner
    self.m_Price = price
    self.m_RenderBind = bind(self.renderRoll, self)

    GUIForm.constructor(self, (screenWidth/2-self.m_OffsetWidth/2) + (self.m_Width*2) + 35, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Auflösung", false, true, self)
    
    self.m_TopLabel = GUIGridLabel:new(2, 0, 5, 1, _("Verlosung: %s", self.m_Price), self.m_Window):setAlignX("center"):setHeader("sub")
	
	self.m_LeftLabel = GUIGridLabel:new(1, 6, 1, 1, ">", self.m_Window):setAlignX("center"):setHeader()
	self.m_RightLabel = GUIGridLabel:new(7, 6, 1, 1, "<", self.m_Window):setAlignX("center"):setHeader()
	
	self.m_Labels = {}
    for i = 1, 11 do
        local name = self.m_NameTable[i-5] or ""
		self.m_Labels[i] = GUIGridLabel:new(2, i, 5, 1, name, self.m_Window):setAlignX("center")
    end
    self.m_Labels[6]:setHeader()
end

function PricePoolRaffleGUI:destructor()
    GUIForm.destructor(self)
    if isEventHandlerAdded("onClientPreRender", root, self.m_RenderBind) then
        removeEventHandler("onClientPreRender", root, self.m_RenderBind)
    end
end

function PricePoolRaffleGUI:startRoll()
    self.m_RollTable = {}

    self.m_WinnerIndex = table.find(self.m_NameTable, self.m_Winner) + ((PricePoolRaffleGUI.WinnerRoll-1) * #self.m_NameTable)
    self.m_RollStartTime = getTickCount()
    self.m_RollEndTime = self.m_RollStartTime + PricePoolRaffleGUI.RollTime
    
    for i = 1, PricePoolRaffleGUI.WinnerRoll+1 do
        for key, name in pairs(self.m_NameTable) do
            self.m_RollTable[#self.m_RollTable+1] = name
        end
    end

    setTimer(function() setTimer(function() self:showWinner() end, 500, 6) end, PricePoolRaffleGUI.RollTime, 1)
    addEventHandler("onClientPreRender", root, self.m_RenderBind)
end

function PricePoolRaffleGUI:renderRoll()
    local now = getTickCount()
	local elapsedTime = now - self.m_RollStartTime
	local duration = self.m_RollEndTime - self.m_RollStartTime
	local progress = elapsedTime / duration

    local rollIndex = interpolateBetween(1, 0, 0, self.m_WinnerIndex, 0, 0, progress, "InOutQuad")

    local index = 1
    for i = -5, 5 do
        local name = self.m_RollTable[math.round(rollIndex)+i] or ""
        self.m_Labels[index]:setText(name)
        index = index + 1
    end
end

function PricePoolRaffleGUI:showWinner()
    local color

    if self.m_LeftLabel:getColor() == Color.White then
        color = Color.Green
        playSoundFrontEnd(101)
    else
        color = Color.White
    end

    self.m_LeftLabel:setColor(color)
    self.m_RightLabel:setColor(color)
    self.m_Labels[6]:setColor(color)
end