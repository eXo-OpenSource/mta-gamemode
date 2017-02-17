-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleTexture.lua
-- *  PURPOSE:     Vehicle Trunk class
-- *
-- ****************************************************************************
VehicleTexture = inherit(Object)
VehicleTexture.Map = {}

function VehicleTexture:constructor(vehicle, path, texture, force)
	self.m_Id = #VehicleTexture.Map+1
	self.m_Vehicle = vehicle
	self.m_Path = path

	if texture then
		self.m_Texture = texture
	elseif VEHICLE_SPECIAL_TEXTURE[vehicle:getModel()] then
		self.m_Texture = VEHICLE_SPECIAL_TEXTURE[vehicle:getModel()]
	else
		self.m_Texture = "vehiclegrunge256"
	end

	VehicleTexture.Map[self.m_Id] = self
	if force then
		triggerClientEvent(root, "changeElementTexture", root, {{vehicle = self.m_Vehicle, textureName = self.m_Texture, texturePath = self.m_Path}})
	end
end

function VehicleTexture:getPath()
	return self.m_Path
end

function VehicleTexture:destructor()
	VehicleTexture.Map[self.m_Id] = nil
	triggerClientEvent(root, "removeElementTexture", root, self.m_Vehicle)
end

addEvent("requestVehicleTextures", true)
addEventHandler("requestVehicleTextures", root, function()
	local vehicleTab = {}
	for index, instance in pairs(VehicleTexture.Map) do
		vehicleTab[#vehicleTab+1] = {vehicle = instance.m_Vehicle, textureName = instance.m_Texture, texturePath = instance.m_Path}
	end
	triggerClientEvent(client, "changeElementTexture", client, vehicleTab)
end)

