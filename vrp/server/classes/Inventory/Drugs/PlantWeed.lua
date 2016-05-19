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
	player:triggerEvent( "PlantWeed:sendClientCheck")
end

function PlantWeed:getClientCheck( bool, z_pos )
	if bool then
		local pos = client:getPosition()
		GrowableManager:getSingleton():addNewPlant("Weed", Vector3(pos.x, pos.y, z_pos), client:getName())
	else
		client:sendError("Dies ist kein guter Untergrund zum Anpflanzen!")
	end
end
