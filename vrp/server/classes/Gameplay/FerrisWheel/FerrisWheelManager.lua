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
    
    FerrisWheelManager.Map[1] = FerrisWheel:new(Vector3(1479.35, -1665.9, 26.5), 0)
    self:registerUpdate(FerrisWheelManager.Map[1])
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

function FerrisWheelManager:unregisterUpdate(wheel)
    if FerrisWheelManager.UpdateMap[wheel] and isTimer(FerrisWheelManager.UpdateMap[wheel]) then
        killTimer(FerrisWheelManager.UpdateMap[wheel])
        FerrisWheelManager.UpdateMap[wheel] = nil
    end
end
