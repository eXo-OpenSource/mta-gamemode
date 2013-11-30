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
	GUIForm.constructor(self, screenWidth/2-450/2, 0, 450, 175)

	self.m_CurrentStation = 0
	showPlayerHudComponent("radio", false)
	setRadioChannel(0)
	addEventHandler("onClientPlayerRadioSwitch", root, cancelEvent)
	
	local x, y = 1600, 900
	self.m_Hintergrund = GUIImage:new(screenWidth*(575/x), screenHeight*(725/y), screenWidth*(450/x), screenHeight*(175/y), "files/images/Radio/radio_bg.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), false)
	self.m_Last = GUIImage:new(screenWidth*(585/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_back.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	self.m_Next = GUIImage:new(screenWidth*(965/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_next.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	self.m_VolumeUp = GUIImage:new(screenWidth*(645/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_normal.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	self.m_VolumeDown = GUIImage:new(screenWidth*(909/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_down.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	self.m_ToggleSound = GUIImage:new(screenWidth*(743/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_play.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	--self.m_StopSound = GUIImage:new(screenWidth*(803/x), screenHeight*(836/y), screenWidth*(50/x), screenHeight*(50/y), "files/images/Radio/sound_stop.png")--, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	self.m_Radioname = GUILabel:new(screenWidth*(601/x), screenHeight*(772/y), screenWidth*(398/x), screenHeight*(38/y), "", 1)
		:setFont(VRPFont(screenHeight*0.03))
		:setAlign("center", "center")
	
	-- Add click events
	self.m_Last.onLeftClick = function() self:previousStation() end
	self.m_Next.onLeftClick = function() self:nextStation() end
	self.m_VolumeUp.onLeftClick = function() if self:getVolume() < 1.0 then self:setVolume(self:getVolume() + 0.1) end end
	self.m_VolumeDown.onLeftClick = function() outputDebug(self:getVolume()) if self:getVolume() >= 0.0 then self:setVolume(self:getVolume() - 0.1) end end
	self.m_ToggleSound.onLeftClick = function() self:toggle() end
	
	-- First of all, set radio off
	self:setRadioStation(0)
	
	-- Bind controls
	bindKey("radio_next", "down", function() self:nextStation() end)
	bindKey("radio_previous", "down", function() self:previousStation() end)
end

function RadioGUI:destructor()
	self:stopSound()
end

function RadioGUI:setRadioStation(station)
	assert(VRP_RADIO[station] or station == 0, "Bad argument @ RadioGUI.setRadioStation")
	outputDebug(station)
	
	self.m_CurrentStation = station

	if self.m_CurrentStation == 0 then
		if self.m_Sound and isElement(self.m_Sound) then
			stopSound(self.m_Sound)
			self.m_Sound = nil
		end
		self.m_Radioname:setText(_"Radio off")
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
	else
		self.m_Radioname:setText(_("Unable to play the radio stream. Please try again later."))
	end
	
	return true
end

function RadioGUI:setVolume(volume)
	assert(type(volume) == "number", "Bad argument @ RadioGUI.setVolume (Volume is not a number)")
	assert(volume >= 0 and volume <= 1, "Bad argument @ RadioGUI.setVolume (Volume is out of range, range 0-1)")
	
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
		self:stopSound()
	else
		self:setRadioStation(self.m_CurrentStation)
	end
end

function RadioGUI:stopSound()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
		self.m_Sound = nil
	end
end

addCommandHandler("testr",
	function()
		local radio = RadioGUI:new()
		radio:setVolume(0.5)
		--radio:nextStation()
		
		localPlayer:sendMessage("Lautstaerke: "..radio:getVolume())
	end
)
