-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/EasterEggs.lua
-- *  PURPOSE:     Halloween Easter Eggs class
-- *
-- ****************************************************************************

HalloweenEasterEggs = inherit(Singleton)
addRemoteEvents{"Halloween:createGhostShip", "Halloween:createZombie", "Halloween:createMotherGhost", "Halloween:createMountChilliadGhost", "Halloween:sendRewardState"}

function HalloweenEasterEggs:constructor()
    addEventHandler("Halloween:createGhostShip", root, bind(self.createGhostShip, self))

    self.m_ZombieFood = createObject(2907, -1950.8659667969, 643.94128417969, 45.722534179688, 0, 0, 280)

    addEventHandler("Halloween:createZombie", root, bind(self.createZombie, self))
    addEventHandler("Halloween:createMotherGhost", root, bind(self.createMotherGhost, self))
    addEventHandler("Halloween:createMountChilliadGhost", root, bind(self.createMountChilliadGhost, self))
    
    triggerServerEvent("Halloween:requestEasterEggs", localPlayer)
end

function HalloweenEasterEggs:destructor()
    if self.m_ShipGhost then
        delete(self.m_ShipGhost)
    end
end

-- Ghost Ships --
function HalloweenEasterEggs:createGhostShip(ship)
    self.m_ShipGhost = HalloweenGhost:new(ship:getPosition() + Vector3(0, 10, -9.503), 180, 0, 0, false, bind(self.onShipGhostKill, self))
    self.m_ShipGhost:setModel(78)
    self.m_ShipGhost:setAlpha(150)
end

function HalloweenEasterEggs:onShipGhostKill()
    local position = self.m_ShipGhost.m_Ped:getPosition()
    laugh = playSound3D("files/audio/evil_laugh.mp3", position)
    laugh:setVolume(5)
    laugh:setMaxDistance(200)
    nextframe(
        function()
            laughHall = playSound3D("files/audio/evil_laugh.mp3", position)
            laughHall:setEffectEnabled("i3dl2reverb", true)
            laughHall:setVolume(4)
            laughHall:setMaxDistance(300)
        end
    )
    triggerServerEvent("Halloween:giveEasterEggReward", localPlayer, 1)
end

-- Zombie --

function HalloweenEasterEggs:createZombie()
    if not isElement(self.m_Zombie) then
        self.m_Zombie = createPed(310, -1950.710, 643.164, 46.563, 6.924)
        self.m_Zombie.m_isClientSided = true
        self.m_Zombie:setFrozen(true)
        self.m_ZombieTimer = setTimer(
            function()
                if not self.m_ZombieHit then
                    if not self.m_Zombie:getAnimation() then
                        self.m_Zombie:setAnimation("STRIP", "STR_B2C")
                    end
                    self.m_Zombie:setAnimationSpeed("STR_B2C", 0)
                    self.m_Zombie:setAnimationProgress("STR_B2C", 0.69)
                end
            end
        , 500, 0)
        addEventHandler("onClientPedDamage", self.m_Zombie, bind(self.onClientPedDamage, self))
        addEventHandler("onClientPedWasted", self.m_Zombie, bind(self.onClientPedWasted, self))
    end
end

function HalloweenEasterEggs:onClientPedWasted(killer)
    if killer == localPlayer then
        triggerServerEvent("Halloween:giveEasterEggReward", localPlayer, 2)
        killTimer(self.m_ZombieTimer)
    end
end

function HalloweenEasterEggs:onClientPedDamage(attacker)
    if attacker == localPlayer then
        self.m_ZombieHit = true
    end
end

-- Beverly Johnsons Ghost --

function HalloweenEasterEggs:createMotherGhost()
    if not self.m_MotherGhost or not isElement(self.m_MotherGhost.m_Ped) then
        self.m_MotherGhost = HalloweenGhost:new(Vector3(-2567.344, -26.716, 12.672), 90, 0, 0, false)
        self.m_MotherGhost:setModel(9)
        self.m_MotherGhost:setAlpha(150)
        setElementData(self.m_MotherGhost.m_Ped, "clickable", true)
        self.m_MotherGhost.m_Ped:setData("onClickEvent", 
            function()
                self.m_MotherGhost:kill()
                DialogGUI:new(false, 
                    "Auf dem Grabstein steht Beverly Johnson..."
                )
                triggerServerEvent("Halloween:giveEasterEggReward", localPlayer, 3)
            end
        )
    end
end

-- Mount Chilliad Ghost --

function HalloweenEasterEggs:createMountChilliadGhost()
    if not isElement(self.m_LullabyColShape) then
        self.m_MountChilliadGhostColShapes = {
            createColCuboid(-2812.632, -1525, 140.2, 1, 2, 2.5),
            createColCuboid(-2820.517, -1519.6, 140.2, 1, 2, 2.5)
        }
        self.m_MountChilliadGhost = HalloweenGhost:new(Vector3(-2818.383, -1529.442, 140.844), 180, 0, 0, false)
        self.m_MountChilliadGhost:setModel(254)
        self.m_MountChilliadGhost:setAlpha(150)
        for key, colshape in ipairs(self.m_MountChilliadGhostColShapes) do
            addEventHandler("onClientColShapeHit", colshape, bind(self.onCabinEnter, self))
        end

        self.m_LullabyColShape = createColSphere(-2818.383, -1529.442, 140.844, 300)
        addEventHandler("onClientColShapeHit", self.m_LullabyColShape, bind(self.onLullabyColShapeHit, self))
    end
end

function HalloweenEasterEggs:onCabinEnter(hitElement)
    if hitElement == localPlayer then
        self.m_MountChilliadGhost:kill()
        setTimer(
            function()
                if self.m_Lullaby:getVolume() == 0 then
                    self.m_Lullaby:destroy()
                    killTimer(sourceTimer)
                    triggerServerEvent("Halloween:giveEasterEggReward", localPlayer, 4)
                else
                    self.m_Lullaby:setVolume(self.m_Lullaby:getVolume()-0.5)
                end
                if isElement(self.m_LullabyHall) then
                    if self.m_LullabyHall:getVolume() > 0.5 then
                        self.m_LullabyHall:setVolume(self.m_LullabyHall:getVolume()-0.5)
                    else
                        self.m_LullabyHall:destroy()
                    end
                end
            end
        , 100, 0)
        for key, colshape in ipairs(self.m_MountChilliadGhostColShapes) do
            colshape:destroy()
        end
        self.m_LullabyColShape:destroy()
    end
end

function HalloweenEasterEggs:onLullabyColShapeHit(hitElement)
    if hitElement == localPlayer then
        self.m_Lullaby = playSound3D("files/audio/evil_lullaby.mp3", -2818.383, -1529.442, 140.844, true) 
        self.m_Lullaby:setVolume(5)
        self.m_Lullaby:setMaxDistance(250)
        nextframe(
            function() 
                self.m_LullabyHall = playSound3D("files/audio/evil_lullaby.mp3", -2818.383, -1529.442, 140.844, true)
                self.m_LullabyHall:setVolume(4)
                self.m_LullabyHall:setMaxDistance(300)
                self.m_LullabyHall:setEffectEnabled("echo", true)
                self.m_LullabyHall:setEffectEnabled("i3dl2reverb", true)
            end
        )
    end
end