-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RadioGUI.lua
-- *  PURPOSE:     Radio UI class
-- *
-- ****************************************************************************
RadioGUI = inherit(GUIForm)
inherit(Singleton, RadioGUI)

function RadioGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.28)/2 / ASPECT_RATIO_MULTIPLIER, 0, screenWidth*0.28 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.19, false, true)

	self.m_CurrentStation = 0
	self.m_ControlEnabled = true
	self.m_Volume = 1

	setPlayerHudComponentVisible("radio", false)
	setRadioChannel(0)
	addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)

	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Radio/radio_bg.png", self)
	self.m_Last = GUIImage:new(self.m_Width*0.02, self.m_Height*0.10, self.m_Width*0.11, self.m_Height*0.29, "files/images/Radio/sound_back.png", self.m_Background)
	self.m_Next = GUIImage:new(self.m_Width*0.87, self.m_Height*0.10, self.m_Width*0.11, self.m_Height*0.29, "files/images/Radio/sound_next.png", self.m_Background)
	self.m_VolumeUp = GUIImage:new(self.m_Width*0.76, self.m_Height*0.24, self.m_Width*0.09, self.m_Height*0.23, "files/images/Radio/sound_normal.png", self.m_Background)
	self.m_VolumeDown = GUIImage:new(self.m_Width*0.16, self.m_Height*0.24, self.m_Width*0.09, self.m_Height*0.23, "files/images/Radio/sound_down.png", self.m_Background)
	self.m_ToggleSound = GUIImage:new(self.m_Width*0.44, self.m_Height*0.06, self.m_Width*0.12, self.m_Height*0.31, "files/images/Radio/sound_stop.png", self.m_Background)
	self.m_Radioname = GUILabel:new(self.m_Width*0.06, self.m_Height*0.53, self.m_Width*0.88, self.m_Height*0.20, "", self.m_Background):setFont(VRPFont(self.m_Height*0.2, Fonts.Rage)):setAlign("center", "center")

	-- Add click events
	self.m_Last.onLeftClick = function() self:previousStation() end
	self.m_Next.onLeftClick = function() self:nextStation() end
	self.m_VolumeUp.onLeftClick = function() self:setVolume((self:getVolume() or 0) + 0.1) end
	self.m_VolumeDown.onLeftClick = function() self:setVolume((self:getVolume() or 0.1) - 0.1) end
	self.m_ToggleSound.onLeftClick = function() self:toggle() end

	self.m_OnVehicleDestroyOrExplodeBind = bind(self.onVehicleDestroyOrExplode, self)

	-- First of all, set radio off
	self:setRadioStation(0)
	if not isPedInVehicle(localPlayer) then
		self:close()
	end

	-- Bind controls
	bindKey("radio_next", "down", function() self:nextStation() end)
	bindKey("radio_previous", "down", function() self:previousStation() end)

	addEventHandler("onClientPlayerVehicleEnter", localPlayer,
		function(veh)
			self:setRadioStation(self.m_CurrentStation)
			addEventHandler("onClientElementDestroy", veh, self.m_OnVehicleDestroyOrExplodeBind, false)
			addEventHandler("onClientVehicleExplode", veh, self.m_OnVehicleDestroyOrExplodeBind)
		end
	)
	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(veh)
			self:setVisible(false)
			self:stopSound()
			removeEventHandler("onClientElementDestroy", veh, self.m_OnVehicleDestroyOrExplodeBind)
			removeEventHandler("onClientVehicleExplode", veh, self.m_OnVehicleDestroyOrExplodeBind)
		end
	)


	self:close()
end

function RadioGUI:virtual_destructor()
	self:stopSound()
end

function RadioGUI:onVehicleDestroyOrExplode()
	if source and source.getType and source:getType() == "vehicle" then
		if table.find(getVehicleOccupants(source), localPlayer) then
			self:setVisible(false)
			self:stopSound()
		end
	end
end

function RadioGUI:setRadioStation(station)
	local stations = RadioStationManager:getSingleton():getStations()
	assert(stations[station] or station == 0, "Bad argument @ RadioGUI.setRadioStation")

	self.m_CurrentStation = station

	if self.m_CurrentStation == 0 then
		removeEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		setRadioChannel(0)
		addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		if self.m_Sound and isElement(self.m_Sound) then
			stopSound(self.m_Sound)
			self.m_Sound = nil
		end
		self.m_Radioname:setText(_"Radio off")
		self.m_ToggleSound:setImage("files/images/Radio/sound_play.png")
		return true
	end

	if self.m_Sound and isElement(self.m_Sound) then
		stopSound(self.m_Sound)
		self.m_Sound = nil
	end

	local radioName, radioUrl = unpack(stations[self.m_CurrentStation])
	if type(radioUrl) == "string" then
		removeEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		setRadioChannel(0)
		addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		self.m_Sound = playSound(radioUrl)
		if self.m_Sound then
			self.m_Radioname:setText(radioName)
			self.m_ToggleSound:setImage("files/images/Radio/sound_stop.png")
		else
			self.m_Radioname:setText(_("Unable to play the radio stream. Please try again later."))
		end
	else
		removeEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		setRadioChannel(radioUrl)
		addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
		self.m_Radioname:setText("[GTA] "..radioName)
		self.m_ToggleSound:setImage("files/images/Radio/sound_stop.png")
	end

	return true
end

function RadioGUI:setVolume(volume)
	assert(type(volume) == "number", "Bad argument @ RadioGUI.setVolume (Volume is not a number)")
	if volume < 0.1 then
		volume = 0
	end

	if volume > 0.9 then
		volume = 1
	end

	self.m_Volume = volume

	if self.m_Sound then
		setSoundVolume(self.m_Sound, self.m_Volume)
	end
end

function RadioGUI:getVolume()
	if self.m_Sound then
		return getSoundVolume(self.m_Sound)
	end
	return self.m_Volume
end

function RadioGUI:nextStation()
	-- Don't do anything if the controls have been disabled
	if not self.m_ControlEnabled then
		return
	end

	if isTimer(self.m_FadeOutTimer) then killTimer(self.m_FadeOutTimer) end

	self.m_CurrentStation = self.m_CurrentStation + 1
	if self.m_CurrentStation > #RadioStationManager:getSingleton():getStations() then
		self.m_CurrentStation = 0
	end
	self:setRadioStation(self.m_CurrentStation)

	if not self:isVisible() then
		self:fadeIn(1000)
	end
	self.m_FadeOutTimer = setTimer(function() self:fadeOut(1000) end, 5000, 1)
end

function RadioGUI:previousStation()
	-- Don't do anything if the controls have been disabled
	if not self.m_ControlEnabled then
		return
	end

	if isTimer(self.m_FadeOutTimer) then
		killTimer(self.m_FadeOutTimer)
	end

	self.m_CurrentStation = self.m_CurrentStation - 1
	if self.m_CurrentStation < 0 then
		self.m_CurrentStation = #RadioStationManager:getSingleton():getStations()
	end
	self:setRadioStation(self.m_CurrentStation)

	if not self:isVisible() then
		self:fadeIn(1000)
	end
	self.m_FadeOutTimer = setTimer(function() self:fadeOut(1000) end, 5000, 1)
end

function RadioGUI:getStation()
	-- Returns: ID von der Station, Name der Station, URL der Station
	return self.m_CurrentStation, RadioStationManager:getSingleton():getStations()[self.m_CurrentStation][1], RadioStationManager:getSingleton():getStations()[self.m_CurrentStation][2]
end

function RadioGUI:toggle()
	if self.m_Sound then
		self:setRadioStation(0)
		self.m_ToggleSound:setImage("files/images/Radio/sound_play.png")
	else
		self:setRadioStation(1)
		self.m_ToggleSound:setImage("files/images/Radio/sound_stop.png")
	end
end

function RadioGUI:stopSound()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
		self.m_Sound = nil
	end
end

function RadioGUI:setControlEnabled(controlEnabled)
	self.m_ControlEnabled = controlEnabled
end
