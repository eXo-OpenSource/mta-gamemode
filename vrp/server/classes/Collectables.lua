-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Collectables.lua
-- *  PURPOSE:     Collectables server-side class
-- *
-- ****************************************************************************
Collectables = inherit(Singleton)

addEvent("requestCollectables", true)
addEvent("checkCollectableHit", true)

function Collectables:constructor()
	
	addEventHandler("requestCollectables", root, bind(self.sendCollectables,self))
	addEventHandler("checkCollectableHit", root, bind(self.checkCollectable,self))
end

function Collectables:checkCollectable(collectableID)
	if not client then return end
	local x,y,z = getElementPosition(client)
	local px,py,pz = unpack(Collectables.POSITIONS[collectableID])
	if getDistanceBetweenPoints3D (x,y,z,px,py,pz) >= 10 then
		print(("WARNING: %s is maybe cheatin' @ collectables"):format(getPlayerName(client)))
	else
		local collectables = client:getCollectables() or {}
		collectables[collectableID] = "1"
		client:setCollectables(collectables)
	end
end

function Collectables:sendCollectables()
	if not client then return end
	
	triggerClientEvent(client,"reciveCollectables",client,Collectables.POSITIONS,client:getCollectables() or {})
end

-- Todo: Add Collectables spots

Collectables.POSITIONS = {
--{0,10,3},
--{0,20,3},
}