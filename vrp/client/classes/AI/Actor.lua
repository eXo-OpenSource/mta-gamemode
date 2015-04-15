-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Actor.lua
-- *  PURPOSE:     Actor class
-- *
-- ****************************************************************************
Actor = inherit(Ped)
addRemoteEvents{"actorCreate", "actorStartPrimaryTask", "actorStopPrimaryTask"}

function Actor:constructor()
    self.m_PrimaryTask = false
end

function Actor:getPrimaryTask()
    return self.m_PrimaryTask
end

function Actor:setPrimaryTask(task)
    self.m_PrimaryTask = task
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
