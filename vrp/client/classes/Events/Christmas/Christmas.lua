Christmas = inherit(Singleton)

function Christmas:constructor()
	--SHADERS["Schnee"] = {["event"] = "switchSnow", ["enabled"] = true} -- Seems to produce windows crashes
	self.m_QuestManager = QuestManager:new()

	self.m_Music = playSound3D("http://exo-reallife.de/ingame/JingleBells.mp3",1479.16, -1697.60, 14.05 , true)
	self.m_Music:setVolume(1)
	self.m_Music:setMaxDistance(200)

	table.insert(VRP_RADIO, {"Jinglebells", "http://exo-reallife.de/ingame/JingleBells.mp3"})

	-- Quest Ped
	local ped = Ped.create(68, Vector3(1468.66, -1706.78, 14.05), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Quest", 0, 1.3)
	ped.SpeakBubble:setBorderColor(Color.LightRed)
	ped.SpeakBubble:setTextColor(Color.LightRed)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			triggerServerEvent("questOnPedClick", localPlayer)
		end
	)

	QuestPackageFind.togglePackages(false)

	--Bonus Ped
	local ped = Ped.create(221, Vector3(1488.31, -1707.28, 14.05), 90)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Prämien-Shop", 0, 1.3)
	ped.SpeakBubble:setBorderColor(Color.LightRed)
	ped.SpeakBubble:setTextColor(Color.LightRed)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			BonusGUI:new()
		end
	)

	--Bubble for Wheel of Fortune
	local wheelDummy = createElement("d") -- this element is only available serverside as its rotation is synced
	wheelDummy:setPosition(1479, -1700.3, 14.2)
	local wheelBubble = SpeakBubble3D:new(wheelDummy, "Weihnachten", "Glücksrad", 180, 1.5)
	wheelBubble:setBorderColor(Color.LightRed)
	wheelBubble:setTextColor(Color.LightRed)


	--Ferris Wheel ped
	local ped = Ped.create(189, Vector3(1484.46, -1672.26, 14.05), 149.23)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Riesenrad", 0, 1.3)
	ped.SpeakBubble:setBorderColor(Color.LightRed)
	ped.SpeakBubble:setTextColor(Color.LightRed)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			FerrisWheelGUI:new()
		end
	)
end
