-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/BombArea.lua
-- *  PURPOSE:     Bomb area class
-- *
-- ****************************************************************************
BombArea = inherit(Object)
BombArea.Map = {}
local DEFAULT_TIMEOUT = 60*1000

function BombArea:constructor(position, placeCallback, explodeCallback, timeout)
    self.m_Position = position
    self.m_PlaceCallback = placeCallback
    self.m_ExplodeCallback = explodeCallback
    self.m_Timeout = timeout

    BombArea.Map[#BombArea.Map + 1] = self
end

function BombArea:destructor()
    if self.m_Timer and isTimer(self.m_Timer) then
        killTimer(self.m_Timer)
    end
end

function BombArea:explode()
    createExplosion(self.m_Position, 2)

    if self.m_ExplodeCallback then
        self.m_ExplodeCallback(self)
    end
end

function BombArea:fire(player)
    -- Do not start the time if the place callback does not want to fire it
    if self.m_PlaceCallback and self.m_PlaceCallback(self, player) == false then
        return
    end

    self.m_Timer = setTimer(bind(BombArea.explode, self), self.m_Timeout, 1)
end

function BombArea.findAt(targetPosition)
    for k, area in pairs(BombArea.Map) do
        if (targetPosition - area.m_Position).length < 10 then
            return area
        end
    end

    return false
end
