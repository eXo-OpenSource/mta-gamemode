Christmas = inherit(Singleton)

function Christmas:constructor()
	
	self.m_QuestManager = QuestManager:new()

	QuestPackageFind.togglePackages(false)

	--Bonus Ped

	if EVENT_CHRISTMAS_MARKET then
		self.m_Music = playSound3D(INGAME_WEB_PATH .. "/ingame/JingleBells.mp3",1479.16, -1697.60, 14.05 , true)
		self.m_Music:setVolume(1)
		self.m_Music:setMaxDistance(50)

		if not core:get("Event", "ChristmasMarketMusic", EVENT_CHRISTMAS) then
			self.m_Music:setVolume(0)
		end

		--Bubble for Wheel of Fortune
		local wheelDummy = createElement("d") -- this element is only available serverside as its rotation is synced
		wheelDummy:setPosition(1479.24, -1671.78, 14.55)
		local wheelBubble = SpeakBubble3D:new(wheelDummy, "Weihnachten", "Glücksrad", 180, 1.5)
		wheelBubble:setBorderColor(Color.LightRed)
		wheelBubble:setTextColor(Color.LightRed)


		--Ferris Wheel ped
		local ped = Ped.create(189, Vector3(1490.94, -1703.03, 14.55), 50)
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

	local ped
	if EVENT_CHRISTMAS_MARKET then -- spawn the ped at the market
		ped = Ped.create(221, Vector3(1456.99, -1684.76, 14.55), 224) -- special shop
	else -- spawn it near town hall
		ped = Ped.create(221, Vector3(1456.93, -1748.58, 13.55), 0)
	end
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Prämien-Shop", 0, 1.3)
	ped.SpeakBubble:setBorderColor(Color.LightRed)
	ped.SpeakBubble:setTextColor(Color.LightRed)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			ChristmasBonusGUI:new()
		end
	)

	local ped
	if EVENT_CHRISTMAS_MARKET then-- spawn the ped at the market
		ped = Ped.create(68, Vector3(1456.50, -1698.16, 14.55), 270)-- Quest Ped
	elseif DEBUG or getRealTime().monthday <= 24 then -- spawn it near town hall
		ped = Ped.create(68, Vector3(1452.84, -1745.13, 13.55), 290)
	end 
	if ped then
		ped:setData("NPC:Immortal", true)
		ped:setFrozen(true)
		ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Adventskalender", 0, 1.3)
		ped.SpeakBubble:setBorderColor(Color.LightRed)
		ped.SpeakBubble:setTextColor(Color.LightRed)
		setElementData(ped, "clickable", true)

		ped:setData("onClickEvent",
			function()
				triggerServerEvent("questOnPedClick", localPlayer)
			end
		)
		local blip = Blip:new("Calendar.png", ped.position.x, ped.position.y, 100, nil, {244, 73, 85})
		blip:attachTo(ped)
		blip:setDisplayText("Adventskalender")
	end

	local ped
	ped = Ped.create(23, 1497.05, -1668.42, 14.05, 181)
	if ped then
		ped:setData("NPC:Immortal", true)
		ped:setFrozen(true)
		ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Cookie Clicker", 0, 1.3)
		ped.SpeakBubble:setBorderColor(Color.LightRed)
		ped.SpeakBubble:setTextColor(Color.LightRed)
		setElementData(ped, "clickable", true)

		ped:setData("onClickEvent",
			function()
				triggerEvent("CookieClicker:openGUI", localPlayer ,ped)
			end
		)
	end

	-- Christmas Truck Ped (El Quebrados)
	local ped
	ped = Ped.create(244, -1568.25, 2703.72, 55.84, 180)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachts-Transport", "Hier startet der Weihnachtstruck", 0, 1.4)
	ped.SpeakBubble:setBorderColor(Color.LightRed)
	ped.SpeakBubble:setTextColor(Color.LightRed)
	setElementData(ped, "clickable", true)
end
