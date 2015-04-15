-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Actor.lua
-- *  PURPOSE:     Actor class
-- *
-- ****************************************************************************
Actor = inherit(Ped)
addRemoteEvents{"actorCreate", "actorStartPrimaryTask"}

function Actor:constructor()

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
            taskClass:new(source, ...)
        else
            error("Invalid primary task Id has been passed!")
        end
    end
)
