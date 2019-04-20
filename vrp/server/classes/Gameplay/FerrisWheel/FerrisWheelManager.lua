-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

FerrisWheelManager = inherit(Singleton)
FerrisWheelManager.PauseInterval = 15000
FerrisWheelManager.UpdateInterval = 1000
FerrisWheelManager.DegreesPerSecond = 6
FerrisWheelManager.RotationPerRound = 138
FerrisWheelManager.GondAmount = 10
FerrisWheelManager.Map = {}
FerrisWheelManager.UpdateMap = {}

function FerrisWheelManager:constructor()
    self.m_BankAccountServer = BankServer.get("gameplay.ferris_wheel")
    self:addWheel(Vector3(391.100, -2028.580, 19.95), -90) --beach
end

function FerrisWheelManager:addWheel(position, rotation)
    local wheel = FerrisWheel:new(position, rotation)
    --self:registerUpdate(wheel)
    table.insert(FerrisWheelManager.Map, wheel)
end

function FerrisWheelManager:registerUpdate(wheel)
    if not FerrisWheelManager.UpdateMap[wheel] then
        wheel:update()
        FerrisWheelManager.UpdateMap[wheel] = setTimer(
            bind(FerrisWheel.update, wheel),
            FerrisWheelManager.UpdateInterval,
            0
        )

    end
end

function FerrisWheelManager:getBankAccount()
    return self.m_BankAccountServer
end

function FerrisWheelManager:unregisterUpdate(wheel)
    if FerrisWheelManager.UpdateMap[wheel] and isTimer(FerrisWheelManager.UpdateMap[wheel]) then
        killTimer(FerrisWheelManager.UpdateMap[wheel])
        FerrisWheelManager.UpdateMap[wheel] = nil
    end
end
