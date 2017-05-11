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
	if vehicle and isElement(vehicle) then
		self.m_Id = #VehicleTexture.Map+1
		self.m_Optional = not self:checkOptional(vehicle)
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
			if self.m_Vehicle and isElement(self.m_Vehicle) then
				VehicleTexture.sendToClient(getRootElement(), {{vehicle = self.m_Vehicle, textureName = self.m_Texture, texturePath = self.m_Path, optional = self.m_Optional, isRequested = false}})
			end
		end
		-- add destruction handler
		addEventHandler("onElementDestroy", self.m_Vehicle, bind(delete, self))
	else
		delete(self)
	end
end

function VehicleTexture:getTextureName()
	return self.m_Texture
end

function VehicleTexture:getPath()
	return self.m_Path
end

function VehicleTexture:checkOptional(vehicle) 
	local nOptional = VehicleManager:getSingleton().NonOptionalTextures
	for i = 1,#nOptional do 
		if instanceof(vehicle, nOptional[i]) then 
			return true
		end
	end
	return false
end

function VehicleTexture:destructor()
	VehicleTexture.Map[self.m_Id] = nil
	if self.m_Vehicle and isElement(self.m_Vehicle) then
		triggerClientEvent(root, "removeElementTexture",  self.m_Vehicle, self.m_Texture)
	end
end

function VehicleTexture.sendToClient(target, ...)
	triggerClientEvent(target, "changeElementTexture", target, ...)
end

addEvent("requestVehicleTextures", true)
addEventHandler("requestVehicleTextures", root, function()
	local vehicleTab = {}
	for index, instance in pairs(VehicleTexture.Map) do
		if instance.m_Vehicle and isElement(instance.m_Vehicle) then
			vehicleTab[#vehicleTab+1] = {vehicle = instance.m_Vehicle, textureName = instance.m_Texture, texturePath = instance.m_Path, optional = instance.m_Optional, isRequested = true}
		end
	end
	VehicleTexture.sendToClient(client, vehicleTab)
end)
