-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/DrugFactory.lua
-- *  PURPOSE:     Drug Factory client class
-- *
-- ****************************************************************************

DrugFactory = inherit(Singleton)

function DrugFactory:constructor()
    addRemoteEvents{"onHeroinFactoryEnter", "onHeroinFactoryLeave", "onHeroinFactoryExplode", "onHeroinFactoryStartTicking", "onHeroinFactoryStartScene"}
    addEventHandler("onHeroinFactoryEnter", root, bind(self.onHeroinFactoryEnter, self))
    addEventHandler("onHeroinFactoryLeave", root, bind(self.onHeroinFactoryLeave, self))
    addEventHandler("onHeroinFactoryExplode", root, bind(self.onHeroinFactoryExplode, self))
    addEventHandler("onHeroinFactoryStartTicking", root, bind(self.onHeroinFactoryStartTicking, self))
    addEventHandler("onHeroinFactoryStartScene", root, bind(self.onHeroinFactoryStartScene, self))

    self.m_WeaponFireBind = bind(self.onWeaponFire, self)
end

function DrugFactory:onWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ)
    if source == localPlayer then
        if getTickCount() - self.m_LastHit > 20000 then
            if getDistanceBetweenPoints3D(hitX, hitY, hitZ, 2678.7858886719, -1490.3532714844, 2908.3049316406) <= 0.025 then
                self.m_LastHit = getTickCount()
                triggerServerEvent("onFactoryEasterEggStart", localPlayer)
            end
        end
    end
end

function DrugFactory:onHeroinFactoryEnter()
    addEventHandler("onClientPlayerWeaponFire", root, self.m_WeaponFireBind)
    self.m_LastHit = 0
end

function DrugFactory:onHeroinFactoryLeave()
    removeEventHandler("onClientPlayerWeaponFire", root, self.m_WeaponFireBind)
end

function DrugFactory:onHeroinFactoryExplode()
    createExplosion(2653.83, -1465.32, 2904, 12, false, 1.0, false)
    createExplosion(2650.40, -1465.33, 2904, 12, false, 1.0, false)
    createExplosion(2653.83, -1465.32, 2905.85, 12, false, 1.0, false)
    createExplosion(2650.40, -1465.33, 2905.85, 12, false, 1.0, false)
end

function DrugFactory:onHeroinFactoryStartTicking()
    playSoundFrontEnd(44)
    setTimer(playSoundFrontEnd, 1000, 6, 44)
    setTimer(playSoundFrontEnd, 7000, 1, 45)
end

function DrugFactory:onHeroinFactoryStartScene()
    self.m_ScenePeds = {
        createPed(162, 2652.25, -1477.59, 2904.41),
        createPed(228, 2652.65, -1478.17, 2904.41),

        createPed(173, 2652.17, -1473.54, 2904.41, 180),

        createPed(115, 2654.17, -1472.59, 2904.41, 180),
        createPed(294, 2653.17, -1472.59, 2904.41, 180),
        createPed(260, 2652.17, -1472.59, 2904.41, 180),
        createPed(181, 2651.17, -1472.59, 2904.41, 180),
        createPed(175, 2650.17, -1472.59, 2904.41, 180)
    }
    for key, ped in ipairs(self.m_ScenePeds) do
        ped:setDimension(3)
        ped:setInterior(3)
        ped:setAlpha(150)
    end
    localPlayer:setPosition(2661.23, -1470.43, 2904.41)
    localPlayer:setFrozen(true)
    fadeCamera(true)
    setCameraMatrix(2655.025390625, -1469.1245117188, 2908.8154296875, 2615.8413085938, -1542.6309814453, 2853.4855957031)
    setTimer(bind(self.startSecondScene, self), 1000, 1)
end

function DrugFactory:startSecondScene()
    setPedAimTarget(self.m_ScenePeds[2], 2652.25, -1477.59, 2904.41)
    setPedAimTarget(self.m_ScenePeds[3], 2652.25, -1477.59, 2904.6)
    givePedWeapon(self.m_ScenePeds[2], 4, 1, true)
    givePedWeapon(self.m_ScenePeds[3], 22, 5, true)
    setTimer(function() self.m_ScenePeds[2]:setControlState("fire", true) end, 500, 1)
    setTimer(function() self.m_ScenePeds[3]:setControlState("aim_weapon", true) end, 1000, 1)
    setTimer(function() self.m_ScenePeds[3]:setControlState("fire", true) end, 1200, 1)
    setTimer(function() setGameSpeed(0.35) self.m_ScenePeds[3]:setControlState("fire", false) self.m_ScenePeds[1]:kill() end, 1325, 1)
    setTimer(function() fadeCamera(false, 2.0) end, 3500, 1)
    setTimer(bind(self.endScene, self), 10500, 1)
end

function DrugFactory:endScene()
    for key, ped in ipairs(self.m_ScenePeds) do 
        ped:destroy()
    end
    setGameSpeed(1)
    localPlayer:setPosition(2652.11, -1464.37, 2904.41)
    localPlayer:setFrozen(false)
    setCameraTarget(localPlayer)
    fadeCamera(true)
    triggerServerEvent("giveFactoryEasterEggAchievement", localPlayer)
end