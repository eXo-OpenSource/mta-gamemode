-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/DrugFactoryEasterEgg.lua
-- *  PURPOSE:     Drug Factory Easter Egg class
-- *
-- ****************************************************************************

DrugFactoryEasterEgg = inherit(Singleton)

addRemoteEvents{"onFactoryEasterEggStart", "giveFactoryEasterEggAchievement"}

function DrugFactoryEasterEgg:constructor()
    self:close()
    self.m_ColShape = createColCuboid(2607.14, -1578.52, 2879.4, 100, 150, 75)
    self.m_AchievementColShape = createColCuboid(2649.19, -1490.31, 2903.75, 7.35, 24.35, 10)
    addEventHandler("onColShapeHit", self.m_AchievementColShape, 
        function(hitElement)
            fadeCamera(hitElement, false)
        end
    )
    addEventHandler("onFactoryEasterEggStart", root, bind(self.onStart, self))
    addEventHandler("giveFactoryEasterEggAchievement", root, bind(self.giveAchievement, self))
    self.m_CloseBind = bind(self.onStop, self)
end

function DrugFactoryEasterEgg:close()
    self.m_OriginalWall = createObject(16350, 2641.3046875, -1465.5576171875, 2914.3999023438, 179.99450683594, 0, 90)
    self.m_OriginalWall:setInterior(3)
    self.m_OriginalWall:setDimension(3)
    self.m_OriginalWall:setDoubleSided(true)
    if self.m_Curtain then
        self.m_Curtain:destroy()
        self.m_FakeWall:destroy()
    end
end

function DrugFactoryEasterEgg:open()
    if self.m_OriginalWall then
        self.m_OriginalWall:destroy()

        self.m_Curtain = createObject(2559, 2653.1999511719, -1464.8599853516, 2903.3999023438, 0, 0, 180)
        self.m_Curtain:setScale(2.07999992)
        self.m_Curtain:setInterior(3)
        self.m_Curtain:setDimension(3)
        self.m_Curtain:setDoubleSided(true)

        self.m_FakeWall = createObject(16350, 2641.3046875, -1465.5576171875, 2917.2199707031, 179.99450683594, 0, 90)
        self.m_FakeWall:setInterior(3)
        self.m_FakeWall:setDimension(3)
        self.m_FakeWall:setDoubleSided(true)
    end
end

function DrugFactoryEasterEgg:onStart()
    if not isTimer(self.m_CloseTimer) then
        self:open()
        for key, player in ipairs(getElementsWithinColShape(self.m_ColShape, "player")) do
            if player:getDimension() == 3 and player:getInterior() == 3 then
                player:triggerEvent("onHeroinFactoryExplode")
                player:triggerEvent("onHeroinFactoryStartTicking")
            end
        end
        self.m_CloseTimer = setTimer(self.m_CloseBind, 7000, 1)
    end
end

function DrugFactoryEasterEgg:onStop()
    self:close()
    for key, player in ipairs(getElementsWithinColShape(self.m_ColShape, "player")) do
        if not isElementWithinColShape(player, self.m_AchievementColShape) then
            if player:getDimension() == 3 and player:getInterior() == 3 then
                player:triggerEvent("onHeroinFactoryExplode")
            end
        end
    end
    setTimer(bind(self.startScene, self), 500, 1)
end

function DrugFactoryEasterEgg:startScene()
    for key, player in ipairs(getElementsWithinColShape(self.m_AchievementColShape, "player")) do
        player:triggerEvent("onHeroinFactoryStartScene")
    end
end

function DrugFactoryEasterEgg:giveAchievement()
    client:giveAchievement(106)
end