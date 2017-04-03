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

	addEventHandler("onElementDestroy", self.m_Vehicle, function() delete(self) end)
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
		self:setSpecial(self.m_Tuning["Special"])
	end

	self.m_Vehicle:setCustomHorn(self.m_Tuning["CustomHorn"])

	--{"vehiclegrunge256" = "files/images/...", "..." = "files/images/..."}
	if not self.m_Vehicle.m_IsURLTexture then
		if type(self.m_Tuning["Texture"]) == "string" then -- backward compatibility (remove if the json @ all vehicles is correct in db)
			local texture = self.m_Tuning["Texture"]
			self.m_Tuning["Texture"] = {["vehiclegrunge256"] = texture}
		end

		for textureName, texturePath in pairs(self.m_Tuning["Texture"]) do
			if #texturePath > 3 then
				self.m_Vehicle:setTexture(texturePath, textureName, true)
			end
		end
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
	self.m_Tuning["Texture"] = {}
end

function VehicleTuning:saveTuning(type, data)
	--if self.m_Tuning[type] then
	self.m_Tuning[type] = data
	--else
	--	outputDebugString("Invalid Tuning Type "..type)
	--end
end

function VehicleTuning:getTuning(type)
	return self.m_Tuning[type] or false
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
	if self.m_Vehicle.m_Texture then
		self.m_Tuning["Texture"][self.m_Vehicle.m_Texture:getTextureName() or "vehiclegrunge256"] = self.m_Vehicle.m_Texture:getPath() or ""
	end
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

function VehicleTuning:setSpecial(special)
	self.m_Vehicle.m_Special = special
	self.m_Vehicle:setData("Special", special, true)
	if special == VehicleSpecial.Soundvan then
		if self.m_Vehicle:getModel() == 535 then
			self.m_Vehicle.speakers = {}
			self.m_Vehicle.speakers["Left"] = createObject(2229, 0, 0, 0)
			self.m_Vehicle.speakers["Right"] = createObject(2229, 0, 0, 0)
			self.m_Vehicle.speakers["Middle"] = createObject(1841, 0, 0, 0)
			self.m_Vehicle.speakers["Middle"]:setScale(1.5)

			self.m_Vehicle.speakers["Left"]:attach(self.m_Vehicle, -0.3, -1.5, 0, -55, 0, 0)
			self.m_Vehicle.speakers["Right"]:attach(self.m_Vehicle, 1, -1.5, 0, -55, 0, 0)
			self.m_Vehicle.speakers["Middle"]:attach(self.m_Vehicle, 0, -0.8, 0.4, 0, 0, 90)

			for index, element in pairs(self.m_Vehicle.speakers) do
				element:setCollisionsEnabled(false)
			end

			local refreshSpeaker = function()
				for index, element in pairs(self.m_Vehicle.speakers) do
					if isElement(self.m_Vehicle) then
						element:setDimension(self.m_Vehicle:getDimension())
						element:setInterior(self.m_Vehicle:getInterior())
						if self.m_Vehicle.m_SoundURL then
							triggerClientEvent("soundvanChangeURLClient", source, self.m_Vehicle.m_SoundURL)
						end
					else
						element:destroy()
						if self.m_Vehicle.m_SoundURL then
							triggerClientEvent("soundvanStopSoundClient", self.m_Vehicle, url)
						end
					end
				end
			end

			refreshSpeaker()
			addEventHandler("onElementDimensionChange", self.m_Vehicle, refreshSpeaker)
			addEventHandler("onElementInteriorChange", self.m_Vehicle, refreshSpeaker)
			addEventHandler("onVehicleExplode", self.m_Vehicle, refreshSpeaker)
			addEventHandler("onVehicleRespawn", self.m_Vehicle, refreshSpeaker)
			addEventHandler("onElementDestroy", self.m_Vehicle, refreshSpeaker)
		end
	end
end

function VehicleTuning:addTexture(texturePath, textureName)
	self.m_Tuning["Texture"][textureName or "vehiclegrunge256"] = texturePath
end
