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

	self:updateNeon()

	if self.m_Tuning["Special"] > 0 then
		self.m_Vehicle:setSpecial(self.m_Tuning["Special"])
	end

	self.m_Vehicle:setCustomHorn(self.m_Tuning["CustomHorn"])

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

function VehicleTuning:loadTuningFromVehicle()
	self:saveColors()
	self:saveGTATuning()
	self.m_Tuning["Neon"] = self.m_Vehicle:getData("Neon")
	self.m_Tuning["NeonColor"] = self.m_Vehicle:getData("NeonColor")
	self.m_Tuning["Texture"] = self.m_Vehicle.m_Texture and self.m_Vehicle.m_Texture:getPath() or ""
end

function VehicleTuning:updateNeon()
	local state = self.m_Tuning["Neon"]
	self.m_Vehicle:setData("Neon", state, true)
	if state == true then
		self.m_Vehicle.m_Neon = self.m_Tuning["NeonColor"] or {255, 0, 0}
		self.m_Vehicle:setData("NeonColor", self.m_Vehicle.m_Neon, true)
	else
		self.m_Vehicle.m_Neon = false
	end
end
