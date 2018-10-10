-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        client/classes/Vehicles/VehicleTuning.lua
-- *  PURPOSE:     Client Vehicle Tuning class
-- *
-- ****************************************************************************
VehicleTuning = inherit(Object)

function VehicleTuning:constructor(vehicle)
	self.m_Vehicle = vehicle
	self.m_Tuning = {}
	self:loadTuningsFromVehicle()
end

function VehicleTuning:getJSON()
	return toJSON(self.m_Tuning)
end

function VehicleTuning:getTunings()
	return self.m_Tuning
end

function VehicleTuning:applyTuning()
	if self.m_Vehicle and isElement(self.m_Vehicle) and self.m_Vehicle.upgrades then
		local r1, g1, b1 = unpack(self.m_Tuning["Color1"])
		local r2, g2, b2 = unpack(self.m_Tuning["Color2"])
		self.m_Vehicle:setColor(r1, g1, b1, r2, g2, b2)
		local rh, gh, bh = unpack(self.m_Tuning["ColorLight"])
		self.m_Vehicle:setHeadLightColor(rh, gh, bh)

		for _, v in pairs(self.m_Vehicle.upgrades) do
			removeVehicleUpgrade(self.m_Vehicle, v)
		end

		for _, v in pairs(self.m_Tuning["GTATuning"] or {}) do
			addVehicleUpgrade(self.m_Vehicle, v)
		end

		self.m_Vehicle:setData("Neon", self.m_Tuning["Neon"])
		self.m_Vehicle:setData("NeonColor", self.m_Tuning["NeonColor"])

		Neon.Vehicles[self.m_Vehicle] = self.m_Tuning["Neon"] and true or nil

		triggerServerEvent("vehicleSetVariant", self.m_Vehicle, self.m_Tuning["Variant1"], self.m_Tuning["Variant2"])
	end
end

function VehicleTuning:setTexture(texture)
	if not getElementData(self.m_Vehicle, "URL_PAINTJOB") then
		if self.m_Texture then delete(self.m_Texture) end
		TextureReplacer.deleteFromElement(self.m_Vehicle)
		if texture and texture:len() > 3 then
			if string.find(texture, "https://") or string.find(texture, "http://") then
				self.m_Texture =  HTTPTextureReplacer:new(self.m_Vehicle, texture, self.m_Vehicle:getTextureName())
			else
				self.m_Texture =  FileTextureReplacer:new(self.m_Vehicle, texture, self.m_Vehicle:getTextureName())
			end
		end
	end
end

function VehicleTuning:getTuning(type)
	if self.m_Tuning[type] then
		return self.m_Tuning[type]
	else
		return false
		--outputDebugString("Invalid Tuning Type "..type)
	end
end

function VehicleTuning:saveTuning(type, data)
	self.m_Tuning[type] = data
end

function VehicleTuning:saveGTATuning()
	self.m_Tuning["GTATuning"] = getVehicleUpgrades(self.m_Vehicle) or {}
end

function VehicleTuning:saveColors()
	local r1, g1, b1, r2, g2, b2 = self.m_Vehicle:getColor(true)
	self.m_Tuning["Color1"] = {r1, g1, b1}
	self.m_Tuning["Color2"] = {r2, g2, b2}

	local headR, headG, headB = self.m_Vehicle:getHeadLightColor()
	self.m_Tuning["ColorLight"] = {headR, headG, headB}
end

function VehicleTuning:loadTuningsFromVehicle()
	self:saveColors()
	self:saveGTATuning()
	local variant1, variant2 = self.m_Vehicle:getVariant()
	self.m_Tuning["Variant1"] = variant1
	self.m_Tuning["Variant2"] = variant2
	self.m_Tuning["Neon"] = self.m_Vehicle:getData("Neon")
	self.m_Tuning["NeonColor"] = self.m_Vehicle:getData("NeonColor")
end
