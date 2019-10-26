-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Halloween/EasterEggs.lua
-- *  PURPOSE:     Ghost Ship class
-- *
-- ****************************************************************************

HalloweenEasterEggs = inherit(Singleton)
addRemoteEvents{"Halloween:giveEasterEggReward", "Halloween:requestEasterEggs"}

function HalloweenEasterEggs:constructor()
    self.m_GhostShips = {
        {-3469, 1505, 14.193, "Palisades"}, -- -3469.46, 1515.87, 4.69 <- Geist
        {697, -2755, 14.193, "Verona Beach"},
        {2000, -3354, 14.193, "Los Santos International"},
        {3491, -2457, 14.193, "Ocean Docks"},
        {3438, 1656, 14.193, "Linden Side"},
    }
    self.m_Rewards = {pumpkins = math.random(3, 5), sweets = math.random(10, 20)}
    self.m_DiscoveredAchievents = {} -- ship, zombie, mother ghost, mount chilliad ghost
    addEventHandler("Halloween:requestEasterEggs", root, bind(self.requestEasterEggs, self))
    addEventHandler("Halloween:giveEasterEggReward", root, bind(self.giveReward, self))
    GlobalTimer:getSingleton():registerEvent(function()
        self:createGhostShip()
    end, "Halloween Ghost Ship Announcement", nil, 20, 0)

    GlobalTimer:getSingleton():registerEvent(function()
        for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
            self:sendEasterEggs(player)
        end
    end, "Halloween Easter Egg Zombie", nil, 18, 0)
    GlobalTimer:getSingleton():registerEvent(function()
        for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
            self:sendEasterEggs(player)
        end
    end, "Halloween Easter Egg Mother Ghost", nil, 21, 0)
    GlobalTimer:getSingleton():registerEvent(function()
        for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
            self:sendEasterEggs(player)
        end
    end, "Halloween Easter Egg Mount Chilliad Ghost", nil, 23, 0)
    
end

function HalloweenEasterEggs:createGhostShip()
    self.m_ShipId = math.random(1, #self.m_GhostShips)
    local x, y, z = self.m_GhostShips[self.m_ShipId][1], self.m_GhostShips[self.m_ShipId][2], self.m_GhostShips[self.m_ShipId][3]
    local zone = self.m_GhostShips[self.m_ShipId][4]
    self.m_Ship = createObject(8493, x, y, z)
    local LOD = createObject(8977, x, y, z, 0, 0, 0, true)
    LOD:attach(self.m_Ship, 0, 0, 0)
    local fences = createObject(9159, x, y, z)
    fences:attach(self.m_Ship)
    local wires = createObject(8981, x, y, z)
    wires:attach(self.m_Ship, -0.55, -6.19, -0.4375)
    self.m_ShipColShape = createColSphere(x, y, z, 300)
    addEventHandler("onColShapeHit", self.m_ShipColShape, bind(self.onShipColShapeHit, self))

    PlayerManager:getSingleton():breakingNews(("Ein merkwürdiges Schiff ist an der Küste von %s aufgetaucht!"):format(zone))
end

function HalloweenEasterEggs:onShipColShapeHit(hitElement)
    if getElementType(hitElement) == "player" then
        if self.m_DiscoveredAchievents[hitElement:getId()] and not self.m_DiscoveredAchievents[hitElement:getId()][1] then
            hitElement:triggerEvent("Halloween:createGhostShip", self.m_Ship)
        end
    end
end

function HalloweenEasterEggs:giveReward(id)
    if client:getId() then
        if not self.m_DiscoveredAchievents[client:getId()] then 
            self.m_DiscoveredAchievents[client:getId()] = {[1]=false,[2]=false,[3]=false,[4]=false} 
        end

        if not self.m_DiscoveredAchievents[client:getId()][id] then
            self.m_DiscoveredAchievents[client:getId()][id] = true
            
            client:getInventory():giveItem("Kürbis", self.m_Rewards.pumpkins)
            client:getInventory():giveItem("Suessigkeiten", self.m_Rewards.sweets)

            client:sendSuccess(_("Du hast %s Kürbisse und und %s Süßigkeiten erhalten!", client, self.m_Rewards.pumpkins, self.m_Rewards.sweets))
        end
    end
end

function HalloweenEasterEggs:requestEasterEggs()
    if client:getId() then
        self:sendEasterEggs(client)
    end
end

function HalloweenEasterEggs:sendEasterEggs(player)
    if not self.m_DiscoveredAchievents[player:getId()] then 
        self.m_DiscoveredAchievents[player:getId()] = {[1]=false,[2]=false,[3]=false,[4]=false} 
    end
    if not self.m_DiscoveredAchievents[player:getId()][2] and (getRealTime().hour >= 17 or getRealTime().hour <= 4) then
        player:triggerEvent("Halloween:createZombie")
    end
    if not self.m_DiscoveredAchievents[player:getId()][3] and (getRealTime().hour >= 20 or getRealTime().hour <= 4) then
        player:triggerEvent("Halloween:createMotherGhost")
    end
    if not self.m_DiscoveredAchievents[player:getId()][4] and (getRealTime().hour >= 22 or getRealTime().hour <= 4) then
        player:triggerEvent("Halloween:createMountChilliadGhost")
    end
end