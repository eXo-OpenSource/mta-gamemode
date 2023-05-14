-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Skyscraper.lua
-- *  PURPOSE:     Serverside skyscraper class
-- *
-- ****************************************************************************
Skyscraper = inherit(Object)

function Skyscraper:constructor(id, position, houses, houseOrder)
    self.m_Id = id
    self.m_Position = position
    --self.m_GaragePosiion = garagePosition
    self.m_Houses = {}

    if houses then 
        for i, v in pairs(houses) do
            table.insert(self.m_Houses, v["Id"])
        end
    end

    if houseOrder then
        self.m_HouseOrder = fromJSON(houseOrder)
    else
        self.m_HouseOrder = table.copy(self.m_Houses)
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
    if hitElement:getType() == "player" and (hitElement:getDimension() == source:getDimension()) then
		if hitElement.vehicle then return end
		hitElement.visitingSkyscraper = self.m_Id
		hitElement.lastSkyscraperPickup = source
        hitElement:triggerEvent("onTryEnterExit", source, "Hochhaus")
	end
end

function Skyscraper:showGUI(player)
    local temp = {}

    for i, v in pairs(self.m_HouseOrder) do
        table.insert(temp, HouseManager:getSingleton().m_Houses[v].m_Owner)
    end
    player:triggerEvent("Skyscraper:showGUI", self.m_Id, self.m_HouseOrder, temp, player.lastSkyscraperPickup)
end

function Skyscraper:save()
    local pos = self.m_Pickup:getPosition()
    sql:queryExec("UPDATE ??_skyscrapers SET PosX = ?, PosY = ?, PosZ = ?, HouseOrder = ? WHERE Id = ?", sql:getPrefix(), pos.x, pos.y, pos.z, toJSON(self.m_HouseOrder), self.m_Id)
end

function Skyscraper:getPosition()
    return self.m_Position
end

function Skyscraper:setPosition(pos)
    if pos and pos.x then
        self.m_Position = pos
        self.m_Pickup:destroy()
        self.m_Pickup = nil
        self:updatePickup()
    end
end