-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Easter/RabbitManager.lua
-- *  PURPOSE:     Rabbit manager class
-- *
-- ****************************************************************************

RabbitManager = inherit(Singleton)

RabbitManager.Animations = {
    {"ped", "WALK_player", "rabit", "rabit_walk"},
    {"ped", "run_player", "rabit", "rabit_run"},
    {"ped", "sprint_civi", "rabit", "rabit_sprint"},
    {"ped", "IDLE_stance", "rabit", "rabit_idle"},
    {"ped", "walk_start", "rabit", "walk_start"},
    --{"ped", "", "rabit", "rabit_damage"},
    --{"ped", "", "rabit", "rabit_die"}
}

RabbitManager.EasingFunctions = {
    "InQuad",
    "OutQuad",
    "InOutQuad",
    "OutInQuad"
}

RabbitManager.EggPositions = {
    {-0.06, 0.07, 0.5, 0.75},
    {0.125, 0.1, 0.45, 0.4},
    {-0.12, -0.11, 0.45, 0.4},
    {0.0325, -0.125, 0.45, 0.525},
    {0.08, 0, 0.45, 0.25},
    {0.175, -0.01, 0.45, 0.325},
    {0.1525, -0.1, 0.45, 0.225},
    {0.055, 0.175, 0.45, 0.2},
    {-0.185, -0.03, 0.45, 0.2},
    {-0.2, 0.03, 0.45, 0.15},
    {-0.059, -0.18, 0.45, 0.15},
    {0.005, 0.205, 0.45, 0.15}
}

function RabbitManager:constructor()
    self.m_IFP = engineLoadIFP("files/animations/rabbit.ifp", "rabit")
    self.m_Shader = dxCreateShader("files/shader/pedSize.fx", 0, 0, false, "ped")
    CustomModelManager:getSingleton():loadImportTXD("files/models/skins/rabbit.txd", 304)
    CustomModelManager:getSingleton():loadImportDFF("files/models/skins/rabbit.dff", 304)

    self.m_IdleRabbits = {}
    self.m_IdleStanceBind = bind(self.renderPedIdleStance, self)
    addEventHandler("onClientPreRender", root, self.m_IdleStanceBind)
end

function RabbitManager:setPedRabbit(ped)
    for index, animation in pairs(RabbitManager.Animations) do
        local InternalBlockName = animation[1]
        local InternalAnimName = animation[2]
        local CustomBlockName = animation[3]
        local CustomAnimName = animation[4]
        engineReplaceAnimation(ped, InternalBlockName, InternalAnimName, CustomBlockName, CustomAnimName)
    end
    dxSetShaderValue(self.m_Shader, "size", 0.5, 0.5, 0.5)
    dxSetShaderValue(self.m_Shader, "offset", 0, 0, 2)
    engineApplyShaderToWorldTexture(self.m_Shader, "*", ped)
end

function RabbitManager:setPedIdleStance(ped)
    ped:setFrozen(true)
    ped:setAnimation("rabit", "rabit_walk")
    ped:setAnimationSpeed("rabit_walk", 0)
    ped:setData("NPC:Immortal", true)

    self.m_IdleRabbits[ped] = {
        movingState = "forward", 
        startTime = getTickCount(), 
        endTime = getTickCount() + 3500, 
        progress = 0.400,
        interpolationProgress = 0,
        animationStartProgress = 0.400,
        animationEndProgress = 0.850,
        easingFunction = 3,
    }

    ped.blockObjects = {
        createObject(2987, ped.position+Vector3(0, 1.2, 0)),
        createObject(2987, ped.position+Vector3(0, -1.2, 0)),
        createObject(2987, ped.position+Vector3(1.2, 0, 0), Vector3(0, 0, 90)),
        createObject(2987, ped.position+Vector3(-1.2, 0, 0), Vector3(0, 0, 90)),
        createObject(2987, ped.position+Vector3(0, 0, 1.2), Vector3(90, 0, 0)),
        createObject(2987, ped.position+Vector3(0, 0, -1), Vector3(90, 0, 0))
    }
    for index, object in pairs(ped.blockObjects) do
        object:setScale(0)
        object:setBreakable(false)
    end
end

function RabbitManager:removePedIdleStance(ped)
    if self.m_IdleRabbits[ped] then
        ped:setAnimation()
        self.m_IdleRabbits[ped] = nil
        for index, object in pairs(ped.blockObjects) do
            object:destroy()
        end
    end
end

function RabbitManager:renderPedIdleStance()
    local x, y, z = getElementPosition(localPlayer)

    for rabbit, rabbitIdleInfo in pairs(self.m_IdleRabbits) do
        local rx, ry, rz = getElementPosition(rabbit)

        if getDistanceBetweenPoints3D(x, y, z, rx, ry, rz) < 100 then
            if not rabbit:getAnimation() then
                rabbit:setAnimation("rabit", "rabit_walk")
                rabbit:setAnimationSpeed("rabit_walk", 0)
            end

            if rabbitIdleInfo.interpolationProgress >= 1 then
                if rabbitIdleInfo.movingState == "forward" then
                    rabbitIdleInfo.movingState = "backwards"
                    rabbitIdleInfo.animationStartProgress = rabbitIdleInfo.progress
                    rabbitIdleInfo.animationEndProgress = 0.400
                else
                    rabbitIdleInfo.movingState = "forward"
                    rabbitIdleInfo.animationStartProgress = rabbitIdleInfo.progress
                    rabbitIdleInfo.animationEndProgress = 0.850
                end
                rabbitIdleInfo.startTime = getTickCount()
                rabbitIdleInfo.endTime = rabbitIdleInfo.startTime + 3500
                rabbitIdleInfo.easingFunction = math.random(1, #RabbitManager.EasingFunctions)
            end

            local now = getTickCount()
	        local elapsedTime = now - rabbitIdleInfo.startTime
	        local duration = rabbitIdleInfo.endTime - rabbitIdleInfo.startTime
            rabbitIdleInfo.interpolationProgress = elapsedTime / duration

            rabbitIdleInfo.progress = interpolateBetween(rabbitIdleInfo.animationStartProgress, 0, 0, rabbitIdleInfo.animationEndProgress, 0, 0, rabbitIdleInfo.interpolationProgress, RabbitManager.EasingFunctions[rabbitIdleInfo.easingFunction])
            rabbit:setAnimationProgress("rabit_walk", rabbitIdleInfo.progress)
        end
    end
end

function RabbitManager:addPedEggBasket(ped)
    ped.basket = createObject(742, ped.position)
    ped.basket:setCollisionsEnabled(false)
    ped.basket:setScale(0.4, 0.4, 0.6)
    exports.bone_attach:attachElementToBone(ped.basket, ped, 3, 0.080, -0.75, 0.1, 0, 43, -90)

    ped.eggs = {}
    for index, position in pairs(RabbitManager.EggPositions) do
        ped.eggs[index] = createObject(1933, ped.position)
        ped.eggs[index]:setCollisionsEnabled(false)
        ped.eggs[index]:attach(ped.basket, position[1], position[2], position[3])
        ped.eggs[index]:setScale(position[4])
    end
end

function RabbitManager:removePedEggBasket(ped)
    if isElement(ped.basket) then
        exports.bone_attach:detachElementFromBone(ped.basket)
        ped.basket:destroy()
    end
    if ped.eggs then
        for index, egg in pairs(ped.eggs) do
            egg:destroy()
        end
    end
end