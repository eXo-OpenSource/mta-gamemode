Indicator = inherit(Singleton)

function Indicator:constructor()
	self.m_Data = self:loadData()

	self.m_AllowedVehicles = {}

	self.ms_Size = 0.24                     -- Size for the corona markers
	self.ms_Color = { 255, 100, 10, 255 }   -- Color in R G B A format
	self.ms_FadeTime = 160                   -- Miliseconds to fade out the indicators
	self.ms_SwitchTimes = { 300, 400 }     -- In miliseconds. First is time to switch them off, second to switch them on.
	self.ms_SwitchOffThreshold = 62   -- A value in degrees ranging (0, 90) preferibly far from the limits.
	self.m_RenderBind = bind(self.render, self)
	self.m_KeyBind = bind(self.vehicleSteering, self)
	self.m_TurnOffThreshold = 700 --ms

	self.ms_SwitchOffThreshold = self.ms_SwitchOffThreshold / 90

	self.m_Enabled = false
	self:toggle()

	self:checkVehicles()
	self:addEvents()

	addCommandHandler('indicator_left', function () self:switchIndicatorState('left') end, false)
	addCommandHandler('indicator_right', function () self:switchIndicatorState('right') end, false)
	bindKey("vehicle_left", "both", self.m_KeyBind)
	bindKey("vehicle_right", "both", self.m_KeyBind)
end

function Indicator:loadData()
	local file = fileOpen("files/data/indicators.dat", true)
    local data = fileRead(file, fileGetSize(file))
	local toReturn = fromJSON(data)
	fileClose(file)

	return toReturn
end

function Indicator:checkVehicles()
    -- Check all streamed in vehicles that have any indicator activated and create a state for them.
    local vehicles = getElementsByType ( 'vehicle' )
    for k, vehicle in ipairs(vehicles) do
        if isElementStreamedIn ( vehicle ) then
            local indicatorLeft = getElementData ( vehicle, 'i:left' )
            local indicatorRight = getElementData ( vehicle, 'i:right' )
            if indicatorLeft or indicatorRight then
                self:performIndicatorChecks ( vehicle )
            end
        end
    end
end

function Indicator:vectorLength ( vector )
    return math.sqrt ( vector[1]*vector[1] + vector[2]*vector[2] + vector[3]*vector[3] )
end

--[[
* normalizeVector
Normalizes a vector, when possible, and returns the normalized vector plus the length.
--]]
function Indicator:normalizeVector ( vector )
    local length = self:vectorLength ( vector )
    if length > 0 then
        local normalizedVector = {}
        normalizedVector[1] = vector[1] / length
        normalizedVector[2] = vector[2] / length
        normalizedVector[3] = vector[3] / length
        return normalizedVector, length
    else
        return nil, length
    end
end

--[[
* crossProduct
Calculates the cross product of two vectors.
--]]
function Indicator:crossProduct ( v, w )
    local result = {}
    result[1] = v[2]*w[3] - v[3]*w[2]
    result[2] = w[1]*v[3] - w[3]*v[1]
    result[3] = v[1]*w[2] - v[2]*w[1]
    return result
end

--[[
* getFakeVelocity
Gets a fake unitary velocity for a vehicle calculated using the current vehicle angle.
--]]
function Indicator:getFakeVelocity ( vehicle )
    -- Get the angle around the Z axis
    local _, _, angle = getElementRotation ( vehicle )
    local velocity = { 0, 0, 0 }
    velocity[1] = -math.sin ( angle )
    velocity[2] = math.cos ( angle )
    return velocity
end

--[[
* createIndicator
Creates a marker for an indicator.
--]]
function Indicator:createIndicator ()
    local x, y, z = getElementPosition(localPlayer)
    local indicator = createMarker (    x, y, z+4, 'corona',
                                        self.ms_Size,
                                        self.ms_Color[1],
                                        self.ms_Color[2],
                                        self.ms_Color[3],
                                        0
                                    )
    setElementStreamable ( indicator, false )
    return indicator
end

--[[
* createIndicatorState
Creates a table with information about the indicators state.
--]]
function Indicator:createIndicatorState ( vehicle, indicatorLeft, indicatorRight )
    local t = { vehicle       = vehicle,        -- The vehicle that this state refers to
                left          = indicatorLeft,  -- The state of the left indicator
                right         = indicatorRight, -- The state of the right indicator
                coronaLeft    = nil,            -- The corona elements for the left indicator
                coronaRight   = nil,            -- The corona elements for the right indicator
                nextChange    = 0,              -- The time for the next change of the indicators
                timeElapsed   = 0,              -- Elapsed time since the last change
                currentState  = false,          -- If set to true, the coronas are activated.
                activationDir = nil,            -- Direction that the vehicle was following when the indicator got activated, for auto shut down.
              }
    return t
end

--[[
* updateIndicatorState
Updates the indicator state (i.e. creates/destroys the coronas).
--]]
function Indicator:updateIndicatorState ( state )
    if not state then return end

    -- Store the number of indicators activated
    local numberOfIndicators = 0

    -- Get the vehicle bounding box
   -- local xmin, ymin, zmin, xmax, ymax, zmax = getElementBoundingBox ( state.vehicle )

    -- Transform the bounding box positions to fit properly the vehicle

	local model = tostring(getElementModel(state.vehicle))
	if not self.m_Data[model] then
		outputDebugString("Blinkersystem: self.m_Data für Model "..model.." - "..getVehicleNameFromModel(model).." nicht gefunden!")
		return
	end

    -- Check the left indicator
    if state.left then
        if not state.coronaLeft then
            state.coronaLeft = { self:createIndicator (), self:createIndicator () }
            attachElements ( state.coronaLeft[1], state.vehicle, self.m_Data[model]["VL"]["x"],  self.m_Data[model]["VL"]["y"], self.m_Data[model]["VL"]["z"] )
            attachElements ( state.coronaLeft[2], state.vehicle, self.m_Data[model]["HL"]["x"],  self.m_Data[model]["HL"]["y"], self.m_Data[model]["HL"]["z"] )
        end
        numberOfIndicators = numberOfIndicators + 1
    elseif state.coronaLeft then
        destroyElement ( state.coronaLeft[1] )
        destroyElement ( state.coronaLeft[2] )
        state.coronaLeft = nil
    end

    -- Check the right indicator
    if state.right then
        if not state.coronaRight then
            state.coronaRight = { self:createIndicator (), self:createIndicator () }
            attachElements ( state.coronaRight[1], state.vehicle, self.m_Data[model]["VR"]["x"],  self.m_Data[model]["VR"]["y"], self.m_Data[model]["VR"]["z"] )
            attachElements ( state.coronaRight[2], state.vehicle, self.m_Data[model]["HR"]["x"],  self.m_Data[model]["HR"]["y"], self.m_Data[model]["HR"]["z"] )
        end
        numberOfIndicators = numberOfIndicators + 1
    elseif state.coronaRight then
        destroyElement ( state.coronaRight[1] )
        destroyElement ( state.coronaRight[2] )
        state.coronaRight = nil
    end

    -- Check if this is the car that you are driving and that there is one and only one indicator
    -- to enable auto switching off
    if numberOfIndicators == 1 and getVehicleOccupant ( state.vehicle, 0 ) == localPlayer then
        -- Store the current velocity, normalized, to check when will we have to switch it off.
        state.activationDir = self:normalizeVector ( { getElementVelocity ( state.vehicle ) } )
        if not state.activationDir then
            -- The vehicle is stopped, get a fake velocity from the angle.
            state.activationDir = self:getFakeVelocity ( state.vehicle )
        end
    else
        state.activationDir = nil
    end
end

--[[
* destroyIndicatorState
Destroys an indicator state, deleting all its resources.
--]]
function Indicator:destroyIndicatorState ( state )
    if not state then return end

    -- Destroy the left coronas
    if state.coronaLeft then
        destroyElement ( state.coronaLeft[1] )
        destroyElement ( state.coronaLeft[2] )
        state.coronaLeft = nil
    end

    -- Destroy the right coronas
    if state.coronaRight then
        destroyElement ( state.coronaRight[1] )
        destroyElement ( state.coronaRight[2] )
        state.coronaRight = nil
    end

    -- If I am the driver, reset the element data.
    if getVehicleOccupant ( state.vehicle ) == localPlayer then
        setElementData ( state.vehicle, 'i:left', false, true )
        setElementData ( state.vehicle, 'i:right', false, true )
		 setElementData ( state.vehicle, 'i:warn', false, true )
		HUDSpeedo:getSingleton():setIndicatorAlpha("left", 0)
		HUDSpeedo:getSingleton():setIndicatorAlpha("right", 0)
    end
end

--[[
* performIndicatorChecks
Checks how the indicators state should be: created, updated or destroyed.
--]]
function Indicator:performIndicatorChecks(vehicle)
	if VEHICLE_BIKES[vehicle:getModel()] then return end

    -- Get the current indicator states
    local indicatorLeft = getElementData(vehicle, 'i:left')
    local indicatorRight = getElementData(vehicle, 'i:right')

    -- Check if we at least have one indicator running
    local anyIndicator = indicatorLeft or indicatorRight

    -- Grab the current indicators state in the flashing period.
    local currentState = self.m_AllowedVehicles [ vehicle ]

    -- If there's any indicator running, push it to the list of vehicles to draw the indicator.
    -- Else, remove it from the list.
    if anyIndicator then
        -- Check if there is already a state for this vehicle
        if currentState then
            -- Update the state
            currentState.left = indicatorLeft
            currentState.right = indicatorRight
        else
            -- Create a new state
            currentState = self:createIndicatorState ( vehicle, indicatorLeft, indicatorRight )
            self.m_AllowedVehicles [ vehicle ] = currentState
        end
        self:updateIndicatorState ( currentState )
    elseif currentState then
        -- Destroy the current state
        self:destroyIndicatorState ( currentState )
        self.m_AllowedVehicles [ vehicle ] = nil
    end
end

--[[
* setIndicatorsAlpha
Sets all the active indicators alpha.
--]]

function Indicator:setIndicatorsAlpha ( state, alpha, updateSpeedo )
    if state.coronaLeft then
        setMarkerColor ( state.coronaLeft[1],   self.ms_Color[1],
                                                self.ms_Color[2],
                                                self.ms_Color[3],
                                                alpha )
        setMarkerColor ( state.coronaLeft[2],   self.ms_Color[1],
                                                self.ms_Color[2],
                                                self.ms_Color[3],
                                                alpha )
		if updateSpeedo then HUDSpeedo:getSingleton():setIndicatorAlpha("left", alpha) end
    end
    if state.coronaRight then
        setMarkerColor ( state.coronaRight[1],  self.ms_Color[1],
                                                self.ms_Color[2],
                                                self.ms_Color[3],
                                                alpha )
        setMarkerColor ( state.coronaRight[2],  self.ms_Color[1],
                                                self.ms_Color[2],
                                                self.ms_Color[3],
                                                alpha )
		if updateSpeedo then HUDSpeedo:getSingleton():setIndicatorAlpha("right", alpha) end
    end
end

--[[
* processIndicators
Processes the indicators switching, and solves some MTA bugs.
--]]
function Indicator:processIndicators ( state )
    -- Check first if the vehicle is blown up.
    if getElementHealth ( state.vehicle ) == 0 then
        -- Destroy the state.
        self:destroyIndicatorState ( state )
        self.m_AllowedVehicles [ state.vehicle ] = nil
        return
    end

    -- Check if we must automatically deactivate the indicators.
    --[[if state.activationDir then
        -- Get the current velocity and normalize it
        local currentVelocity = self:normalizeVector ( { getElementVelocity ( state.vehicle ) } )

        -- If the vehicle is stopped, calculate a fake velocity from the angle.
        if not currentVelocity then
            currentVelocity = self:getFakeVelocity ( state.vehicle )
        end

        -- Calculate the cross product between the velocities to get the angle and direction of any turn.
        local cross = self:crossProduct ( state.activationDir, currentVelocity )

        -- Get the length of the resulting vector to calculate the "amount" of direction change [0..1].
        local length = self:vectorLength ( cross )

		outputChatBox(("%s > %s"):format(length, self.ms_SwitchOffThreshold))
        -- If the turn is over the threshold, deactivate the indicators
        if length > self.ms_SwitchOffThreshold then
            -- Destroy the state
            self:destroyIndicatorState ( state )
            self.m_AllowedVehicles [ state.vehicle ] = nil
            return
        end
    end]]

    -- Get the vehicle that we are in
    local playerVehicle = getPedOccupiedVehicle ( localPlayer )

    -- Check if we must switch the state
    if state.nextChange <= state.timeElapsed then
        -- Turn to switched on indicators, in both cases. When turning on,
        -- it goes straight to the full alpha mode. When turning off, it
        -- fades out from full alpha to full transparent.

        self:setIndicatorsAlpha ( state, self.ms_Color[4], playerVehicle == state.vehicle )

        -- Switch the state
        state.currentState = not state.currentState

        -- Restart the timers and play a sound if we are in that vehicle
        state.timeElapsed = 0
        if state.currentState then
            state.nextChange = self.ms_SwitchTimes[1]
            if playerVehicle == state.vehicle then playSoundFrontEnd ( 37 ) end
        else
            state.nextChange = self.ms_SwitchTimes[2]
            if playerVehicle == state.vehicle then playSoundFrontEnd ( 38 ) end
        end


    -- Check if we are turning them off
    elseif state.currentState == false then
        -- If the time elapsed is bigger than the time to fade out, then
        -- just set the alpha to zero. Else, set it to the current alpha
        -- value.
        if state.timeElapsed >= self.ms_FadeTime then
            self:setIndicatorsAlpha ( state, 0, playerVehicle == state.vehicle)
        else
            self:setIndicatorsAlpha ( state, (1 - (state.timeElapsed / self.ms_FadeTime)) * self.ms_Color[4], playerVehicle == state.vehicle)
        end
    end
end

--[[
* indicator_left and indicator_right commands
Changes the state of the indicators for the current vehicle.
--]]
function Indicator:switchIndicatorState ( indicator )
    -- First check that we are in a vehicle.
	local v = localPlayer.vehicle
    if v then
        -- check for the correct vehicle type
        if v:getVehicleType() == VehicleType.Automobile then
            -- Check that we are the vehicle driver
            if getVehicleOccupant(v, 0) == localPlayer then
                -- Switch the indicator state
                if self.m_Enabled == true then
					if indicator ~= "warn" and getElementData(v, "i:warn") then return end
					if indicator == "warn" then
						if not getElementData(v, "i:warn") then
							setElementData(v, "i:left", true)
							setElementData(v, "i:right", true)
							setElementData(v, "i:warn", true)
						else
							setElementData(v, "i:left", false)
							setElementData(v, "i:right", false)
							setElementData(v, "i:warn", false)
						end
					elseif indicator == "left" then
						if getElementData(v, "i:left") then
							setElementData(v, "i:left", false)
						else
							setElementData(v, "i:left", true)
							setElementData(v, "i:right", false)
						end
					elseif indicator == "right" then
						if getElementData(v, "i:right") then
							setElementData(v, "i:right", false)
						else
							setElementData(v, "i:right", true)
							setElementData(v, "i:left", false)
						end
					end
				else
					outputChatBox("Du hast die Blinker deaktiviert! Aktiviere die Blinker im F2 Menü!",255,0,0)
				end
            end
        end
    end
end

function Indicator:render(timeSlice)
    -- Process every vehicle with indicators
    for vehicle, state in pairs(self.m_AllowedVehicles) do
        state.timeElapsed = state.timeElapsed + timeSlice
        self:processIndicators ( state, state.lastChange )
    end
end

function Indicator:vehicleSteering(key, state)
	if not localPlayer.vehicle then return end
	if getElementData(localPlayer.vehicle, "i:warn") then return end

	if state == "down" then
		self.m_VehicleLeft = key == "vehicle_left" and getTickCount() or self.m_VehicleLeft
		self.m_VehicleRight = key == "vehicle_right" and getTickCount() or self.m_VehicleRight
	elseif state == "up" and key == "vehicle_left" and getElementData(localPlayer.vehicle, "i:left") then
		if getTickCount() - self.m_VehicleLeft > self.m_TurnOffThreshold then
			self:switchIndicatorState("left")
		end
	elseif state == "up" and key == "vehicle_right" and getElementData(localPlayer.vehicle, "i:right") then
		if getTickCount() - self.m_VehicleRight > self.m_TurnOffThreshold then
			self:switchIndicatorState("right")
		end
	end
end

function Indicator:toggle()
	self.m_Enabled = core:get("Vehicles", "Indicators", true)
	if self.m_Enabled == true then
		addEventHandler('onClientPreRender', root, self.m_RenderBind)
	else
		removeEventHandler('onClientPreRender', root, self.m_RenderBind)
	end
end

function Indicator:addEvents()
	--[[
	* onClientVehicleRespawn
	Restore the state for vehicles respawning.
	--]]
	addEventHandler('onClientVehicleRespawn', root, function ()
		if isElementStreamedIn ( source ) then
			self:performIndicatorChecks ( source )
		end
	end)

	--[[
	* onClientElementDestroy
	Destroys the state for a vehicle when it's deleted.
	--]]
	addEventHandler('onClientElementDestroy', root, function ()
		if getElementType ( source ) == 'vehicle' then
			local currentState = self.m_AllowedVehicles [ source ]
			if currentState then
				-- Destroy the state
				self:destroyIndicatorState ( currentState )
				self.m_AllowedVehicles [ source ] = nil
			end
		end
	end)

		--[[
	* onClientElementDataChange
	Detects when the indicator state of a vehicle changes.
	--]]
	addEventHandler('onClientElementDataChange', root, function ( dataName, oldValue )
		-- Check that the source is a vehicle and that the data name is what we are looking for.
		if getElementType(source) == 'vehicle' and ( dataName == 'i:left' or dataName == 'i:right' ) then
			-- If the vehicle is not streamed in, don't do anything.
			if isElementStreamedIn(source) then
				-- Perform the indicator checks for the new indicator states.
				self:performIndicatorChecks ( source )
			end
		end
	end)

	--[[
	* onClientElementStreamIn
	Detects when a vehicle streams in, to check if we must draw the indicators.
	--]]
	addEventHandler('onClientElementStreamIn', root, function ()
		if getElementType(source) == 'vehicle' then
			-- Perform the indicator checks for the just streamed in vehicle.
			self:performIndicatorChecks ( source )
		end
	end)

	--[[
	* onClientElementStreamOut
	Detects when a vehicle streams out, to destroy its state.
	--]]
	addEventHandler('onClientElementStreamOut', root, function ()
		if getElementType(source) == 'vehicle' then
			-- Grab the current indicators state
			local currentState = self.m_AllowedVehicles [ source ]

			-- If it has a state, remove it.
			if currentState then
				self:destroyIndicatorState(currentState)
				self.m_AllowedVehicles [ source ] = nil
			end
		end
	end)

end
