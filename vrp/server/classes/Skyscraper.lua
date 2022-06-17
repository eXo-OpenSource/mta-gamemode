-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Skyscraper.lua
-- *  PURPOSE:     Serverside skyscraper class
-- *
-- ****************************************************************************
Skyscraper = inherit(Object)

function Skyscraper:constructor(id, position, houses)
    self.m_Id = id
    self.m_Position = position
    --self.m_GaragePosiion = garagePosition
    self.m_Houses = {}

    if houses then 
        for i, v in pairs(houses) do
            table.insert(self.m_Houses, v["Id"])
        end
    end

    self:updatePickup()
    --self:createGarage()
end

function Skyscraper:updatePickup()
    if self.m_Pickup then
        for i, v in pairs(self.m_Houses) do
            if HouseManager:getSingleton().m_Houses[v].m_Owner == false or HouseManager:getSingleton().m_Houses[v].m_Owner == 0 then
                setPickupType(self.m_Pickup, 3, 1273)
                break
            else
                setPickupType(self.m_Pickup, 3, 1272)
            end
        end  
    else
        self.m_Pickup = createPickup(self.m_Position, 3, 1273, 10, math.huge)
        self:updatePickup()
        addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
    end
end

function Skyscraper:onPickupHit(hitElement)
    local temp = {}
    for i, v in pairs(self.m_Houses) do
        table.insert(temp, HouseManager:getSingleton().m_Houses[v].m_Owner)
    end
    if hitElement:getType() == "player" and (hitElement:getDimension() == source:getDimension()) then
		if hitElement.vehicle then return end
		hitElement.visitingSkyscraper = self.m_Id
		hitElement.lastSkyscraperPickup = source
		hitElement:triggerEvent("Skyscraper:showGUI", self.m_Houses, temp)
	end
end

function Skyscraper:save()
    local x, y, z = self.m_Pickup:getPosition()
    return sql:queryExec("UPDATE ??_skyscrapers SET x = ?, y = ?, z = ?", sql:getPrefix(), x, y, z)
end

function Skyscraper:getPosition()
    return self.m_Position
end

function Skyscraper:setPosition(pos)
    if pos and pos.x then
        self.m_Position = pos
        self.m_Pickup:destory()
        self.m_Pickup = nil
        self:updatePickup()
    end
end