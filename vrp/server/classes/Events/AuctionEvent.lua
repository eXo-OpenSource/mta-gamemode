-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Events/AuctionEvent.lua
-- * PURPOSE: helper for admin auctions
-- *
-- ****************************************************************************

AuctionEvent = inherit(Singleton)

function AuctionEvent:constructor()
    self.m_Blip = Blip:new("Bank.png", 2750.79, -1825.51, root, 1500, BLIP_COLOR_CONSTANTS.Green)
    self.m_Blip:setDisplayText("Adminversteigerung")
    self.m_Open = false
end

function AuctionEvent:destructor()
    self.m_Blip:delete() 
    self:setOpen(false)
end

function AuctionEvent:setOpen(state)
    if state and not self.m_Teleports then
        self.m_Teleports = {
            InteriorEnterExit:new(Vector3(2781.73, -1811.59, 11.84), Vector3(1652.79, -1290.35, 23235.87), 90, 225.30, 1),
            InteriorEnterExit:new(Vector3(2727.06, -1826.95, 11.84), Vector3(1652.47, -1383.60, 23235.87), 90, 164.06, 1),
        }
    elseif not state and self.m_Teleports then
        for i, v in pairs(self.m_Teleports) do
            v:delete()
        end
        self.m_Teleports = nil
    end
end