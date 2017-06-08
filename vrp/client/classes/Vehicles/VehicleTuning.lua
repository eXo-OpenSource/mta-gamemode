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
	local r1, g1, b1 = unpack(self.m_Tuning["Color1"])
	local r2, g2, b2 = unpack(self.m_Tuning["Color2"])
	self.m_Vehicle:setColor(r1, g1, b1, r2, g2, b2)
	local rh, gh, bh = unpack(self.m_Tuning["ColorLight"])
	self.m_Vehicle:setHeadLightColor(rh, gh, bh)

	for i = 0, 16 do
		removeVehicleUpgrade(self.m_Vehicle, i)
	end

	for k, v in pairs(self.m_Tuning["GTATuning"] or {}) do
		addVehicleUpgrade(self.m_Vehicle, v)
	end

	self.m_Vehicle:setData("Neon", self.m_Tuning["Neon"], true)
    if self.m_Tuning["Neon"] then
		Neon.Vehicles[self.m_Vehicle] = true
	end

	self.m_Vehicle:setData("NeonColor", self.m_Tuning["NeonColor"], true)
end

function VehicleTuning:setTexture(texture)
	if not getElementData(self.m_Vehicle, "URL_PAINTJOB") then
		if self.m_Texture then delete(self.m_Texture) end
		TextureReplace.deleteFromElement(self.m_Vehicle)
		if texture and texture:len() > 3 then
			--self.m_Texture = TextureReplace:new(self.m_Vehicle:getTextureName(), texture, false, 250, 250, self.m_Vehicle)
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
	--if self.m_Tuning[type] then
		self.m_Tuning[type] = data
	--else
	--	outputDebugString("Invalid Tuning Type "..type)
	--end
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
	self.m_Tuning["Neon"] = self.m_Vehicle:getData("Neon")
	self.m_Tuning["NeonColor"] = self.m_Vehicle:getData("NeonColor")
	if TextureReplace.Map[self.m_Vehicle] then
		self.m_Tuning["Texture"] = TextureReplace.Map[self.m_Vehicle].m_TexturePath
	else
		self.m_Tuning["Texture"] = ""
	end
end
