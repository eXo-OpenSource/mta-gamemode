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
		if self.m_Tuning then
			self:applyTuning(self.m_Tuning["TextureForce"] or false)
		else
			self:createNew()
		end
	else
		self:createNew()
	end
	VehicleTuning.Map[self.m_Vehicle] = self

	addEventHandler("onElementDestroy", self.m_Vehicle, function() delete(self) end, false)
end

function VehicleTuning:getJSON()
	return toJSON(self.m_Tuning, true)
end

function VehicleTuning:getTunings()
	return self.m_Tuning
end

function VehicleTuning:applyTuning(disableTextureForce)

	if self.m_Tuning["Color1"] then
		local colors = {}
		local r, g, b = unpack(self.m_Tuning["Color1"])

		table.insert(colors, r)
		table.insert(colors, g)
		table.insert(colors, b)

		if self.m_Tuning["Color2"] then
			local r, g, b = unpack(self.m_Tuning["Color2"])

			table.insert(colors, r)
			table.insert(colors, g)
			table.insert(colors, b)

			if self.m_Tuning["Color3"] then
				local r, g, b = unpack(self.m_Tuning["Color3"])

				table.insert(colors, r)
				table.insert(colors, g)
				table.insert(colors, b)

				if self.m_Tuning["Color4"] then
					local r, g, b = unpack(self.m_Tuning["Color4"])

					table.insert(colors, r)
					table.insert(colors, g)
					table.insert(colors, b)
				end
			end
		end

		self.m_Vehicle:setColor(unpack(colors))
	end


	local rh, gh, bh = 255, 255, 255
	if self.m_Tuning["ColorLight"] then rh, gh, bh =  unpack(self.m_Tuning["ColorLight"]) end
	self.m_Vehicle:setHeadLightColor(rh, gh, bh)

	for _, v in pairs(self.m_Vehicle.upgrades) do
		removeVehicleUpgrade(self.m_Vehicle, v)
	end

	for _, v in pairs(self.m_Tuning["GTATuning"] or {}) do
		addVehicleUpgrade(self.m_Vehicle, v)
	end

	self:updateNeon()

	if self.m_Tuning["Special"] and self.m_Tuning["Special"] > 0 then
		self:setSpecial(self.m_Tuning["Special"])
	end

	if self.m_Tuning["Variant1"] or self.m_Tuning["Variant2"] then
		self.m_Vehicle:setVariant(self.m_Tuning["Variant1"] or 255, self.m_Tuning["Variant2"] or 255)
	end

	self.m_Vehicle:setCustomHorn(self.m_Tuning["CustomHorn"])

	--{"vehiclegrunge256" = "files/images/...", "..." = "files/images/..."}
	--[[if type(self.m_Tuning["Texture"]) == "string" then -- backward compatibility (remove if the json @ all vehicles is correct in db)
		local texture = self.m_Tuning["Texture"]
		self.m_Tuning["Texture"] = {["vehiclegrunge256"] = texture}
	end]]
	if self.m_Tuning["Texture"] then
		for textureName, texturePath in pairs(self.m_Tuning["Texture"]) do
			if #texturePath > 3 then
				self.m_Vehicle:setTexture(texturePath, textureName, not disableTextureForce)
			else
				self.m_Tuning["Texture"][textureName] = nil
			end
		end
	end

	if self.m_TuningKits then
		for tuning, class in pairs(self.m_TuningKits) do
			class:destroy()
		end
	end

	self.m_TuningKits = { }
	for tuning, class in pairs(VehicleManager:getSingleton().m_TuningClasses) do 
		if self.m_Tuning[tuning] then 
			if self.m_Tuning[tuning][1] == 1 then 
				self.m_TuningKits[tuning] = class:new( self.m_Vehicle, unpack(self.m_Tuning[tuning],2) ) 
			end
		end
	end
	
	self:saveTuningKits()
end

function VehicleTuning:createNew()
	self.m_Tuning = {}
	self.m_Tuning["Color1"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["Color2"] = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.m_Tuning["ColorLight"] = {255, 255, 255}
	self.m_Tuning["GTATuning"] = {}
	self.m_Tuning["Neon"] = 0
	self.m_Tuning["NeonColor"] = {0, 0, 0}
	self.m_Tuning["Special"] = 0
	self.m_Tuning["CustomHorn"] = 0
	self.m_Tuning["Texture"] = {}
	self.m_Tuning["Variant1"] = 255
	self.m_Tuning["Variant2"] = 255

	for tuning, class in pairs(VehicleManager:getSingleton().m_TuningClasses) do
		self.m_Tuning[tuning] = {0} -- the first index in every tuning-kit field will be indicating wether the kit is installed or not
	end
end

function VehicleTuning:saveTuning(type, data)
	self.m_Tuning[type] = data
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

function VehicleTuning:saveTuningKits()

	for tuning, class in pairs(VehicleManager:getSingleton().m_TuningClasses) do -- Reset every Tuning-Kit in case some got destructed
		self.m_Tuning[tuning] = {0}
	end

	for tuning, class in pairs(self.m_TuningKits) do -- loop through active tuning kits
		self.m_Tuning[tuning] = class:save() or {0}
	end

end

function VehicleTuning:addTuningKit( name )
	if VehicleManager:getSingleton().m_TuningClasses[name] then 
		self.m_TuningKits[name] = VehicleManager:getSingleton().m_TuningClasses[name]:new( self.m_Vehicle )
	end
	self:saveTuningKits()
end

function VehicleTuning:removeTuningKit( kit )
	for tuning, class in pairs(self.m_TuningKits) do -- loop through active tuning kits
		if class == kit then 
			self.m_TuningKits[tuning] = nil
		end
	end
	self:saveTuningKits()
end

function VehicleTuning:loadTuningFromVehicle()
	self:saveColors()
	self:saveGTATuning()
	self:saveTuningKits()
	self.m_Tuning["Neon"] = self.m_Vehicle:getData("Neon") and 1 or 0
	self.m_Tuning["NeonColor"] = self.m_Vehicle:getData("NeonColor")
	local variant1, variant2 = self.m_Vehicle:getVariant()
	self.m_Tuning["Variant1"] = variant1
	self.m_Tuning["Variant2"] = variant2
	if self.m_Vehicle.m_Texture then
		self.m_Tuning["Texture"][self.m_Vehicle.m_Texture:getTextureName() or "vehiclegrunge256"] = self.m_Vehicle.m_Texture:getPath() or ""
	end
end

function VehicleTuning:updateNeon()
	if self.m_Tuning["Neon"] == true then self.m_Tuning["Neon"] = 1 end -- Workaround, remove until irgendwann

	local state = self.m_Tuning["Neon"] == 1
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
			if self.m_Vehicle.m_Speakers then
				for _, v in pairs(self.m_Vehicle.m_Speakers) do
					if isElement(v) then
						v:destroy()
					end
				end
			end

			self.m_Vehicle.m_Speakers = {}
			self.m_Vehicle.m_Speakers["Left"] = createObject(2229, 0, 0, 0)
			self.m_Vehicle.m_Speakers["Right"] = createObject(2229, 0, 0, 0)
			self.m_Vehicle.m_Speakers["Middle"] = createObject(1841, 0, 0, 0)
			self.m_Vehicle.m_Speakers["Middle"]:setScale(1.5)

			for index, element in pairs(self.m_Vehicle.m_Speakers) do
				element:setCollisionsEnabled(false)
			end

			self.refreshSpeaker =
				function()
					for index, element in pairs(self.m_Vehicle.m_Speakers) do
						if isElement(self.m_Vehicle) then
							element:setDimension(self.m_Vehicle:getDimension())
							element:setInterior(self.m_Vehicle:getInterior())
							element:setPosition(self.m_Vehicle:getPosition())
						end
					end

					self.m_Vehicle.m_Speakers["Left"]:attach(self.m_Vehicle, -0.3, -1.5, 0, -55, 0, 0)
					self.m_Vehicle.m_Speakers["Right"]:attach(self.m_Vehicle, 1, -1.5, 0, -55, 0, 0)
					self.m_Vehicle.m_Speakers["Middle"]:attach(self.m_Vehicle, 0, -0.8, 0.4, 0, 0, 90)

					if self.m_Vehicle.m_SoundURL then
						triggerClientEvent("soundvanChangeURLClient", self.m_Vehicle, self.m_Vehicle.m_SoundURL)
					end
				end

			self.destroySpeaker =
				function()
					for index, element in pairs(self.m_Vehicle.m_Speakers) do
						if isElement(element) then
							element:destroy()
						end
					end

					if self.m_Vehicle.m_SoundURL then
						triggerClientEvent("soundvanStopSoundClient", self.m_Vehicle, url)
					end
				end

			self.refreshSpeaker()
			addEventHandler("onElementDimensionChange", self.m_Vehicle, self.refreshSpeaker)
			addEventHandler("onElementInteriorChange", self.m_Vehicle, self.refreshSpeaker)
			addEventHandler("onVehicleExplode", self.m_Vehicle, self.refreshSpeaker)
			addEventHandler("onVehicleRespawn", self.m_Vehicle, self.refreshSpeaker)
			addEventHandler("onElementDestroy", self.m_Vehicle, self.destroySpeaker, false)
		end
	end
end

function VehicleTuning:addTexture(texturePath, textureName)
	local textureName = VEHICLE_SPECIAL_TEXTURE[self.m_Vehicle:getModel()] or textureName ~= nil and textureName or "vehiclegrunge256"
	self.m_Tuning["Texture"][textureName] = texturePath
end

function VehicleTuning:getList()
	local tuning, specialTuning = {}, {}

	if self.m_Tuning["GTATuning"] then
		for _,v in pairs(self.m_Tuning["GTATuning"]) do
			tuning[getVehicleUpgradeSlotName(v)] = v
		end
	else
		tuning["(keine)"] = ""
	end
	if table.size(tuning) == 0 then tuning["(keine)"] = "" end

	local neon = self.m_Tuning["Neon"] == 1 and self.m_Tuning["NeonColor"] or nil
	local horn = (self.m_Tuning["CustomHorn"] and self.m_Tuning["CustomHorn"] > 0) and "Ja (ID: "..self.m_Tuning["CustomHorn"]..")" or nil
	local textureName = VEHICLE_SPECIAL_TEXTURE[self.m_Vehicle:getModel()] or textureName ~= nil and textureName or "vehiclegrunge256"
	local texture = self.m_Tuning["Texture"] and self.m_Tuning["Texture"][textureName] and self.m_Tuning["Texture"][textureName]:gsub("files/images/Textures", "")
	specialTuning["Neon"] = neon
	specialTuning["Spezial-Hupe"] = horn
	specialTuning["Textur"] = texture
	if table.size(specialTuning) == 0 then specialTuning["(keine)"] = "" end

	return tuning, specialTuning
end

--[[
	** EngineKit **
    	setAcceleration(acceleration)
]]--
function VehicleTuning:getEngine()
	return self.m_TuningKits["EngineKit"]
end

--[[
	** BrakeKit **
    	setBrake(strength)
    	setBias(bias)
]]--
function VehicleTuning:getBrake()
	return self.m_TuningKits["BrakeKit"]
end

--[[
	** SuspensionKit **
    	setSuspension( suspensionStretch)
    	setSuspensionBias(suspensionBias)
    	setDamping(damping)
    	setSteer(steer)
    	setSuspensionHeight(suspensionHeight)
]]--
function VehicleTuning:getSuspension()
	return self.m_TuningKits["SuspensionKit"]
end

--[[
	** WheelKit **
    	setTraction( traction)
		setTractionBias( tractionBias)
]]--
function VehicleTuning:getWheel()
	return self.m_TuningKits["WheelKit"]
end

function VehicleTuning:setPerformanceTuningTable( table, player, reset )
	local range, desc, min, max
	for property, value in pairs(table) do 
		range, desc, unit = unpack(VEHICLE_TUNINGKIT_DESCRIPTION[property])
		if not unit then
			if tonumber(value) and property ~= "driveType" then
				min, max = self:transformRange(range)
				value = max*(value/100) - min
				self:setTuningProperty(property, value)
			elseif property == "driveType" then
				self:setTuningProperty(property, value)
			end
		else 
			self:setTuningProperty(property, value)
		end
	end
	self:saveTuningKits()
	triggerClientEvent("vehiclePerformanceUpdateGUI", player, self.m_Vehicle, self.m_Vehicle:getHandling(), reset)
end

function VehicleTuning:transformRange(range)
	return math.abs(range[1]), math.abs(range[1])+range[2]
end

function VehicleTuning:setTuningProperty(property, value)
	if WheelTuning.Properties[property] then 
		if not self.m_TuningKits["WheelKit"] then 
			self:addTuningKit("WheelKit")
		end
	end
	if EngineTuning.Properties[property] then 
		if not self.m_TuningKits["EngineKit"] then 
			self:addTuningKit("EngineKit")
		end
	end
	if BrakeTuning.Properties[property] then 
		if not self.m_TuningKits["BrakeKit"] then 
			self:addTuningKit("BrakeKit")
		end
	end
	if SuspensionTuning.Properties[property] then 
		if not self.m_TuningKits["SuspensionKit"] then 
			self:addTuningKit("SuspensionKit")
		end
	end

	--//Wheel
	if property == "tractionMultiplier" then 
		self.m_TuningKits["WheelKit"]:setTraction(value)
	end
	if property == "tractionBias" then 
		self.m_TuningKits["WheelKit"]:setTractionBias(value)
	end
	if property == "tractionLoss" then 
		self.m_TuningKits["WheelKit"]:setTractionLoss(value)
	end

	--//Engine
	if property == "engineAcceleration" then 
		self.m_TuningKits["EngineKit"]:setAcceleration(value)
	end
	if property == "maxVelocity" then 
		self.m_TuningKits["EngineKit"]:setTopSpeed(value)
	end
	if property == "driveType" then 
		self.m_TuningKits["EngineKit"]:setType(value)
	end
	if property == "engineInertia" then 
		self.m_TuningKits["EngineKit"]:setInertia(value)
	end

	--//Suspension
	if property == "suspensionForceLevel" then 
		self.m_TuningKits["SuspensionKit"]:setSuspension(value)
	end
	if property == "steeringLock" then 
		self.m_TuningKits["SuspensionKit"]:setSteer(value)
	end
	if property == "suspensionDamping" then 
		self.m_TuningKits["SuspensionKit"]:setDamping(value)
	end
	if property == "suspensionLowerLimit" then 
		self.m_TuningKits["SuspensionKit"]:setSuspensionHeight(value)
	end
	if property == "suspensionFrontRearBias" then 
		self.m_TuningKits["SuspensionKit"]:setSuspensionBias(value)
	end

	--//Brake
	if property == "brakeDeceleration" then 
		self.m_TuningKits["BrakeKit"]:setBrake(value)
	end
	if property == "brakeBias" then 
		self.m_TuningKits["BrakeKit"]:setBias(value)
	end

end
