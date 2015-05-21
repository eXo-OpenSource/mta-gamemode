-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/ActorManager.lua
-- *  PURPOSE:     Actor manager class
-- *
-- ****************************************************************************
ActorManager = inherit(Singleton)

function ActorManager:constructor()
    self.m_Map = {}

    addEventHandler("playerReady", root, bind(self.playerReady, self))
end

function ActorManager:register(actor)
    self.m_Map[actor] = true
end

function ActorManager:unregister(actor)
    self.m_Map[actor] = nil
end

function ActorManager:playerReady()
    local player = client

    -- Sync active tasks to the client
    local syncInfo = {}
    for actor in pairs(self.m_Map) do
        syncInfo[actor] = actor:getSyncInfo()
    end

    player:triggerEvent("actorInitialSync", syncInfo)
end
