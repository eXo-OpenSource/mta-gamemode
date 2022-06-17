-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HouseGarage.lua
-- *  PURPOSE:     Serverside house garage class
-- *
-- ****************************************************************************
HouseGarage = inherit(Object)

HouseGarage.Map = {}
HouseGarage.Garage = {
    [4] = Vector3(1797.62, -2146.73, 13.55),
    [5] = Vector3(1699.06, -2089.99, 13.55),
    [13] = Vector3(322.60, -1769.86, 4.72),
    [14] = Vector3(1353.23, -625.68, 109.13),
    [42] = Vector3(-360.72, 1193.05, 19.74),
    [48] = Vector3(2231.22, 167.27, 27.48),
    [49] = Vector3(785.95, -494.23, 17.34),
}

function HouseGarage:constructor(houseId, garageId)
    self.m_HouseId = houseId
    self.m_GarageId = garageId
    self.m_LastInteraction = 0
end

function HouseGarage:toggleGarage()
    if timestampCoolDown(self.m_LastInteraction, 3) then
        setGarageOpen(self.m_GarageId, not isGarageOpen(self.m_GarageId))
        self.m_LastInteraction = getRealTime().timestamp
    end
end