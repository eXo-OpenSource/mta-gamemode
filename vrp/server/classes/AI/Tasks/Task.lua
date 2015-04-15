-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Task.lua
-- *  PURPOSE:     Abstract Task base class
-- *
-- ****************************************************************************
Task = inherit(Object)
Task.Map = {}

function Task:virtual_constructor(actor)
    self.m_Actor = actor
end

function Task.onInherit(derivedClass)
    -- Register class delayed (to ensure that the classes are loaded)
    nextframe(function() Task.Map[derivedClass:getId()] = derivedClass end)
end

function Task.getById(taskId)
    return Task.Map[taskId]
end

Task.getId = pure_virtual
Task.hasClientScipt = pure_virtual
