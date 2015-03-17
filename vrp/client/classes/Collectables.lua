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

	for key, value in ipairs(self.m_Pickups) do
		if value == source then
			triggerServerEvent("checkCollectableHit",localPlayer,key)
			setElementDimension(value,PRIVATE_DIMENSION_SERVER)
		end
	end
end

function Collectables:reciveCollectables(positions,progress)
	for key, value in ipairs(positions) do
		self.m_Pickups[key] = createPickup(value[1],value[2],value[3],3,2903)
		if progress[tostring(key)] == "1" then
			setElementDimension(self.m_Pickups[key],PRIVATE_DIMENSION_SERVER)
		end
	end
end

function Collectables:destructor()

end
