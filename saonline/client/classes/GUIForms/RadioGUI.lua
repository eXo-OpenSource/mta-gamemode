RadioGUI = inherit(Singleton)
inherit(GUIForm, RadioGUI)

local textRadio = ""
local currentRadio = ""
local currentIndex = 1
local localPlayer = getLocalPlayer()
local sx,sy = guiGetScreenSize ()
local loltimer = nil
local templol = false
volume = 0.5

curRadioName = "KEINS"

local car_radio_plays = {}

local playRadioThing = nil

VRP_RADIO = {"Radio aus",
	"Di.fm Dubstep",
	"Di.fm Electro House",
	"RMF Dance",
	"Sky.fm Alternative",
	"Sky.fm Roots Reggae",
	"Sky.fm Classic Rap",
	"Sky.fm Top Hits",
	"89.0 RTL",
	"Technobase.fm",
	"N-Joy",
	"Hardbase.fm",
	"Housetime.fm",
	"Techno4Ever",
	"ClubTime.fm",
	"CoreTime.fm",
}

VRP_RADIO_PATHS = {0,--1,2,3,4,5,6,7,8,9,10,11,12,
	"http://80.94.69.106:6374/",
	"http://scfire-ntc-aa02.stream.aol.com:80/stream/1025",
	"http://files.kusmierz.be/rmf/rmfdance-3.mp3",
	"http://u12.sky.fm:80/sky_altrock_aacplus",
	"http://u16b.sky.fm:80/sky_rootsreggae_aacplus",
	"http://u17.sky.fm:80/sky_classicrap_aacplus",
	"http://u12b.sky.fm:80/sky_tophits_aacplus",
	"http://80.237.156.45/890rtl-128.mp3",
	"http://listen.technobase.fm/dsl.asx",
	"http://ndrstream.ic.llnwd.net/stream/ndrstream_n-joy_hi_mp3.m3u",
	"http://listen.hardbase.fm/tunein-dsl-asx",
	"http://listen.housetime.fm/tunein-dsl-asx",
	"http://www.techno4ever.net/t4e/stream/dsl_listen.asx",
	"http://listen.ClubTime.fm/dsl.pls",
	"http://listen.CoreTime.fm/dsl.pls"
}

addEventHandler("onClientResourceStart",root, function()
	triggerServerEvent("radio_load_success", getRootElement())

	showPlayerHudComponent ("radio", false)
	setRadioChannel (0)

	bindKey ("radio_next", "down", function(key,state)
		if getVehicleOccupant ( getPlayerOccupiedVehicle(getLocalPlayer()), 0 ) then
			local nextIndex = ((currentIndex)%(#VRP_RADIO_PATHS)) +1
			currentIndex = nextIndex
			local radio = VRP_RADIO_PATHS[nextIndex]
			curRadioName = VRP_RADIO[nextIndex]
			if type (radio) == "number" then
				setRadioChannel (radio)
				if playRadioThing then
					stopSound (playRadioThing)
					playRadioThing = nil
				end
			else
				setRadioChannel (0)
				if playRadioThing then 
					stopSound (playRadioThing)
					playRadioThing = nil
				end
				playRadioThing = playSound (radio)
				setSoundVolume(playRadioThing, volume)
				if getPedOccupiedVehicle(getLocalPlayer()) then
					setElementData(getPedOccupiedVehicle(getLocalPlayer()), "now_radio_played", radio)
					triggerServerEvent("car_radio_changed", getRootElement(), getPedOccupiedVehicle(getLocalPlayer()))
				end
			end
		else
			outputChatBox("Darfst du nicht!", 255, 0, 0)
		end
	end)

	bindKey ("radio_previous","down", function(key,state)
		if getVehicleOccupant ( getPlayerOccupiedVehicle(getLocalPlayer()), 0 ) then
			local nextIndex = ((currentIndex -2)%(#VRP_RADIO_PATHS)) +1
			currentIndex = nextIndex
			local radio = VRP_RADIO_PATHS[nextIndex]
			curRadioName = VRP_RADIO[nextIndex]
			if type (radio) == "number" then
				setRadioChannel (radio)
				if playRadioThing then
					stopSound (playRadioThing)
					playRadioThing = nil
				end
			else
				setRadioChannel (0)
				if playRadioThing then 
					stopSound (playRadioThing)
					playRadioThing = nil
				end
				playRadioThing = playSound (radio)
				setSoundVolume(playRadioThing, volume)
				if getPedOccupiedVehicle(getLocalPlayer()) then
					setElementData(getPedOccupiedVehicle(getLocalPlayer()), "now_radio_played", radio)
					triggerServerEvent("car_radio_changed", getRootElement(), getPedOccupiedVehicle(getLocalPlayer()))
				end
			end
		else
			outputChatBox("Darfst du nicht!", 255, 0, 0)
		end
	end)
end)

function RadioGUI:constructor()
	sW, sH = guiGetScreenSize()
	x, y = 1600, 900
	
	local currentIndex = 1
	
	GUIForm.constructor(self, sW*(461/x), sH*(753/y), sW*(678/x), sH*(137/y))
	self.m_Background = GUIRectangle:new(sW*(461/x), sH*(753/y), sW*(678/x), sH*(137/y), tocolor(0, 0, 0, 200))
	self.m_SliderBack = GUIRectangle:new(sW*(426/x), sH*(753/y), sW*(25/x), sH*(25/y), tocolor(4, 78, 153, 255))
	--self.m_SliderText = GUILabel:new(sW*(426/x), sH*(753/y), sW*(451/x), sH*(778/y), ">", 1)
	
	self.m_SliderText = GUILabel:new(sW*(426/x), sH*(753/y), sW*(25/x), sH*(25/y), ">", 1)
		:setFont(VRPFont(sH*0.025))
	self.m_SliderText:setAlign("center", "center")
	--tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "center", false, false, true, false, false)
	
	self.m_SliderText.onLeftClick = bind(function(self)
		outputChatBox("Hallo")
	end, self)
	
	
	self.m_Strich1 = GUIRectangle:new(sW*(461/x), sH*(753/y), sW*(678/x), sH*(5/y), tocolor(2, 17, 39, 255))

	self.m_CurRadio = GUILabel:new(sW*(461/x), sH*(753/y), sW*(678/x), sH*(67/y), "Keins", 1)
		:setFont(VRPFont(sH*0.05))
	self.m_CurRadio:setAlign("center", "center")
	
	
	setTimer(function()
		self.m_CurRadio:setText(curRadioName)
	end, 50, 0)
	
	
	--tocolor(255, 255, 255, 255), 1.00, "pricedown", "center", "center", false, false, true, false, false)
	
	self.m_Strich2 = GUIRectangle:new(sW*(461/x), sH*(820/y), sW*(678/x), sH*(5/y), tocolor(2, 17, 39, 255))
	self.m_BackLautHoch = GUIRectangle:new(sW*(471/x), sH*(835/y), sW*(177/x), sH*(23/y), tocolor(4, 78, 153, 255))
	self.m_BackLautRunter = GUIRectangle:new(sW*(952/x), sH*(835/y), sW*(177/x), sH*(23/y), tocolor(4, 78, 153, 255))
	self.m_LautHoch = GUILabel:new(sW*(471/x), sH*(835/y), sW*(177/x), sH*(23/y), "Lautstärke: +", 1)
		:setFont(VRPFont(sH*0.025))
	self.m_LautHoch:setAlign("center", "center")
	
	self.m_LautHoch.onLeftClick = bind(function(self)
		if playRadioThing then
			if volume < 1 then
				volume = volume+0.1
				setSoundVolume(playRadioThing, volume)
			else
				outputChatBox("Lauter gehts nicht!", 255, 0, 0)
			end
		end
	end, self)
	
	
	--tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "center", false, false, true, false, false)
	
	self.m_LautRunter = GUILabel:new(sW*(952/x), sH*(835/y), sW*(177/x), sH*(23/y), "Lautstärke: -", 1)
		:setFont(VRPFont(sH*0.025))
	self.m_LautRunter:setAlign("center", "center")
	
	self.m_LautRunter.onLeftClick = bind(function(self)
		if playRadioThing then
			if volume > 0 then
				volume = volume-0.1
				setSoundVolume(playRadioThing, volume)
			else
				outputChatBox("Leiser gehts nicht!", 255, 0, 0)
			end
		end
	end, self)
	
	
	
	
	--tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "center", false, false, true, false, false)
end

function loadRadio()
	RadioGUI:new()
end
addCommandHandler("testr", loadRadio)