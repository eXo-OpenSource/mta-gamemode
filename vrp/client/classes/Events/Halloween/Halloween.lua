Halloween = inherit(Singleton)

function Halloween:constructor()
	local ped = Ped.create(181, Vector3(1487.88, -1710.87, 14.05), 90)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Halloween", "Zeichen-Contest")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			DrawContestOverviewGUI:new()
		end
	)

	HalloweenSign:new()
	HalloweenSpookyScreen:new()
	
	addEventHandler("onClientRender", root, bind(Halloween.renderDarkness, self))
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
end



HalloweenSpookyScreen = inherit(GUIForm3D)
inherit(Singleton, HalloweenSpookyScreen)

function HalloweenSpookyScreen:constructor()
	self.m_Position = Vector3(1480.35, -1777.64, 23)
	self.m_StreamDistance = 100
	self.m_ResX, self.m_ResY = 1280, 720
	self.m_SizeM = 95
	self.m_StartTime = 0
	GUIForm3D.constructor(self, self.m_Position, Vector3(0, 0, 0), Vector2(self.m_ResX/self.m_SizeM, self.m_ResY/self.m_SizeM), Vector2(self.m_ResX,self.m_ResY), self.m_StreamDistance)
end

function HalloweenSpookyScreen:onStreamIn(surface)
	self.m_WebView = GUIWebView:new(0, 0, self.m_ResX, self.m_ResY, string.format("https://www.youtube.com/embed/0DGoQo3HYF0?autoplay=1&controls=0&disablekb=1&loop=1&playlist=0DGoQo3HYF0&showinfo=0&iv_load_policy=3&start=%s", self.m_StartTime), true, surface)
	self.m_WebView:setControlsEnabled(false)
	self.m_WebView.onDocumentReady = function()
		self.m_StremInTC = getTickCount()
		local draw = surface.draw
		surface.draw = function()
			draw(surface)
			local vol = 1 - (getDistanceBetweenPoints3D(self.m_Position, localPlayer.position)/self.m_StreamDistance) 
			self.m_WebView:setVolume(vol/2)--max it to 0.5
		end
	end

end

function HalloweenSpookyScreen:onStreamOut()
	self.m_StartTime = math.floor((self.m_StartTime + (getTickCount()-self.m_StremInTC)/1000)%307) -- video is 307 seconds long
end