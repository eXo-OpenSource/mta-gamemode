-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Actor.lua
-- *  PURPOSE:     Actor class
-- *
-- ****************************************************************************
Actor = inherit(Ped)
addRemoteEvents{"actorCreate", "actorStartPrimaryTask", "actorStopPrimaryTask", "actorStartSecondaryTask", "actorInitialSync"}

function Actor:constructor()
    self.m_PrimaryTask = false
    self.m_SecondaryTasks = {}
end

function Actor:destructor()
    if self.m_PrimaryTask then
        delete(self.m_PrimaryTask)
    end

    for k, task in pairs(self.m_SecondaryTasks) do
        delete(task)
    end
end

function Actor:getPrimaryTask()
    return self.m_PrimaryTask
end

function Actor:setPrimaryTask(task)
    self.m_PrimaryTask = task
end

function Actor:addSecondaryTask(task)
    self.m_SecondaryTasks[#self.m_SecondaryTasks + 1] = task
end

function Actor:removeSecondaryTaskById(taskId)
    for k, v in pairs(self.m_SecondaryTasks) do
        if taskId == v:getId() then
            delete(v)
            self.m_SecondaryTasks[k] = nil
            break
        end
    end
end

addEventHandler("actorCreate", root,
    function(...)
        enew(source, Actor, ...)
    end
)

addEventHandler("actorStartPrimaryTask", root,
    function(taskId, ...)
        local taskClass = Task.getById(taskId)
        if taskClass then
            source:setPrimaryTask(taskClass:new(source, ...))
        else
            error("Invalid primary task Id has been passed!")
        end
    end
)

addEventHandler("actorStopPrimaryTask", root,
    function()
        local task = source:getPrimaryTask()
        if task then
            delete(task)
            source:setPrimaryTask(false)
        end
    end
)

addEventHandler("actorStartSecondaryTask", root,
    function(taskId, ...)
        local taskClass = Task.getById(taskId)
        if taskClass then
            source:addPrimaryTask(taskClass:new(source, ...))
        else
            error("Invalid secondary task Id has been passed!")
        end
    end
)

addEventHandler("actorStopSecondaryTask", root,
    function(taskId)
        source:removeSecondaryTaskById(taskId)
    end
)

addEventHandler("actorInitialSync", root,
    function(syncInfo)
        local loadSyncInfo = function(actor, info)
                local taskId, parameters = unpack(info)
                local taskClass = Task.getById(taskId)
                --outputDebug("Loading taskId: "..tostring(taskId).."; taskClass: "..tostring(taskClass))
                if taskClass then
                    actor:setPrimaryTask(taskClass:new(actor, unpack(parameters)))
                end
            end

        for actor, info in pairs(syncInfo) do
            enew(actor, Actor)

            if info.Primary then
                loadSyncInfo(actor, info.Primary)
            end

            for k, secInfo in pairs(info.Secondary) do
                loadSyncInfo(actor, secInfo)
            end
        end
    end
)
