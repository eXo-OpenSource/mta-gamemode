-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Actor.lua
-- *  PURPOSE:     Actor class
-- *
-- ****************************************************************************
Actor = inherit(Ped)

function Actor:virtual_constructor()
    self.m_PrimaryTask = false
    self.m_SecondaryTasks = {}

    triggerClientEvent("actorCreate", self)
end

-- Custom allocator
function Actor:new(position, ...)
    local ped = Ped.create(0, position)
    enew(ped, self, ...)
    return ped
end

function Actor:createFromPed(ped, ...)
    enew(ped, self, ...)
end

function Actor:startPrimaryTask(taskClass, ...)
    -- Delete old primary task if available
    if self.m_PrimaryTask then
        triggerClientEvent("actorStopPrimaryTask", self)
        delete(self.m_PrimaryTask)
    end

    self.m_PrimaryTask = taskClass:new(self, ...)

    if self.m_PrimaryTask:hasClientScript() then
        local parameters = self.m_PrimaryTask.getClientParameter and self.m_PrimaryTask:getClientParameter() or {}
        triggerClientEvent("actorStartPrimaryTask", self, self.m_PrimaryTask:getId(), unpack(parameters))
    end
end

function Actor:getPrimaryTask()
    return self.m_PrimaryTask
end

function Actor:getPrimaryTaskClass()
    if self.m_PrimaryTask then
        return Task.getById(self.m_PrimaryTask:getId())
    end
    return false
end

function Actor:startSecondaryTask(taskClass, ...)
    local task = taskClass:new(self, ...)
    self.m_SecondaryTasks[#self.m_SecondaryTasks + 1] = task

    if task:hasClientScript() then
        local parameters = task.getClientParameter and task:getClientParameter() or {}
        triggerClientEvent("actorStartSecondaryTask", self, task:getId(), unpack(parameters))
    end
end

function Actor:stopSecondaryTask(taskClass)
    for k, v in pairs(self.m_SecondaryTasks) do
        if v:getId() == taskClass.getId() then
            delete(v)
            self.m_SecondaryTasks[k] = nil
            break
        end
    end
end

function Actor:getSecondaryTasks()
    return self.m_SecondaryTasks
end

function Actor:getTaskById(taskId)
    if self.m_PrimaryTask and self.m_PrimaryTask:getId() == taskId then
        return self.m_PrimaryTask
    end

    for k, v in pairs(self.m_SecondaryTasks) do
        if v:getId() == taskId then
            return v
        end
    end

    return false
end

function Actor:isDoingTask(taskId)
    return self:getTaskById(taskId) ~= false
end

function Actor:startIdleTask(...)
    if self.getIdleTask then
        self:startPrimaryTask(self:getIdleTask(), ...)
    end
end
