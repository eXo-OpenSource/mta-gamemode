-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RadioGUI.lua
-- *  PURPOSE:     Radio UI class
-- *
-- ****************************************************************************
RadioGUI = inherit(Singleton)
inherit(GUIForm, RadioGUI)

VRP_RADIO = {
	{"Di.fm Dubstep", "http://80.94.69.106:6374/"},
	{"Di.fm Electro House", "http://scfire-ntc-aa02.stream.aol.com:80/stream/1025"},
	{"RMF Dance", "http://files.kusmierz.be/rmf/rmfdance-3.mp3"},
	{"Sky.fm Alternative", "http://u12.sky.fm:80/sky_altrock_aacplus"},
	{"Sky.fm Roots Reggae", "http://u16b.sky.fm:80/sky_rootsreggae_aacplus"},
	{"Sky.fm Classic Rap", "http://u17.sky.fm:80/sky_classicrap_aacplus"},
	{"Sky.fm Top Hits", "http://u12b.sky.fm:80/sky_tophits_aacplus"},
	{"89.0 RTL", "http://80.237.156.45/890rtl-128.mp3"},
	{"Technobase.fm", "http://listen.technobase.fm/dsl.asx"},
	{"N-Joy", "http://ndrstream.ic.llnwd.net/stream/ndrstream_n-joy_hi_mp3.m3u"},
	{"Hardbase.fm", "http://listen.hardbase.fm/tunein-dsl-asx"},
	{"Housetime.fm", "http://listen.housetime.fm/tunein-dsl-asx"},
	{"Techno4Ever", "http://www.techno4ever.net/t4e/stream/dsl_listen.asx"},
	{"ClubTime.fm", "http://listen.ClubTime.fm/dsl.pls"},
	{"CoreTime.fm", "http://listen.CoreTime.fm/dsl.pls"}
}

function RadioGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.28)/2 / ASPECT_RATIO_MULTIPLIER, 0, screenWidth*0.28 / ASPECT_RATIO_MULTIPLIER, screenHeight*0.19)

	self.m_CurrentStation = 0
	showPlayerHudComponent("radio", false)
	setRadioChannel(0)
	addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
	
	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Radio/radio_bg.png", self)
	self.m_Last = GUIImage:new(self.m_Width*0.02, self.m_Height*0.10, self.m_Width*0.11, self.m_Height*0.29, "files/images/Radio/sound_back.png", self.m_Background)
	self.m_Next = GUIImage:new(self.m_Width*0.87, self.m_Height*0.10, self.m_Width*0.11, self.m_Height*0.29, "files/images/Radio/sound_next.png", self.m_Background)
	self.m_VolumeUp = GUIImage:new(self.m_Width*0.76, self.m_Height*0.24, self.m_Width*0.09, self.m_Height*0.23, "files/images/Radio/sound_normal.png", self.m_Background)
	self.m_VolumeDown = GUIImage:new(self.m_Width*0.16, self.m_Height*0.24, self.m_Width*0.09, self.m_Height*0.23, "files/images/Radio/sound_down.png", self.m_Background)
	self.m_ToggleSound = GUIImage:new(self.m_Width*0.44, self.m_Height*0.06, self.m_Width*0.12, self.m_Height*0.31, "files/images/Radio/sound_stop.png", self.m_Background)
	self.m_Radioname = GUILabel:new(self.m_Width*0.06, self.m_Height*0.53, self.m_Width*0.88, self.m_Height*0.20, "", 1, self.m_Background)
		:setFont(VRPFont(self.m_Height*0.2))
		:setAlign("center", "center")
	
	-- Add click events
	self.m_Last.onLeftClick = function() self:previousStation() end
	self.m_Next.onLeftClick = function() self:nextStation() end
	self.m_VolumeUp.onLeftClick = function() self:setVolume(self:getVolume() + 0.1) end
	self.m_VolumeDown.onLeftClick = function() self:setVolume(self:getVolume() - 0.1) end
	self.m_ToggleSound.onLeftClick = function() self:toggle() end
	
	-- First of all, set radio off
	self:setRadioStation(0)
	if not isPedInVehicle(localPlayer) then
		self:setVisible(false)
	end
	
	-- Bind controls
	bindKey("radio_next", "down", function() self:nextStation() end)
	bindKey("radio_previous", "down", function() self:previousStation() end)
	
	addEventHandler("onClientPlayerVehicleEnter", localPlayer,
		function()
			self:setVisible(true)
			self:setRadioStation(self.m_CurrentStation)
		end
	)
	addEventHandler("onClientPlayerVehicleExit", localPlayer, 
		function()
			self:setVisible(false)
			self:stopSound()
		end
	)
	addEventHandler("onClientVehicleExplode", root,
		function()
			if table.find(getVehicleOccupants(source), localPlayer) then
				self:setVisible(false)
				self:stopSound()
			end
		end
	)
end

function RadioGUI:destructor()
	GUIForm.destructor(self)
	self:stopSound()
end

function RadioGUI:setRadioStation(station)
	assert(VRP_RADIO[station] or station == 0, "Bad argument @ RadioGUI.setRadioStation")
	
	self.m_CurrentStation = station

	if self.m_CurrentStation == 0 then
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
	
	local radioName, radioUrl = unpack(VRP_RADIO[self.m_CurrentStation])

	self.m_Sound = playSound(radioUrl)
	if self.m_Sound then
		self.m_Radioname:setText(radioName)
		self.m_ToggleSound:setImage("files/images/Radio/sound_stop.png")
	else
		self.m_Radioname:setText(_("Unable to play the radio stream. Please try again later."))
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
	self.m_CurrentStation = self.m_CurrentStation + 1
	if self.m_CurrentStation > #VRP_RADIO then
		self.m_CurrentStation = 0
	end
	self:setRadioStation(self.m_CurrentStation)
end

function RadioGUI:previousStation()
	self.m_CurrentStation = self.m_CurrentStation - 1
	if self.m_CurrentStation < 0 then
		self.m_CurrentStation = #VRP_RADIO
	end
	self:setRadioStation(self.m_CurrentStation)
end

function RadioGUI:getStation()
	-- Returns: ID von der Station, Name der Station, URL der Station
	return self.m_CurrentStation, VRP_RADIO[self.m_CurrentStation][1], VRP_RADIO[self.m_CurrentStation][2]
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
