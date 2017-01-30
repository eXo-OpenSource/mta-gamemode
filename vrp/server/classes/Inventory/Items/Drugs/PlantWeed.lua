-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
PlantWeed = inherit(Item)

function PlantWeed:constructor()
	self.m_Name = "Weed"
	addRemoteEvents{"PlantWeed:getClientCheck"}
	addEventHandler("PlantWeed:getClientCheck",root, bind(self.getClientCheck, self))
end

function PlantWeed:destructor()
end

function PlantWeed:use(player)
	if not GrowableManager:getSingleton():getNextPlant(player, 3) then
		player:triggerEvent("PlantWeed:sendClientCheck")
	else
		player:sendInfo(_("Du bist zu nah an einer anderen Pflanze!", player))
	end
end

function PlantWeed:getClientCheck( bool, z_pos )
	if bool then
		if client:isOnGround() then
			if not client.vehicle then
				local pos = client:getPosition()
				client:getInventory():removeItem("Weed-Samen", 1)
				GrowableManager:getSingleton():addNewPlant("Weed", Vector3(pos.x, pos.y, z_pos), client)
			else
				client:sendError("Du sitzt in einem Fahrzeug!")
			end
		else
			client:sendError("Du bist nicht am Boden!")
		end
	else
		client:sendError("Dies ist kein guter Untergrund zum Anpflanzen!")
	end
end
