-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PricePoolPriceGUI.lua
-- *  PURPOSE:     PricePool Raffle GUI class
-- *
-- ****************************************************************************

PricePoolPriceGUI = inherit(GUIForm)
inherit(Singleton, PricePoolPriceGUI)

function PricePoolPriceGUI:constructor(pricelist)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
    self.m_Height = grid("y", 12)
    self.m_OffsetWidth = grid("x", 16)

    GUIForm.constructor(self, (screenWidth/2-self.m_OffsetWidth/2) + (self.m_Width*2) + 35, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Preisliste", true, true, self)
	
    self.m_GridList = GUIGridGridList:new(1, 1, 7, 11, self.m_Window)
    self.m_GridList:addColumn(_"Preise", 1.0)

    for key, price in pairs(pricelist) do
        local priceType = price[1]
        local priceIndexOrAmount = price[2]
        local winner = price[3]
        local text = ""

        if priceType == "money" then
            text = ("1x %d$"):format(priceIndexOrAmount)
        elseif priceType == "points" then
            text = ("1x %d Punkte"):format(priceIndexOrAmount)
        elseif priceType == "vehicle" then
            text = ("1x %s"):format(VehicleCategory:getSingleton():getModelName(priceIndexOrAmount))
        else
            text = ("%sx %s"):format(priceIndexOrAmount, priceType)
        end

        if winner then
            text = ("%s - Gewinner: %s"):format(text, winner)
        end

        self.m_GridList:addItem(text)
    end
end

function PricePoolPriceGUI:destructor()
    GUIForm.destructor(self)
end