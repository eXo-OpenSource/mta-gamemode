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
