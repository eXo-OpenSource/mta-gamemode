-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Task.lua
-- *  PURPOSE:     Abstract Task base class
-- *
-- ****************************************************************************
Task = inherit(Object)
Task.Map = {}

function Task:virtual_constructor()
    if self.update then
        self.m_UpdateFunc = bind(self.update, self)
        addEventHandler("onClientPreRender", root, self.m_UpdateFunc)
    end
end

function Task:virtual_destructor()
    if self.m_UpdateFunc then
        removeEventHandler("onClientPreRender", root, self.m_UpdateFunc)
    end
end

function Task.onInherit(derivedClass)
    -- Register class delayed (to ensure that the classes are loaded)
    nextframe(function() Task.Map[derivedClass:getId()] = derivedClass end)
end

function Task.getById(taskId)
    return Task.Map[taskId]
end

Task.getId = pure_virtual
