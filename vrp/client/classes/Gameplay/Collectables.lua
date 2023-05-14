-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Collectables.lua
-- *  PURPOSE:     Collectables client-side class
-- *
-- ****************************************************************************
Collectables = inherit(Singleton)

addEvent("reciveCollectables", true)

function Collectables:constructor()
    self.m_Pickups = {}

    -- Request for pickup positions
    triggerServerEvent("requestCollectables", localPlayer)


    addEventHandler("reciveCollectables", root, bind(self.reciveCollectables,self))
    addEventHandler("onClientPickupHit" , root, bind(self.onCollectableHit,self))
end

function Collectables:onCollectableHit(hitElement)
    if hitElement ~= localPlayer then return end

    for key, value in pairs(self.m_Pickups) do
        if value == source then
            triggerServerEvent("checkCollectableHit", localPlayer, key)
            self.m_Pickups[key]:destroy()
        end
    end
end

function Collectables:reciveCollectables(positions)
	for key, value in pairs(positions) do
        self.m_Pickups[key] = createPickup(value[1], value[2], value[3], 3, 2836)
    end
end

function Collectables:destructor()

end
