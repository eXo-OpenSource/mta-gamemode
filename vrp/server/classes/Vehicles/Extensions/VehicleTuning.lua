-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleTuning.lua
-- *  PURPOSE:     Vehicle Tuning class
-- *
-- ****************************************************************************
VehicleTuning = inherit(Object)
VehicleTuning.Map = {}

function VehicleTuning:constructor(vehicle, tuningJSON)
	self.m_Vehicle = vehicle
	if tuningJSON then
		self.m_Tuning = fromJSON(tuningJSON)
		self:applyTuning()
	else
		self:createNew()
	end
	VehicleTuning.Map[self.m_Vehicle] = self
end

function VehicleTuning:getJSON()
	return toJSON(self.m_Tuning)
end

function VehicleTuning:applyTuning()
	setVehicleColor(self.m_Vehicle, unpack(self.m_Tuning["Color1"]), unpack(self.m_Tuning["Color2"]))
	setVehicleHeadLightColor(self.m_Vehicle, unpack(self.m_Tuning["ColorLight"]))

	for k, v in pairs(self.m_Tuning["GTATuning"] or {}) do
		addVehicleUpgrade(self, v)
	end

	self:setData("Neon", self.m_Tuning["Neon"], true)
	self:setData("NeonColor", self.m_Tuning["NeonColor"], true)

	if self.m_Tuning["Special"] > 0 then
		self.m_Vehicle:setSpecial(self.m_Tuning["Special"])
	end

	if self.m_Tuning["CustomHorn"] > 0 then
		self.m_Vehicle:setCustomHorn(self.m_Tuning["CustomHorn"])
	end

	if #self.m_Tuning["Texture"] > 3 then
		self.m_Vehicle:setTexture(self.m_Tuning["Texture"], nil, true)
	end
end

function VehicleTuning:createNew()
	self.m_Tuning = {}
	self.m_Tuning["Color1"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["Color2"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["ColorLight"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["GTATuning"] = {}
	self.m_Tuning["Neon"] = false
	self.m_Tuning["NeonColor"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["Special"] = 0
	self.m_Tuning["CustomHorn"] = 0
	self.m_Tuning["Texture"] = ""
end

function VehicleTuning:saveGTATuning()
	self.m_Tuning["GTATuning"] = getVehicleUpgrades(self.m_Vehicle) or {}
end

function VehicleTuning:saveColors()
	local r1, g1, b1, r2, g2, b2 = self.m_Vehicle:getColor()
	self.m_Tuning["Color1"] = {r1, g1, b1}
	self.m_Tuning["Color2"] = {r2, g2, b2}

	local headR, headG, headB = self.m_Vehicle:getHeadLightColor()
	self.m_Tuning["ColorLight"] = {headR, headG, headB}
end
