-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Hook.lua
-- *  PURPOSE:     Hook class (helps us to handle things from other position in the code)
-- *
-- ****************************************************************************
Hook = inherit(Object)

function Hook:constructor()
    self.m_Functions = {}
end

function Hook:register(hookFunc)
    self.m_Functions[#self.m_Functions + 1] = hookFunc
end

function Hook:call(...)
    for k, hookFunc in pairs(self.m_Functions) do
        if hookFunc(...) then
            return true
        end
    end
end
