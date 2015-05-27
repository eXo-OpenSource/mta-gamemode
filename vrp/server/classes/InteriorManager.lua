-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorManager.lua
-- *  PURPOSE:     Manages interiors and its dimensions
-- *
-- ****************************************************************************
InteriorManager = inherit(Singleton)

function InteriorManager:constructor()
    self.m_Map = {}
end

function InteriorManager:registerInterior(Id, interiorId, spawnPosition)
    self.m_Map[Id] = {
        InteriorId = interiorId,
        SpawnPosition = spawnPosition
    }
end

function InteriorManager:getInteriorInfo(Id)
    local info = self.m_Map[Id]
    if info then
        return info.InteriorId, info.SpawnPosition
    end
    return false, false
end

function InteriorManager:teleportPlayerToInterior(player, Id)
    local interiorId, position = self:getInteriorInfo(Id)
    if interiorId then
        player:setInterior(interiorId, position)
        player:setDimension(Id)
        player:setUniqueInterior(Id)
    end
end
