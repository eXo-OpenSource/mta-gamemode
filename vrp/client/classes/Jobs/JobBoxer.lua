-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobBoxer.lua
-- *  PURPOSE:     Boxer job class
-- *
-- ****************************************************************************

JobBoxer = inherit(Job)

function JobBoxer:constructor()
    Job.constructor(self, 307, 2228.39, -1718.57, 13.55, 90.98, "BoxingGlove.png", {200, 40, 30}, "files/images/Jobs/HeaderBoxer.png", _(HelpTextTitles.Jobs.Boxer):gsub("Job: ", ""), _(HelpTexts.Jobs.Boxer))
    self:setJobLevel(JOB_LEVEL_BOXER)

    addRemoteEvents{"boxerJobFightList", "boxerJobTopList"}
    addEventHandler("boxerJobFightList", root, bind(JobBoxer.openFightList, self))
    addEventHandler("boxerJobTopList", root, bind(JobBoxer.openTopList, self))
end

function JobBoxer:start()
    HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Boxer), _(HelpTexts.Jobs.Boxer))
end

function JobBoxer:stop()
    HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end

function JobBoxer:openFightList()
    JobBoxerGUI:new()
end

function JobBoxer:openTopList(table, playertable)
    JobBoxerTopList:new(table, playertable)
end

function JobBoxer:startJob(type)
    local dimension = DimensionManager:getSingleton():getFreeDimension()
    triggerServerEvent("boxerJobStartJob", localPlayer, type, dimension)
    
    self.m_Boxer = Ped(math.random(80, 81), Vector3(763.25, 11.18, 1001.16), 90)
    self.m_Boxer:setInterior(5)
    self.m_Boxer:setDimension(dimension)
    self.m_Boxer:setHealth(JobBoxerFights[type][2])
    self.m_BoxLevel = type

    self.m_ColShape = ColShape.Cuboid(757.51, 7.76, 999, 7, 7, 5)
    self.m_ColShape:setInterior(5)
    self.m_ColShape:setDimension(dimension)
    addEventHandler("onClientColShapeLeave", self.m_ColShape, bind(self.onClientColShapeLeave, self, leaveElement, matchingDimension))

    bindKey("L", "down", bind(self.abortJob, self))

    self.m_StartTick = getTickCount()
    self.m_LastTick = getTickCount()
    self.m_NextTick = getTickCount()
    addEventHandler("onClientPreRender", root, bind(self.aiUpdate, self, self.m_Boxer))
end

function JobBoxer:onClientColShapeLeave(leaveElement, matchingDimension)
    if matchingDimension then
        if leaveElement == localPlayer then
            self:abortJob()
        end
    end
end

function JobBoxer:aiUpdate(boxer)
    if isElement(boxer) then
        if boxer:isDead() == false then
            local boxerPos = boxer:getPosition()
            local playerPos = localPlayer:getPosition()
            local now = getTickCount()
            local boxerDistance = getDistanceBetweenPoints3D(boxerPos.x, boxerPos.y, boxerPos.z, playerPos.x, playerPos.y, playerPos.z)
            local boxerRotation = findRotation(boxerPos.x, boxerPos.y, playerPos.x, playerPos.y)
            boxer:setRotation(0, 0, boxerRotation)
            setPedControlState(boxer, "aim_weapon", true)
            if boxerDistance < 2 then
                if localPlayer:isDead() then
                    self:boxerRemoveControlStates(boxer)
                    setPedControlState(boxer, "fire", false)
                    return
                end
                if now > self.m_NextTick then
                    boxerActionRandom = math.random(0, JobBoxerFightRandoms[self.m_BoxLevel][1])
                    self.m_LastTick = getTickCount()
                end
                if boxerActionRandom < JobBoxerFightRandoms[self.m_BoxLevel][2] then
                    self:boxerPunch(boxer)
                    self.m_NextTick = self.m_LastTick+(boxerActionRandom*1000)
                elseif boxerActionRandom < JobBoxerFightRandoms[self.m_BoxLevel][3] then
                    self:boxerBlock(boxer)
                    self.m_NextTick = self.m_LastTick+(math.random(1, 6)*1000)
                elseif boxerActionRandom < JobBoxerFightRandoms[self.m_BoxLevel][4] then
                    self:boxerLeft(boxer)
                    self.m_NextTick = self.m_LastTick+(math.random(1, 3)*750)
                elseif boxerActionRandom < JobBoxerFightRandoms[self.m_BoxLevel][5] then
                    self:boxerRight(boxer)
                    self.m_NextTick = self.m_LastTick+(math.random(1, 3)*750)
                else
                    self:boxerRemoveControlStates(boxer)
                    self.m_NextTick = self.m_LastTick+1500
                end
            else
                setPedControlState(boxer, "left", false)
                setPedControlState(boxer, "right", false)
                setPedControlState(boxer, "jump", false)
                setPedControlState(boxer, "fire", false)
                setPedControlState(boxer, "forwards", true)
            end
        else
            self:stopJob()
        end
    end
end

function JobBoxer:boxerRemoveControlStates(boxer)
    setPedControlState(boxer, "left", false)
    setPedControlState(boxer, "right", false)
    setPedControlState(boxer, "jump", false)
    setPedControlState(boxer, "forwards", false)
end

function JobBoxer:boxerPunch(boxer)
    self:boxerRemoveControlStates(boxer)
    setPedControlState(boxer, "fire", not getPedControlState(boxer, "fire"))
end

function JobBoxer:boxerBlock(boxer)
    self:boxerRemoveControlStates(boxer)
    setPedControlState(boxer, "fire", false)
    setPedControlState(boxer, "jump", true)
end

function JobBoxer:boxerLeft(boxer)
    self:boxerRemoveControlStates(boxer)
    setPedControlState(boxer, "fire", false)
    setPedControlState(boxer, "left", true)
end

function JobBoxer:boxerRight(boxer)
    self:boxerRemoveControlStates(boxer)
    setPedControlState(boxer, "fire", false)
    setPedControlState(boxer, "right", true)
end

function JobBoxer:stopJob()
    if isElement(self.m_Boxer) then
        self.m_Boxer:destroy()
        localPlayer:setPosition(763.26, 5.48, 1000.71)
        localPlayer:setRotation(0, 0, 270)
        setCameraTarget(localPlayer)
        triggerServerEvent("boxerJobEndJob", localPlayer)
        self.m_ColShape:destroy()
    end
end

function JobBoxer:abortJob()
    if isElement(self.m_Boxer) then
        self.m_Boxer:destroy()
        localPlayer:setPosition(763.26, 5.48, 1000.71)
        localPlayer:setRotation(0, 0, 270)
        setCameraTarget(localPlayer)
        triggerServerEvent("boxerJobAbortJob", localPlayer)
        self.m_ColShape:destroy()
    end
end