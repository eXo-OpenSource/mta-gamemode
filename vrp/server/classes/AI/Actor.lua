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

    triggerClientEvent("actorCreate", self)
end

-- Custom allocator
function Actor:new(position, ...)
    local ped = Ped.create(0, position)
    enew(ped, self, ...)
    return ped
end

function Actor:startPrimaryTask(taskClass, ...)
    -- Delete old primary task if available
    if self.m_PrimaryTask then
        delete(self.m_PrimaryTask)
    end

    self.m_PrimaryTask = taskClass:new(self, ...)

    if self.m_PrimaryTask:hasClientScript() then
        -- TODO: Maybe start task only for close players
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
