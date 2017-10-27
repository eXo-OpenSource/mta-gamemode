Halloween = inherit(Singleton)

function Halloween:constructor()

	Blip:new("Ghost.png", 945.57, -1103.55, 400):setDisplayText("Halloween-Friedhof")

	--Drawing Contest

	local ped = Ped.create(151, Vector3(906.59998, -1065.7, 24.8), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Zeichen-Wettbewerb")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			DrawContestOverviewGUI:new()
		end
	)


	--Ware Ped
	local ped = Ped.create(68, Vector3(934.79999, -1070.5, 25), 118)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Ware-Games")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			triggerServerEvent("Ware:onPedClick", localPlayer)
		end
	)

	--Bonus Ped
	local ped = Ped.create(264, Vector3(813.40002, -1103.1, 25.8), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Prämien-Shop")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			BonusGUI:new()
		end
	)

	--    <ped id="ped (5)" dimension="0" model="77" interior="0" rotZ="160.003" alpha="255" posX="833.40002" posY="-1112.1" posZ="24.2" rotX="0" rotY="0"></ped>

	--water in grave yard
	
	createWater(884, -1112, 23, 908, -1112, 23, 884, -1090, 23, 908, -1090, 23)
	setWaveHeight(0.2)
	local col = createColSphere(895.49, -1101.41, 24.70, 40)
	addEventHandler("onClientColShapeHit", col, function()
		setTimer(function()
			if localPlayer:isWithinColShape(col) then
				self:addRandomBloodInPool()
			else
				killTimer(sourceTimer)
			end
		end, 50, 0)
	end)

	HalloweenSign:new()
	HalloweenSpookyScreen:new()
end

function Halloween:addRandomBloodInPool()
	local z = 22
	local pos = {
		{894.98, -1097.22, z}, 
		{890.16, -1100.98, z},
		{890.46, -1106.22, z}, 
		{895.81, -1105.37, z},
		{900.75, -1104.33, z}, 
		{897.56, -1101.07, z}, 
		{900.35, -1096.88, z},
		{896.24, -1097.16, z},
		{890.16, -1099.64, z},
		{893.43, -1105.01, z},
		{896.14, -1108.02, z}, 
		{902.12, -1100.06, z}, 
	}
	if chance(25) then createEffect("blood_heli", unpack(pos[math.random(1, #pos)])) end
		fxAddBlood(895.63, -1101.78, 25, 0, 0, 0, 180, 1)
end

HalloweenSign = inherit(GUIForm3D)
inherit(Singleton, HalloweenSign)

function HalloweenSign:constructor()
	--1903, 1484.80, -1710.70
	--rechts -> höher
	GUIForm3D.constructor(self, Vector3(1484.86, -1710.80, 15.90), Vector3(0, 0, 180), Vector2(4.4, 2.09), Vector2(1200,600), 50)
end

function HalloweenSign:onStreamIn(surface)
	self.m_Url = "http://exo-reallife.de/ingame/other/HalloweenSign.php"
	GUIWebView:new(0, 0, 1200, 600, self.m_Url, true, surface)
end


function Halloween:renderDarkness() -- not to be confused with 'dankness'!
	setTime(22,0) -- there are stars after 22 o clock
	setFarClipDistance(100)
	setFogDistance(5)
	setSkyGradient(0, 0, 0, 0, 0, 0)
	setWeather(9)
	setWaterColor(255, 0, 0)
	if chance(25) then
		if chance(50) then
			setTrafficLightState("yellow", "yellow")
		else
			setTrafficLightState("disabled")
		end
	end
end



HalloweenSpookyScreen = inherit(GUIForm3D)
inherit(Singleton, HalloweenSpookyScreen)

function HalloweenSpookyScreen:constructor()
	self.m_Position = Vector3(1480.35, -1777.64, 23)
	self.m_StreamDistance = 100
	self.m_ResX, self.m_ResY = 1280, 720
	self.m_SizeM = 95
	self.m_StartTime = 0
	self.m_Volume = 0.25
	GUIForm3D.constructor(self, self.m_Position, Vector3(0, 0, 0), Vector2(self.m_ResX/self.m_SizeM, self.m_ResY/self.m_SizeM), Vector2(self.m_ResX,self.m_ResY), self.m_StreamDistance)
end

function HalloweenSpookyScreen:onStreamIn(surface)
	local startTime = (getRealTime().hour * 60 * 60 + getRealTime().minute * 60 + getRealTime().second) % 307 -- the video is 307 seconds long

	self.m_WebView = GUIWebView:new(0, 0, self.m_ResX, self.m_ResY, string.format("https://www.youtube.com/embed/0DGoQo3HYF0?autoplay=1&controls=0&disablekb=1&loop=1&playlist=0DGoQo3HYF0&showinfo=0&iv_load_policy=3&start=%s", startTime), true, surface)
	self.m_WebView:setControlsEnabled(false)
	self.m_WebView.onDocumentReady = function()
		local draw = surface.draw
		surface.draw = function()
			draw(surface)
			if not self.m_Muted then
				local vol = 1 - (getDistanceBetweenPoints3D(self.m_Position, localPlayer.position)/self.m_StreamDistance)
				self.m_WebView:setVolume(vol*self.m_Volume)--max it to 0.5
			else
				self.m_WebView:setVolume(0)
			end
		end
	end
	--text, title, tcolor, timeout, callback, timeoutFunc, minimapPos, minimapBlips
	self.m_ShortMessage = ShortMessage:new(_("Lautstärke der Leinwand:\n\n"), nil, nil, -1)
	self.m_ShortMessage.onLeftClick = nil
	self.m_VolumeSlider = GUISlider:new(5, 35, self.m_ShortMessage.m_Width-10, 30, self.m_ShortMessage):setValue(self.m_Volume)
	self.m_VolumeSlider.onUpdate = function(vol)
		self.m_Volume = vol
	end

end

function HalloweenSpookyScreen:onStreamOut()
	if self.m_ShortMessage then self.m_ShortMessage:delete() end
end
